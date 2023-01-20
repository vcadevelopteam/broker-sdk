import 'dart:convert';

import 'package:brokersdk/core/chat_socket.dart';
import 'package:brokersdk/helpers/color_convert.dart';
import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/helpers/sender_type.dart';
import 'package:brokersdk/model/models.dart';
import 'package:brokersdk/model/personalization.dart';

import 'package:brokersdk/repository/chat_socket_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../model/color_preference.dart';
import '../../model/message_response.dart';
import '../widget/message_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.socket,
  }) : super(key: key);

  final ChatSocket socket;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var _textController = TextEditingController();
  bool _visible = true;
  List<Message> messages = [];
  final f = new DateFormat('dd/mm/yyyy');

  bool _isLoading = false;
  ScrollController? scrollController;

  @override
  void initState() {
    initSocket();
    super.initState();
  }

  @override
  void dispose() {
    disposeSocket();
    super.dispose();
  }

  disposeSocket() async {
    widget.socket.disconnect();
  }

  initSocket() async {
    await widget.socket.connect();
    widget.socket.channel!.stream.asBroadcastStream().listen((event) {
      setState(() {
        var decodedJson = jsonDecode(event);
        decodedJson['sender'] = SenderType.chat.name;
        widget.socket.controller!.sink.add(decodedJson);
      });
    });
  }

  void sendMessage() async {
    if (_textController.text.isNotEmpty) {
      var response = await ChatSocketRepository.sendMessage(
          _textController.text, MessageType.text);

      var messageSent = {
        'message': _textController.text,
        'messageDate': DateTime.now().millisecondsSinceEpoch,
        'sender': SenderType.user
      };
      setState(() {
        widget.socket.controller!.sink.add(messageSent);
      });

      _textController.clear();
    }
  }

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
    var _screenWidth = MediaQuery.of(context).size.width;
    var _screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    ColorPreference colorPreference =
        widget.socket.integrationResponse!.metadata!.color!;
    Color backgroundColor =
        HexColor(colorPreference.chatBackgroundColor.toString());
    IconsPreference headerIcons =
        widget.socket.integrationResponse!.metadata!.icons!;
    Personalization header =
        widget.socket.integrationResponse!.metadata!.personalization!;

    Widget _messagesArea() {
      return StreamBuilder(
        stream: widget.socket.controller!.stream,
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            var message = Message.fromJson(snapshot.data);
            messages.add(message);
            ChatSocketRepository.saveMessageInLocal(messages);
            return messages.isNotEmpty
                ? Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (ctx, indx) {
                              Widget separator = SizedBox();

                              if (indx == messages.length - 1) {
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

                              return Column(
                                children: [
                                  separator,
                                  MessageBubble(
                                      messages[indx], indx, colorPreference)
                                ],
                              );
                            }),
                      ),
                      if (_isLoading)
                        Container(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator())
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
            return Center(child: Container());
          }
        },
      );
    }

    Widget _messageInput() {
      return SafeArea(
        child: Container(
          color: backgroundColor,
          width: _screenWidth,
          child: Row(
            children: [
              Flexible(
                  flex: 5,
                  child: Container(
                    child: StreamBuilder(builder: (context, snapshot) {
                      return TextFormField(
                        controller: _textController,
                        textAlign: TextAlign.left,
                        onChanged: (val) {},
                        style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).textTheme.bodyText1!.color),
                        decoration: InputDecoration(
                          hintText: "¡Escribe Algo!",
                          hintStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1!.color),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      );
                    }),
                  )),
              Flexible(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: StreamBuilder(builder: (context, snapshot) {
                      return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            primary: _textController.text.length > 0
                                ? Color.fromRGBO(106, 194, 194, 1)
                                : Colors.grey,
                            padding: EdgeInsets.all(15),
                          ),
                          onPressed: () async {
                            if (_textController.text.length > 0) {
                              sendMessage();
                            }
                          },
                          child: Icon(
                            Icons.send,
                            color: Colors.black,
                          ));
                    }),
                  ))
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await widget.socket.channel!.sink.close();

        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor:
                HexColor(colorPreference.chatHeaderColor.toString()),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(headerIcons.chatHeaderImage!),
                  backgroundColor:
                      HexColor(colorPreference.chatHeaderColor.toString()),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      header.headerTitle.toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    if (header.headerSubtitle != null)
                      Text(
                        header.headerSubtitle.toString(),
                        style: const TextStyle(fontSize: 15),
                      )
                  ],
                ),
              ],
            ),
            elevation: 1,
            centerTitle: false,
          ),
          backgroundColor:
              HexColor(colorPreference.chatBackgroundColor.toString()),
          body: Container(
            decoration: BoxDecoration(color: backgroundColor),
            child: Container(
                child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              child: widget.socket.channel != null
                                  ? _messagesArea()
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      _messageInput()
                    ],
                  ),
                ),
              ],
            )),
          )),
    );
  }
}