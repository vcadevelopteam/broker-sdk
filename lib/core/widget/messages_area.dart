// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, unused_local_variable

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../../helpers/sender_type.dart';
import '../../model/color_preference.dart';
import '../../model/message.dart';
import '../../repository/chat_socket_repository.dart';
import '../chat_socket.dart';
import 'message_bubble.dart';

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
    super.initState();
  }

  @override
  void dispose() {
    scrollController!.removeListener(_scrollListener);
    super.dispose();
  }

  void scrollDown() {
    scrollController!.animateTo(
      scrollController!.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(seconds: 3),
    );
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
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            }
          });

          return messages.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          controller: scrollController,
                          reverse: false,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: messages.length,
                          itemBuilder: (ctx, indx) {
                            Widget separator = const SizedBox();

                            // if (indx == messages.length - 1) {
                            //   separator = _labelDay(f.format(DateTime.parse(
                            //       MessageBubble.parseTime(
                            //           messages[0].messageDate!))));
                            // }
                            // if (indx != 0 &&
                            //     DateTime.fromMillisecondsSinceEpoch(
                            //                 messages[indx].messageDate!)
                            //             .day !=
                            //         DateTime.fromMillisecondsSinceEpoch(
                            //                 messages[indx - 1].messageDate!)
                            //             .day) {
                            //   separator = _labelDay(f.format(DateTime.parse(
                            //       MessageBubble.parseTime(
                            //           messages[indx].messageDate!))));
                            // }

                            return Column(
                              children: [
                                separator,
                                MessageBubble(
                                    messages[indx],
                                    indx,
                                    colorPreference,
                                    widget.socket.integrationResponse!.metadata!
                                        .icons!.chatHeaderImage!,
                                    widget.socket)
                              ],
                            );
                          }),
                    ),
                  ],
                )
              : Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - kToolbarHeight,
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
                  ),
                );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  initChat() async {
    widget.socket.channel!.stream.asBroadcastStream().listen((event) {
      var decodedJson = jsonDecode(event);
      decodedJson['sender'] = SenderType.chat.name;
      widget.socket.controller!.sink.add(decodedJson);
    });
    await Future.delayed(const Duration(milliseconds: 500));
    var messagesCount = await ChatSocketRepository.getLocalMessages();
    if (messagesCount.isNotEmpty) {
      scrollDown();
    }
  }

  final f = DateFormat('dd/mm/yyyy');
  // Widget _labelDay(String date) {
  //   if (f.format(DateTime.parse(
  //           MessageBubble.parseTime(messages[0].messageDate!))) ==
  //       date) {
  //     date = "Hoy";
  //   }
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
  //     decoration: BoxDecoration(
  //         color: const Color.fromRGBO(106, 194, 194, 1),
  //         borderRadius: BorderRadius.circular(10)),
  //     child: Text(
  //       date,
  //       style: const TextStyle(color: Colors.black),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Widget downButton = Positioned(
      left: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: _visible ? 1.0 : 0.0,
        child: Transform.rotate(
          angle: 270 * math.pi / 180,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: const Color.fromRGBO(106, 194, 194, 1),
                padding: const EdgeInsets.all(0),
              ),
              onPressed: () {
                scrollController!.animateTo(
                  scrollController!.position.maxScrollExtent,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500),
                );
                setState(() {
                  _visible = true;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("")),
        ),
      ),
    );
    return Stack(
      children: [mystreambuilder],
    );
  }
}
