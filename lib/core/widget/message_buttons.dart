// ignore_for_file: must_be_immutable

import 'dart:developer';

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
class MessageButtons extends StatefulWidget {
  Message message;
  String imageUrl;
  List<MessageResponseData> data;
  final ChatSocket _socket;
  ColorPreference color;

  MessageButtons(
      this.message, this.imageUrl, this.data, this.color, this._socket,
      {super.key});

  @override
  State<MessageButtons> createState() => _MessageButtonsState();
}

class _MessageButtonsState extends State<MessageButtons> {
  void sendMessage(String text, String title) async {
    log('message_buttons: text: $text, title: $title');
    var dateSent = DateTime.now().toUtc().millisecondsSinceEpoch;

    List<MessageResponseData> data = [];
    data.add(MessageResponseData(message: text, title: title));
    log('message_buttons ->data: $data');
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
    log('message_buttons ->messageSend: $messageSent');
    widget._socket.controller!.sink.add(messageSent);

    var response =
        await ChatSocketRepository.sendMessage(text, title, MessageType.text);
    if (response.statusCode != 500 || response.statusCode != 400) {
      widget._socket.controller!.sink
          .add({"messageId": dateSent, "status": MessageStatus.sent});
    } else {
      widget._socket.controller!.sink
          .add({"messageId": dateSent, "status": MessageStatus.error});
    }
  }

  bool taped = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return taped == true
        ? const SizedBox()
        : Align(
            alignment: (!widget.message.isUser!)
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!widget.message.isUser!)
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircleAvatar(
                        onBackgroundImageError: (exception, stackTrace) {
                          if (kDebugMode) {
                            print("No Image loaded");
                          }
                        },
                        backgroundImage: NetworkImage(widget.imageUrl),
                      ),
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: Material(
                      color:
                          HexColor(widget.color.chatBackgroundColor.toString()),
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
                                color: HexColor(
                                        widget.color.messageBotColor.toString())
                                    .withOpacity(1.0),
                                borderRadius: BorderRadius.only(
                                    topRight: !widget.message.isUser!
                                        ? const Radius.circular(10)
                                        : const Radius.circular(0),
                                    bottomLeft: widget.message.isUser!
                                        ? const Radius.circular(10)
                                        : const Radius.circular(0),
                                    topLeft: const Radius.circular(10),
                                    bottomRight: const Radius.circular(10))),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(widget.data[0].message ?? '',
                                    style: TextStyle(
                                        color: HexColor(widget.color
                                                        .messageClientColor
                                                        .toString())
                                                    .computeLuminance() >
                                                0.5
                                            ? Colors.white
                                            : Colors.black)),
                                Wrap(
                                  alignment: WrapAlignment.end,
                                  children: widget.data[0].buttons!
                                      .map(
                                        (e) => Container(
                                            margin: const EdgeInsets.all(4),
                                            child: SingleTapEventElevatedButton(
                                                dissapear: true,
                                                style: ElevatedButton.styleFrom(
                                                    minimumSize:
                                                        const Size(50, 35),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5),
                                                    elevation: 0,
                                                    backgroundColor: HexColor(widget
                                                            .color
                                                            .messageClientColor!)
                                                        .withOpacity(0.2),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    side: BorderSide(
                                                      width: 1.0,
                                                      color: HexColor(widget
                                                          .color
                                                          .messageClientColor!),
                                                    )),
                                                onPressed: () async {
                                                  if (mounted) {
                                                    setState(() {
                                                      taped = true;
                                                    });
                                                  }
                                                  if (e.type == 'link') {
                                                    await launchUrl(
                                                        Uri.parse(e.uri!));
                                                    setState(() {});
                                                  } else {
                                                    sendMessage(
                                                        e.payload!, e.text!);
                                                  }
                                                },
                                                child: Text(
                                                  e.text!,
                                                  style: TextStyle(
                                                    color: HexColor(widget.color
                                                        .messageBotColor!),
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
