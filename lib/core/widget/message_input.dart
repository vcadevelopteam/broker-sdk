// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/message_status.dart';
import '../../helpers/message_type.dart';
import '../../helpers/single_tap.dart';
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
  FocusNode focusNode;
  MessageInput(this.socket, this.focusNode, {super.key});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _textController = TextEditingController();
  late SharedPreferences prefs;
  late List<dynamic> messages;

  void sendMessage() async {
    if (_textController.text.isNotEmpty) {
      List<MessageResponseData> data = [];
      data.add(MessageResponseData(
        message: _textController.text,
      ));
      var dateSent = DateTime.now().toUtc().millisecondsSinceEpoch;
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
      widget.socket.controller!.sink.add(messageSent);
      if (messages.isEmpty) {
        widget.focusNode.unfocus();
      }

      var response = await ChatSocketRepository.sendMessage(
          _textController.text, "null", MessageType.text);
      _textController.clear();

      if (response.statusCode != 500 || response.statusCode != 400) {
        widget.socket.controller!.sink
            .add({"messageId": dateSent, "status": MessageStatus.sent});
        _textController.clear();
        if (messages.isEmpty) {
          messages = await ChatSocketRepository.getLocalMessages();
        }
      } else {
        widget.socket.controller!.sink
            .add({"messageId": dateSent, "status": MessageStatus.error});
      }
    }
  }

  void sendMultiMediaMessage(Map media, MessageType type) async {
    List<Map<String, dynamic>> messagesToSend = [];
    if (type == MessageType.location) {
      List<MessageResponseData> data = [];

      var response = await ChatSocketRepository.sendMediaMessage(media, type);
      var position = media["data"][0] as Position;
      var dateSent = DateTime.now().toUtc().millisecondsSinceEpoch;
      data.add(MessageResponseData(
          lat: position.latitude,
          long: position.longitude,
          message: "Se envió data de localización"));
      var messageSent = MessageResponse(
              type: type.name,
              isUser: true,
              error: false,
              message: MessageSingleResponse(
                  createdAt: dateSent,
                  data: data,
                  type: type.name,
                  id: const Uuid().v4().toString()),
              receptionDate: dateSent)
          .toJson();

      messagesToSend.add(messageSent);
      if (response.statusCode != 500 || response.statusCode != 400) {
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
                          createdAt:
                              DateTime.now().toUtc().millisecondsSinceEpoch,
                          data: data,
                          type: type.name,
                          id: const Uuid().v4().toString()),
                      receptionDate:
                          DateTime.now().toUtc().millisecondsSinceEpoch)
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
                          createdAt:
                              DateTime.now().toUtc().millisecondsSinceEpoch,
                          data: data,
                          type: type.name,
                          id: const Uuid().v4().toString()),
                      receptionDate:
                          DateTime.now().toUtc().millisecondsSinceEpoch)
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
        case MessageType.image:
          break;
        case MessageType.video:
          break;
      }
    }
    setState(() {
      widget.socket.controller!.sink.add({'data': messagesToSend});
    });
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    messages = await ChatSocketRepository.getLocalMessages();
  }

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    ColorPreference colorPreference =
        widget.socket.integrationResponse!.metadata!.color!;
    Color backgroundColor =
        HexColor(colorPreference.chatBackgroundColor.toString());
    // bool sendValidator = false;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
              top: BorderSide(
            //                   <--- left side
            color: HexColor('#8c8c8e').withOpacity(0.5),
            width: 1.0,
          )),
        ),
        width: screenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),

          // padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: StreamBuilder(builder: (context, snapshot) {
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.focusNode.unfocus();
                          showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
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

                              if (kDebugMode) {
                                print(mapValueInBottomSheet["data"]);
                              }

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
                                  case MessageType.image:
                                    break;
                                  case MessageType.video:
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
                            color: HexColor('#8c8c8e'),

                            //  HexColor(colorPreference.messageBotColor!)
                            //             .computeLuminance() >
                            //         0.5
                            //     ? Colors.black
                            //     : Colors.white, // border color
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: HexColor(colorPreference.iconsColor!),
                            size: 25,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 51,
                          child: Center(
                            child: TextFormField(
                              focusNode: widget.focusNode,
                              controller: _textController,
                              textAlign: TextAlign.left,
                              onChanged: (String val) {
                                setState(() {});
                              },
                              autofocus: false,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: HexColor('#8c8c8e'),
                                  fontWeight: FontWeight.w500

                                  // HexColor(
                                  //     colorPreference.iconsColor.toString())

                                  ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,

                                // HexColor(colorPreference.iconsColor
                                //                 .toString())
                                //             .computeLuminance() >
                                //         0.5
                                //     ? Colors.black
                                //     : Colors.white,

                                hintText: "Escribe un mensaje...",
                                hintMaxLines: 1,

                                contentPadding: const EdgeInsets.only(left: 10),
                                hintStyle: TextStyle(
                                    color: HexColor('#8c8c8e'),
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis

                                    // HexColor(
                                    //     colorPreference.iconsColor.toString())

                                    ),
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
                      ),
                    ],
                  );
                }),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: StreamBuilder(builder: (context, snapshot) {
                  return SingleTapEvent(
                    onTap: () async {
                      final connection =
                          await ChatSocketRepository.hasNetwork();
                      if (connection) {
                        if (_textController.text.isNotEmpty) {
                          sendMessage();
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return const AlertDialog(
                                title: Text('Error de conexión'),
                                content: Text(
                                    'Por favor verifique su conexión de internet e intentelo nuevamente'),
                              );
                            }));
                      }
                    },
                    child: Platform.isIOS
                        ? Text(
                            "Enviar",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: (_textController.text.isEmpty ||
                                        _textController.text == '')
                                    ? HexColor('#8c8c8e')
                                    : HexColor(
                                        colorPreference.messageClientColor!)),
                          )
                        : Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_textController.text.isEmpty ||
                                      _textController.text == '')
                                  ? HexColor('#8c8c8e')
                                  : HexColor(
                                      colorPreference.messageClientColor!),

                              //  HexColor(colorPreference.messageBotColor!)
                              //             .computeLuminance() >
                              //         0.5
                              //     ? Colors.black
                              //     : Colors.white,
                              //      // border color

                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.send,
                                color: HexColor(colorPreference.iconsColor!),
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
