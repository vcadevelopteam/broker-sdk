// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laraigo_chat/helpers/single_tap.dart';
import 'package:laraigo_chat/model/message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/message_status.dart';
import '../../helpers/message_type.dart';
import '../../model/color_preference.dart';
import '../../model/message_response.dart';
import '../../repository/chat_socket_repository.dart';
import '../chat_socket.dart';

/*
Message Widget for Button MessageType
 */
class MessageButtons extends StatelessWidget {
  Message message;
  String imageUrl;
  List<MessageResponseData> data;
  final ChatSocket _socket;
  ColorPreference color;

  MessageButtons(
      this.message, this.imageUrl, this.data, this.color, this._socket,
      {super.key});

  void sendMessage(String text, String title) async {
    var dateSent = DateTime.now().toUtc().millisecondsSinceEpoch;

    List<MessageResponseData> data = [];
    data.add(MessageResponseData(message: text, title: title));
    var messageSent = MessageResponse(
            type: MessageType.text.name,
            isUser: true,
            error: false,
            message: MessageSingleResponse(
                createdAt: dateSent,
                data: data,
                type: MessageType.text.name,
                id: const Uuid().v4().toString()),
            receptionDate: dateSent)
        .toJson();
    _socket.controller!.sink.add(messageSent);

    var response =
        await ChatSocketRepository.sendMessage(text, title, MessageType.text);
    if (response.statusCode != 500 || response.statusCode != 400) {
      _socket.controller!.sink
          .add({"messageId": dateSent, "status": MessageStatus.sent});
    } else {
      _socket.controller!.sink
          .add({"messageId": dateSent, "status": MessageStatus.error});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment:
          (!message.isUser!) ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isUser!)
              SizedBox(
                width: 30,
                height: 30,
                child: CircleAvatar(
                  onBackgroundImageError: (exception, stackTrace) {
                    if (kDebugMode) {
                      print("No Image loaded");
                    }
                  },
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Material(
                color: HexColor(color.chatBackgroundColor.toString()),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                        maxWidth: size.width * 0.8,
                        minHeight: 10,
                        maxHeight: size.height * 0.6,
                        minWidth: 10,
                      ),
                      decoration: BoxDecoration(
                          color: HexColor(color.messageBotColor.toString())
                              .withOpacity(1.0),
                          borderRadius: BorderRadius.only(
                              topRight: !message.isUser!
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0),
                              bottomLeft: message.isUser!
                                  ? const Radius.circular(10)
                                  : const Radius.circular(0),
                              topLeft: const Radius.circular(10),
                              bottomRight: const Radius.circular(10))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(data[0].message ?? '',
                              style: TextStyle(
                                  color: HexColor(color.messageClientColor
                                                  .toString())
                                              .computeLuminance() >
                                          0.5
                                      ? Colors.white
                                      : Colors.black)),
                          Wrap(
                            alignment: WrapAlignment.end,
                            children: data[0]
                                .buttons!
                                .map(
                                  (e) => Container(
                                      margin: const EdgeInsets.all(4),
                                      child: SingleTapEventElevatedButton(
                                          // dissapear: true,
                                          style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(50, 35),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              elevation: 0,
                                              backgroundColor: HexColor(
                                                      color.messageClientColor!)
                                                  .withOpacity(0.2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              side: BorderSide(
                                                width: 1.0,
                                                color: HexColor(
                                                    color.messageClientColor!),
                                              )),
                                          onPressed: () {
                                            if (e.type == 'link') {
                                              launchUrl(Uri.parse(e.uri!));
                                            } else {
                                              sendMessage(e.payload!, e.text!);
                                            }
                                          },
                                          child: Text(
                                            e.text!,
                                            style: TextStyle(
                                              color: HexColor(
                                                  color.messageBotColor!),
                                            ),
                                          ))),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
