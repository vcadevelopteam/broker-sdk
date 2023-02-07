import 'package:laraigo_chat/core/chat_socket.dart';
import 'package:laraigo_chat/helpers/color_convert.dart';
import 'package:laraigo_chat/helpers/message_type.dart';
import 'package:laraigo_chat/model/color_preference.dart';
import 'package:laraigo_chat/model/message_response.dart';
import 'package:laraigo_chat/repository/chat_socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:uuid/uuid.dart';

class MessageButtons extends StatelessWidget {
  List<MessageResponseData> data;
  ChatSocket _socket;
  ColorPreference color;

  MessageButtons(this.data, this.color, this._socket);

  sendMessage(String text, String title) async {
    var messageSent = await ChatSocket.sendMessage(text, title);
    _socket.controller!.sink.add(messageSent);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data[0].message!,
          style: TextStyle(
              fontSize: 15,
              color: HexColor(color.messageBotColor.toString())
                          .computeLuminance() >
                      0.5
                  ? Colors.black
                  : Colors.white),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: data[0].buttons!.length,
            itemBuilder: (context, indx) {
              return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: HexColor(color.messageBotColor!),
                    ),
                    onPressed: () {
                      sendMessage(data[0].buttons![indx].payload!,
                          data[0].buttons![indx].text!);
                    },
                    child: Text(
                      data[0].buttons![indx].text!,
                      style: TextStyle(
                          color: HexColor(color.messageBotColor.toString())
                                      .computeLuminance() >
                                  0.5
                              ? Colors.black
                              : Colors.white),
                    ),
                  ));
            },
          ),
        )
      ],
    );
  }
}
