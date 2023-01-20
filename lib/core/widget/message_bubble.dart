import 'dart:ui';

import 'package:brokersdk/helpers/color_convert.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:brokersdk/model/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final int indx;
  final ColorPreference color;
  final Color textColor = Colors.black;
  const MessageBubble(this.message, this.indx, this.color);

  static String parseTime(int time) {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);
    return dt.toString();
  }

  @override
  Widget build(BuildContext context) {
    final f = new DateFormat('hh:mm');
    var _screenWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment:
          !message.isUser! ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.all(5),
        child: Material(
          borderRadius: BorderRadius.only(
              topRight:
                  !message.isUser! ? Radius.circular(10) : Radius.circular(0),
              bottomLeft: Radius.circular(10),
              topLeft:
                  message.isUser! ? Radius.circular(10) : Radius.circular(0),
              bottomRight: Radius.circular(10)),
          elevation: 10,
          child: Container(
            padding: EdgeInsets.all(10),
            constraints:
                BoxConstraints(maxWidth: _screenWidth * 0.7, minWidth: 10),
            decoration: BoxDecoration(
                color: message.isUser!
                    ? HexColor(color.messageClientColor.toString())
                    : HexColor(color.messageBotColor.toString()),
                border: Border.all(
                    color: HexColor(color.chatBorderColor.toString())),
                borderRadius: BorderRadius.only(
                    topRight: !message.isUser!
                        ? Radius.circular(10)
                        : Radius.circular(0),
                    bottomLeft: Radius.circular(10),
                    topLeft: message.isUser!
                        ? Radius.circular(10)
                        : Radius.circular(0),
                    bottomRight: Radius.circular(10))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: message.isUser!
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.message!,
                  style: TextStyle(color: textColor),
                ),
                Container(
                  // constraints: BoxConstraints(maxWidth: _screenWidth * 0.2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: message.isUser!
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              f.format(DateTime.parse(
                                  parseTime(message.messageDate!))),
                              textAlign: TextAlign.end,
                              style: TextStyle(color: textColor, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}