// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/message_type.dart';
import '../../helpers/sender_type.dart';
import '../../model/color_preference.dart';
import '../../model/message.dart';
import '../../repository/chat_socket_repository.dart';
import '../chat_socket.dart';
import 'message_bubble.dart';
import 'message_carousel.dart';

/*
This widget is used as an showing area for all the messages, the messages are recollected by an stream that is connected to the web socket
 */
class MessagesArea extends StatefulWidget {
  ChatSocket socket;
  MessagesArea(this.socket, {super.key});

  @override
  State<MessagesArea> createState() => _MessagesAreaState();
}

class _MessagesAreaState extends State<MessagesArea> {
  List<Message> messages = [];
  ScrollController? scrollController;
  bool _visible = true;

  var mystreambuilder;
  @override
  void initState() {
    initStreamBuilder();
    initChat();
    scrollController = ScrollController()..addListener(_scrollListener);

    super.initState();
  }

  @override
  void dispose() {
    scrollController!.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController?.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _visible = false;
      });
    }
    if (scrollController?.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        _visible = true;
      });
    }
  }

  Widget scrollDownButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _visible ? 1.0 : 0.0,
      child: Transform.rotate(
        angle: 270 * math.pi / 180,
        child: messages.isNotEmpty
            ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(0),
                ),
                onPressed: () {
                  setState(() {
                    _visible = false;
                  });
                  scrollController!.animateTo(
                    scrollController!.position.maxScrollExtent + 100,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500),
                  );
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                label: const Text(""))
            : const SizedBox(),
      ),
    );
  }

  initStreamBuilder() {
    scrollController = ScrollController()..addListener(_scrollListener);

    ColorPreference colorPreference =
        widget.socket.integrationResponse!.metadata!.color!;
    mystreambuilder = StreamBuilder(
      stream: widget.socket.controller!.stream,
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          //Valida si lo recibido es una lista o un mensaje
          //Si es una lista va a agregar a cada mensaje de la lista al arreglo local
          if (snapshot.data.runtimeType == List) {
            var recievedMessages = snapshot.data as List;
            for (var element in recievedMessages) {
              var message = Message.fromJson(element);
              messages.add(message);
            }
          } else if ((snapshot.data as Map<String, dynamic>)["data"] != null) {
            var messagesWithMedia =
                (snapshot.data as Map<String, dynamic>)["data"] as List;
            for (var element in messagesWithMedia) {
              var message = Message.fromJson(element);
              messages.add(message);
              message.isSaved = true;
              ChatSocketRepository.saveMessageInLocal(message);
            }
          } else {
            //Si no es una lista solo va a agregar el mensaje al arreglo

            var message =
                Message.fromJson((snapshot.data as Map<String, dynamic>));
            messages.add(message);
            message.isSaved = true;
            ChatSocketRepository.saveMessageInLocal(message);
          }
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (messages.isNotEmpty) {
              scrollController!.animateTo(
                  scrollController!.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear);
            }
          });

          return messages.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          controller: scrollController,
                          reverse: false,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: messages.length,
                          itemBuilder: (ctx, indx) {
                            Widget separator = const SizedBox();

                            if (indx == 0) {
                              separator = _labelDay(f.format(DateTime.parse(
                                  MessageBubble.parseTime(
                                      messages[0].messageDate!))));
                            }
                            if (indx != 0 &&
                                DateTime.fromMillisecondsSinceEpoch(
                                            messages[indx].messageDate!)
                                        .day !=
                                    DateTime.fromMillisecondsSinceEpoch(
                                            messages[indx - 1].messageDate!)
                                        .day) {
                              separator = _labelDay(f.format(DateTime.parse(
                                  MessageBubble.parseTime(
                                      messages[indx].messageDate!))));
                            }

                            return messages[indx].type == MessageType.carousel
                                ? MessageCarousel(messages[indx].data!,
                                    colorPreference, widget.socket)
                                : Column(
                                    children: [
                                      separator,
                                      MessageBubble(
                                          messages[indx],
                                          indx,
                                          colorPreference,
                                          widget
                                              .socket
                                              .integrationResponse!
                                              .metadata!
                                              .icons!
                                              .chatHeaderImage!,
                                          widget.socket)
                                    ],
                                  );
                          }),
                    ),
                  ],
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("No ha enviado mensajes")
                    ],
                  ),
                );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('8.8.8.8');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  initChat() async {
    try {
      widget.socket.channel!.stream.asBroadcastStream().listen((event) async {
        var decodedJson = jsonDecode(event);
        decodedJson['sender'] = SenderType.chat.name;
        widget.socket.controller!.sink.add(decodedJson);
      }, onDone: () async {
        var prefs = await SharedPreferences.getInstance();
        if (prefs.getBool("cerradoManualmente") == false) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text('Error de conexión'),
                content: Text(
                    'Por favor verifique su conexión de internet e intentelo nuevamente'),
              );
            },
          );
        }
        prefs.setBool("cerradoManualmente", false);
      }, onError: (error, stacktrace) async {
        var prefs = await SharedPreferences.getInstance();
        prefs.setBool("cerradoManualmente", false);
      });

      await Future.delayed(const Duration(milliseconds: 50));
      var messagesCount = await ChatSocketRepository.getLocalMessages();
      // if (messagesCount.isNotEmpty) {
      //   // scrollDown();
      // }
    } catch (exception) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Error de conexión'),
            content: Text(
                'Por favor verifique su conexión de internet e intentelo nuevamente'),
          );
        },
      );
    }
  }

  final f = DateFormat('MMMM dd, hh:mm a');
  Widget _labelDay(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Text(
        date,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mystreambuilder,
        Align(alignment: Alignment.bottomCenter, child: scrollDownButton())
      ],
    );
  }
}
