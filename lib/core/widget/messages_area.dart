// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables, unused_local_variable, use_build_context_synchronously

import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:laraigo_chat/core/widget/message_buttons.dart';
import 'package:laraigo_chat/helpers/message_status.dart';

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
        if (mounted) {
          setState(() {
            _visible = false;
          });
        }
      }
      if (scrollController?.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (mounted) {
          setState(() {
            _visible = true;
          });
        }
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
                    scrollController!.animateTo(
                      scrollController!.position.pixels,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 1),
                    );
                    scrollController!.animateTo(
                      scrollController!.position.maxScrollExtent + 100,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 500),
                    );
                    if (mounted) {
                      setState(() {
                        _visible = false;
                      });
                    }
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

  validateSent(
      List<Message> messages, int messageId, MessageStatus status, String? id) {
    var test =
        messages.firstWhere((element) => element.messageDate == messageId);
    if (status == MessageStatus.sent) {
      test.isSent = true;
      test.messageId = id;
    } else {
      test.hasError = true;
    }
    ChatSocketRepository.updateMessageInLocal(test);
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
          if ((snapshot.data as Map<String, dynamic>)["savedMessages"] !=
              null) {
            var recievedMessages = (snapshot.data
                as Map<String, dynamic>)["savedMessages"] as List;
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
            if ((snapshot.data as Map<String, dynamic>)["messageId"] == null) {
              var message =
                  Message.fromJson((snapshot.data as Map<String, dynamic>));
              messages.add(message);
              message.isSaved = true;
              ChatSocketRepository.saveMessageInLocal(message);
            } else {
              validateSent(
                  messages,
                  (snapshot.data as Map<String, dynamic>)["messageId"],
                  (snapshot.data as Map<String, dynamic>)["status"],
                  (snapshot.data as Map<String, dynamic>)["id"]);
              if (kDebugMode) {
                print((snapshot.data as Map<String, dynamic>)["messageId"]);
              }
            }
          }
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (messages.isNotEmpty) {
              scrollController!.animateTo(
                  scrollController!.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.linear);
              if (mounted) {
                setState(() {
                  _visible = false;
                });
              }
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
                        log(messages[indx].toJson().toString());
                        if (indx == (messages.length - 2)) {
                          counterExceptions = true;
                        }

                        return MessageButtons(
                            messages[indx],
                            widget.socket.integrationResponse!.metadata!.icons!
                                .chatHeaderImage!,
                            messages[indx].data!,
                            colorPreference,
                            widget.socket);
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
