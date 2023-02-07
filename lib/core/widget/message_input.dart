// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:laraigo_chat/core/chat_socket.dart';
import 'package:laraigo_chat/core/widget/media_input_modal.dart';
import 'package:laraigo_chat/helpers/color_convert.dart';
import 'package:laraigo_chat/helpers/message_type.dart';
import 'package:laraigo_chat/model/color_preference.dart';
import 'package:laraigo_chat/model/icons_preference.dart.dart';
import 'package:laraigo_chat/model/message_response.dart';
import 'package:laraigo_chat/model/personalization.dart';
import 'package:laraigo_chat/repository/chat_socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

class MessageInput extends StatefulWidget {
  ChatSocket socket;
  MessageInput(this.socket);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  var _textController = TextEditingController();

  void sendMessage() async {
    if (_textController.text.isNotEmpty) {
      var response = await ChatSocketRepository.sendMessage(
          _textController.text, "null", MessageType.text);

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

  void sendMultiMediaMessage(Map media, MessageType type) async {
    List<Map<String, dynamic>> messagesToSend = [];
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
                          id: Uuid().v4().toString()),
                      receptionDate: DateTime.now().millisecondsSinceEpoch)
                  .toJson();

              messagesToSend.add(messageSent);
            }
          }
          break;
        case MessageType.location:
          var response =
              await ChatSocketRepository.sendMediaMessage(media, type);
          var position = media["data"] as Position;
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
                        id: Uuid().v4().toString()),
                    receptionDate: DateTime.now().millisecondsSinceEpoch)
                .toJson();

            messagesToSend.add(messageSent);
          }
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
                          id: Uuid().v4().toString()),
                      receptionDate: DateTime.now().millisecondsSinceEpoch)
                  .toJson();

              messagesToSend.add(messageSent);
            }
          }
          break;
        case MessageType.text:
          // TODO: Handle this case.
          break;
        case MessageType.button:
          // TODO: Handle this case.
          break;
        case MessageType.carousel:
          // TODO: Handle this case.
          break;
      }
    }
    setState(() {
      widget.socket.controller!.sink.add({'data': messagesToSend});
    });
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
    return SafeArea(
      child: Container(
        color: backgroundColor,
        width: _screenWidth,
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
                              if (mapValueInBottomSheet["data"].isNotEmpty) {
                                var dataType = mapValueInBottomSheet["type"]
                                    as MessageType;

                                switch (dataType) {
                                  case MessageType.media:
                                    sendMultiMediaMessage(mapValueInBottomSheet,
                                        MessageType.media);
                                    break;
                                  case MessageType.location:
                                    sendMultiMediaMessage(
                                        mapValueInBottomSheet["data"],
                                        MessageType.location);
                                    break;

                                  case MessageType.file:
                                    sendMultiMediaMessage(mapValueInBottomSheet,
                                        MessageType.file);
                                    break;
                                  case MessageType.text:
                                    // TODO: Handle this case.
                                    break;
                                  case MessageType.button:
                                    // TODO: Handle this case.
                                    break;
                                  case MessageType.carousel:
                                    // TODO: Handle this case.
                                    break;
                                }
                              }
                            } catch (ex) {
                              print("No se envia nada");
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
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
                                    .bodyText1!
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
                                      .bodyText1!
                                      .color),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
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
                margin: EdgeInsets.only(left: 10),
                child: StreamBuilder(builder: (context, snapshot) {
                  return GestureDetector(
                    onTap: () {
                      if (_textController.text.length > 0) {
                        sendMessage();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
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
