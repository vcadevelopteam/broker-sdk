// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, unused_local_variable, use_build_context_synchronously

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:laraigo_chat/core/widget/message_buttons.dart';

import '../../helpers/message_type.dart';
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
  FocusNode focusNode;
  MessagesArea(this.socket, this.focusNode, {super.key});

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
    scrollController = ScrollController()..addListener(_scrollListener);
    widget.focusNode?.addListener(() {
      if (widget.focusNode.hasFocus) {
        setState(() {
          _visible = false;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController!.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!widget.focusNode.hasFocus) {
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
  }

  Widget scrollDownButton() {
    return IgnorePointer(
      ignoring: !_visible,
      child: AnimatedOpacity(
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
      ),
    );
  }

  validateMessage(int indx, List<Message> messages) {
    if (messages[indx].type != MessageType.button &&
        messages[indx].isUser == false) {
      messages[indx].haveIcon = true;
      messages[indx].haveTitle = true;
    } else {
      validateMessage(indx - 1, messages);
    }
  }

  initStreamBuilder() async {
    scrollController = ScrollController()..addListener(_scrollListener);
    bool counterExceptions = false;

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

          return
              //  messages.isNotEmpty
              //     ?
              Column(
            children: [
              Expanded(
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: scrollController,
                    reverse: false,
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
                      //                 else if (message.type == MessageType.button) {
                      // return MessageButtons(message.data!, widget.color, widget._socket);
                      // }

                      if (messages[indx].type == MessageType.carousel) {
                        return MessageCarousel(
                            messages[indx].data!,
                            colorPreference,
                            widget.socket,
                            indx == (messages.length - 1) ? true : null,
                            widget.socket.integrationResponse!.metadata!.icons!
                                .chatHeaderImage!);
                      }
                      if (messages[indx].type == MessageType.button) {
                        if (indx == (messages.length - 2)) {
                          counterExceptions = true;
                        }

                        return MessageButtons(messages[indx].data!,
                            colorPreference, widget.socket);
                      } else {
                        messages[indx].haveIcon = false;
                        messages[indx].haveTitle = false;

                        if (!messages[indx].isUser!) {
                          validateMessage(messages.length - 1, messages);
                        }

                        return Column(
                          children: [
                            separator,
                            MessageBubble(
                                messages[indx],
                                indx,
                                colorPreference,
                                widget.socket.integrationResponse!.metadata!
                                    .icons!.chatHeaderImage!,
                                widget.socket,
                                indx == (messages.length - 1))
                          ],
                        );
                      }
                    }),
              ),
            ],
          );
          // : SizedBox(
          //     height: MediaQuery.of(context).size.height - kToolbarHeight,
          //     width: MediaQuery.of(context).size.width,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.message,
          //           color: Theme.of(context).textTheme.bodyLarge!.color,
          //         ),
          //         const SizedBox(
          //           width: 10,
          //         ),
          //         const Text("No ha enviado mensajes")
          //       ],
          //     ),
          //   );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
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
