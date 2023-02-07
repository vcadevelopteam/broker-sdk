import 'package:laraigo_chat/core/chat_socket.dart';
import 'package:laraigo_chat/core/widget/message_input.dart';
import 'package:laraigo_chat/core/widget/messages_area.dart';
import 'package:laraigo_chat/helpers/color_convert.dart';
import 'package:laraigo_chat/model/models.dart';
import 'package:laraigo_chat/repository/chat_socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  bool _visible = true;
  List<Message> messages = [];
  final f = new DateFormat('dd/mm/yyyy');
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
    await fillWithChatHistory();
  }

  fillWithChatHistory() async {
    setState(() {});
    //Setea el estado para actualizar el stream a que responda
    var savedMessages = await ChatSocketRepository.getLocalMessages();
    await Future.delayed(const Duration(seconds: 1));
    //Agrega una lista de mensajes
    widget.socket.controller!.sink.add(savedMessages);
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
                const SizedBox(
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
            elevation: 0,
            centerTitle: false,
          ),
          backgroundColor:
              HexColor(colorPreference.chatBackgroundColor.toString()),
          body: Container(
            height: _screenHeight,
            decoration: BoxDecoration(color: backgroundColor),
            child: Container(
                width: _screenWidth,
                height: _screenHeight,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Flexible(
                      flex: 10,
                      child: Container(
                        child: widget.socket.channel != null
                            ? MessagesArea(widget.socket)
                            : Container(),
                      ),
                    ),
                    MessageInput(widget.socket)
                  ],
                )),
          )),
    );
  }
}
