// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:laraigo_chat/helpers/single_tap.dart';
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
  List<MessageResponseData> data;
  final ChatSocket _socket;
  ColorPreference color;

  MessageButtons(this.data, this.color, this._socket, {super.key});

  @override
  State<MessageButtons> createState() => _MessageButtonsState();
}

class _MessageButtonsState extends State<MessageButtons> {
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
        : Padding(
            padding: const EdgeInsets.only(left: 35),
            child: SizedBox(
                width: size.width,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: widget.data[0].buttons!
                      .map(
                        (e) => Container(
                            margin: const EdgeInsets.all(4),
                            child: SingleTapEventElevatedButton(
                                dissapear: true,
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(50, 35),
                                    padding: EdgeInsets.zero,
                                    elevation: 0,
                                    backgroundColor: HexColor(
                                            widget.color.messageClientColor!)
                                        .withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: HexColor(
                                          widget.color.messageClientColor!),
                                    )),
                                onPressed: () {
                                  setState(() {
                                    taped = true;
                                  });
                                  sendMessage(e.payload!, e.text!);
                                },
                                child: Text(
                                  e.text!,
                                  style: TextStyle(
                                    color: HexColor(
                                        widget.color.messageClientColor!),
                                  ),
                                ))),
                      )
                      .toList(),
                )),
          );
  }
}
