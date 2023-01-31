import 'dart:convert';

import 'package:brokersdk/core/chat_socket.dart';
import 'package:brokersdk/helpers/sender_type.dart';
import 'package:brokersdk/model/color_preference.dart';
import 'package:brokersdk/model/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

import '../../repository/chat_socket_repository.dart';
import 'message_bubble.dart';

class MessagesArea extends StatefulWidget {
  ChatSocket socket;
  MessagesArea(this.socket);

  @override
  State<MessagesArea> createState() => _MessagesAreaState();
}

class _MessagesAreaState extends State<MessagesArea> {
  List<Message> messages = [];

  var mystreambuilder;
  @override
  void initState() {
    initStreamBuilder();
    initChat();
    super.initState();
  }

  initStreamBuilder() {
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
            recievedMessages.forEach((element) {
              var message = Message.fromJson(element);
              messages.add(message);
            });
          } else {
            //Si no es una lista solo va a agregar el mensaje al arreglo
            var message = Message.fromJson(snapshot.data);
            messages.add(message);
            message.isSaved = true;
            ChatSocketRepository.saveMessageInLocal(message);
          }

          return messages.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          reverse: false,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: messages.length,
                          itemBuilder: (ctx, indx) {
                            Widget separator = SizedBox();

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
                                        .icons!.chatHeaderImage!)
                              ],
                            );
                          }),
                    ),
                    // if (_isLoading)
                    //   Container(
                    //       width: 40,
                    //       height: 40,
                    //       child: CircularProgressIndicator())
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message,
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("No ha creado mensajes")
                  ],
                );
        } else {
          return Center(child: CircularProgressIndicator());
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
  }

  final f = new DateFormat('dd/mm/yyyy');
  Widget _labelDay(String date) {
    if (f.format(DateTime.parse(
            MessageBubble.parseTime(messages[0].messageDate!))) ==
        date) {
      date = "Hoy";
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      decoration: BoxDecoration(
          color: Color.fromRGBO(106, 194, 194, 1),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        date,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return mystreambuilder;
  }
}
