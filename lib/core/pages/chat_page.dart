import 'dart:convert';

import 'package:brokersdk/core/chat_socket.dart';
import 'package:brokersdk/core/widget/messages_area.dart';
import 'package:brokersdk/helpers/color_convert.dart';
import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/helpers/sender_type.dart';
import 'package:brokersdk/model/models.dart';
import 'package:brokersdk/model/personalization.dart';

import 'package:brokersdk/repository/chat_socket_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
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
    super.initState();
    initSocket();
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
    initChat();
    await fillWithChatHistory();
  }

  initChat() async {
    widget.socket.channel!.stream.asBroadcastStream().listen((event) {
      var decodedJson = jsonDecode(event);
      decodedJson['sender'] = SenderType.chat.name;
      widget.socket.controller!.sink.add(decodedJson);
    });
  }

  fillWithChatHistory() async {
    setState(() {});
    //Setea el estado para actualizar el stream a que responda
    var savedMessages = await ChatSocketRepository.getLocalMessages();
    await Future.delayed(Duration(seconds: 1));
    //Agrega una lista de mensajes
    widget.socket.controller!.sink.add(savedMessages);
  }

  void sendMessage() async {
    if (_textController.text.isNotEmpty) {
      var response = await ChatSocketRepository.sendMessage(
          _textController.text, MessageType.text);

      //Envia un mensaje unico como una respuesta para reutilizar
      // el from json del stream de mensajes recibidos
      List<MessageResponseData> data = [];
      data.add(MessageResponseData(
        message: _textController.text,
      ));
      var messageSent = MessageResponse(
              type: MessageType.text.name,
              isUser: true,
              error: false,
              message: MessageSingleResponse(
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  data: data,
                  type: MessageType.text.name,
                  id: Uuid().v4().toString()),
              receptionDate: DateTime.now().millisecondsSinceEpoch)
          .toJson();

      setState(() {
        widget.socket.controller!.sink.add(messageSent);
      });

      _textController.clear();
    }
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
    Color textColor =
        backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

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
                      return Row(
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(15),
                                // maximumSize: Size(30, 30)
                              ),
                              onPressed: () {
                                print('hola');
                              },
                              child: Icon(
                                Icons.add_box,
                                color: Colors.black,
                              )),
                          Expanded(
                            child: TextFormField(
                              controller: _textController,
                              textAlign: TextAlign.left,
                              onChanged: (val) {},
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color),
                              decoration: InputDecoration(
                                hintText: "¡Escribe Algo!",
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                                labelStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
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
                            ),
                          ),
                        ],
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
            iconTheme: IconThemeData(color: textColor),
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
                      style: TextStyle(fontSize: 20, color: textColor),
                    ),
                    if (header.headerSubtitle != null)
                      Text(header.headerSubtitle.toString(),
                          style: TextStyle(fontSize: 15, color: textColor))
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
                  width: _screenWidth,
                  height: _screenHeight,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              child: widget.socket.channel != null
                                  ? MessagesArea(widget.socket)
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
