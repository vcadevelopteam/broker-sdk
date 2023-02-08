// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/message_type.dart';
import '../../model/color_preference.dart';
import '../../model/message_response.dart';
import '../../repository/chat_socket_repository.dart';
import '../chat_socket.dart';
import 'media_input_modal.dart';

/*
This widget is used as an input for the whole chat page
 */
class MessageInput extends StatefulWidget {
  ChatSocket socket;
  MessageInput(this.socket, {super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _textController = TextEditingController();

  void sendMessage() async {
    if (_textController.text.isNotEmpty) {
      var response = await ChatSocketRepository.sendMessage(
          _textController.text, "null", MessageType.text);

      if (response.statusCode != 500 || response.statusCode != 400) {
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
                    id: const Uuid().v4().toString()),
                receptionDate: DateTime.now().millisecondsSinceEpoch)
            .toJson();

        setState(() {
          widget.socket.controller!.sink.add(messageSent);
        });

        _textController.clear();
      }
    }
  }

  void sendMultiMediaMessage(Map media, MessageType type) async {
    List<Map<String, dynamic>> messagesToSend = [];
    if (type == MessageType.location) {
      List<MessageResponseData> data = [];

      var response = await ChatSocketRepository.sendMediaMessage(media, type);
      var position = media["data"][0] as Position;
      data.add(MessageResponseData(
          lat: position.latitude,
          long: position.longitude,
          message: "Se envió data de localización"));
      if (response.statusCode != 500 || response.statusCode != 400) {
        var messageSent = MessageResponse(
                type: type.name,
                isUser: true,
                error: false,
                message: MessageSingleResponse(
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    data: data,
                    type: type.name,
                    id: const Uuid().v4().toString()),
                receptionDate: DateTime.now().millisecondsSinceEpoch)
            .toJson();

        messagesToSend.add(messageSent);
        widget.socket.controller!.sink.add({'data': messagesToSend});
      }
      return;
    }

    var toUse = media["data"] as List;
    for (String element in toUse) {
      List<MessageResponseData> data = [];

      switch (type) {
        case MessageType.media:
          {
            var response =
                await ChatSocketRepository.sendMediaMessage(element, type);
            var parseName = element.split("/");
            final mimeType = lookupMimeType(element);
            data.add(MessageResponseData(
                mediaUrl: element,
                mimeType: mimeType,
                filename: parseName[parseName.length - 1]));
            if (response.statusCode != 500 || response.statusCode != 400) {
              var messageSent = MessageResponse(
                      type: type.name,
                      isUser: true,
                      error: false,
                      message: MessageSingleResponse(
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                          data: data,
                          type: type.name,
                          id: const Uuid().v4().toString()),
                      receptionDate: DateTime.now().millisecondsSinceEpoch)
                  .toJson();

              messagesToSend.add(messageSent);
            }
          }
          break;
        case MessageType.location:
          break;

        case MessageType.file:
          {
            var response =
                await ChatSocketRepository.sendMediaMessage(element, type);
            var parseName = element.split("/");
            final mimeType = lookupMimeType(element);
            data.add(MessageResponseData(
                mediaUrl: element,
                mimeType: mimeType,
                filename: parseName[parseName.length - 1]));
            if (response.statusCode != 500 || response.statusCode != 400) {
              var messageSent = MessageResponse(
                      type: type.name,
                      isUser: true,
                      error: false,
                      message: MessageSingleResponse(
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                          data: data,
                          type: type.name,
                          id: const Uuid().v4().toString()),
                      receptionDate: DateTime.now().millisecondsSinceEpoch)
                  .toJson();

              messagesToSend.add(messageSent);
            }
          }
          break;
        case MessageType.text:
          break;
        case MessageType.button:
          break;
        case MessageType.carousel:
          break;
      }
    }
    setState(() {
      widget.socket.controller!.sink.add({'data': messagesToSend});
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    ColorPreference colorPreference =
        widget.socket.integrationResponse!.metadata!.color!;
    Color backgroundColor =
        HexColor(colorPreference.chatBackgroundColor.toString());

    return SafeArea(
      child: Container(
        color: backgroundColor,
        width: screenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: StreamBuilder(builder: (context, snapshot) {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                                  backgroundColor: HexColor(colorPreference
                                      .chatBackgroundColor
                                      .toString()),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  builder: (modalBottomSheetContext) {
                                    return MediaInputModal(colorPreference);
                                  },
                                  context: context,
                                  isDismissible: true,
                                  isScrollControlled: false)
                              .then((valueInBottomSheet) {
                            try {
                              var mapValueInBottomSheet =
                                  valueInBottomSheet as Map;

                              print(mapValueInBottomSheet["data"]);

                              if (mapValueInBottomSheet["data"].isNotEmpty) {
                                var dataType = mapValueInBottomSheet["type"]
                                    as MessageType;

                                switch (dataType) {
                                  case MessageType.media:
                                    sendMultiMediaMessage(mapValueInBottomSheet,
                                        MessageType.media);
                                    break;
                                  case MessageType.location:
                                    sendMultiMediaMessage(mapValueInBottomSheet,
                                        MessageType.location);
                                    break;

                                  case MessageType.file:
                                    sendMultiMediaMessage(mapValueInBottomSheet,
                                        MessageType.file);
                                    break;
                                  case MessageType.text:
                                    break;
                                  case MessageType.button:
                                    break;
                                  case MessageType.carousel:
                                    break;
                                }
                              }
                            } catch (ex) {
                              if (kDebugMode) {
                                print("No se envia nada");
                              }
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: HexColor(colorPreference
                                .messageBotColor!), // border color
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: HexColor(colorPreference.messageBotColor
                                            .toString())
                                        .computeLuminance() <
                                    0.5
                                ? Colors.black
                                : Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            controller: _textController,
                            textAlign: TextAlign.left,
                            onChanged: (val) {},
                            autofocus: false,
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: HexColor(
                                  colorPreference.chatHeaderColor.toString()),
                              hintText: "¡Escribe Algo!",
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5)),
                              labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: StreamBuilder(builder: (context, snapshot) {
                  return GestureDetector(
                    onTap: () {
                      if (_textController.text.isNotEmpty) {
                        sendMessage();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: HexColor(
                            colorPreference.messageBotColor!), // border color
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.send,
                          color: HexColor(colorPreference.messageBotColor
                                          .toString())
                                      .computeLuminance() <
                                  0.5
                              ? Colors.black
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
