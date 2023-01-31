// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:brokersdk/core/chat_socket.dart';
import 'package:brokersdk/helpers/color_convert.dart';
import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/model/color_preference.dart';
import 'package:brokersdk/model/icons_preference.dart.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:brokersdk/model/personalization.dart';
import 'package:brokersdk/repository/chat_socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
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
  var isSendingMessage = false;

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

  void sendMediaMessage(List media, MessageType type) async {
    media.forEach((element) async {
      var response = await ChatSocketRepository.sendMediaMessage(element, type);
      var parseName = element.split("/");
      final mimeType = lookupMimeType(element);

      if (response.statusCode != 500 || response.statusCode != 400) {
        List<MessageResponseData> data = [];
        data.add(MessageResponseData(
            mediaUrl: element,
            mimeType: mimeType,
            filename: parseName[parseName.length - 1]));
        var messageSent = MessageResponse(
                type: MessageType.image.name,
                isUser: true,
                error: false,
                message: MessageSingleResponse(
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    data: data,
                    type: MessageType.image.name,
                    id: Uuid().v4().toString()),
                receptionDate: DateTime.now().millisecondsSinceEpoch)
            .toJson();

        setState(() {
          widget.socket.controller!.sink.add(messageSent);
        });
      }
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
                              elevation: 0,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                              primary: HexColor(
                                  colorPreference.chatHeaderColor.toString()),

                              // maximumSize: Size(30, 30)
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                      backgroundColor: HexColor(colorPreference
                                          .chatBackgroundColor
                                          .toString()),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              12)), //for the round edges
                                      builder: (modalBottomSheetContext) {
                                        return Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Escoja una opción',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: HexColor(colorPreference
                                                                      .chatBackgroundColor
                                                                      .toString())
                                                                  .computeLuminance() >
                                                              0.5
                                                          ? Colors.black
                                                          : Colors.white),
                                                ),
                                                TextButton(
                                                    onPressed: (() async {
                                                      final ImagePicker
                                                          _picker =
                                                          ImagePicker();

                                                      final List<XFile> images =
                                                          await _picker
                                                              .pickMultiImage();

                                                      if (images.isNotEmpty) {
                                                        showDialog(
                                                            context:
                                                                modalBottomSheetContext,
                                                            builder:
                                                                (dialogContext) {
                                                              return StatefulBuilder(builder:
                                                                  (dialogContext,
                                                                      setStateCustom) {
                                                                return Dialog(
                                                                  insetPadding:
                                                                      const EdgeInsets
                                                                          .all(0),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  child: SizedBox(
                                                                      width: _screenWidth,
                                                                      height: _screenHeight * 0.5,
                                                                      child: Stack(children: [
                                                                        PageView.builder(
                                                                            physics: const BouncingScrollPhysics(),
                                                                            controller: PageController(viewportFraction: 0.95),
                                                                            itemCount: images.length,
                                                                            itemBuilder: (ctx, indx) {
                                                                              return Container(
                                                                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(fit: BoxFit.cover, image: FileImage(File(images[indx].path)))),
                                                                              );
                                                                            }),
                                                                        isSendingMessage
                                                                            ? Align(
                                                                                alignment: Alignment.center,
                                                                                child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white), padding: const EdgeInsets.all(10), child: const CircularProgressIndicator()))
                                                                            : Align(
                                                                                alignment: Alignment.bottomCenter,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Container(
                                                                                      margin: const EdgeInsets.all(10),
                                                                                      child: CircleAvatar(
                                                                                        backgroundColor: Colors.red[800],
                                                                                        radius: 30,
                                                                                        child: IconButton(
                                                                                            onPressed: () {
                                                                                              Navigator.pop(dialogContext, []);
                                                                                            },
                                                                                            icon: const Icon(
                                                                                              Icons.close,
                                                                                              color: Colors.white,
                                                                                            )),
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      margin: const EdgeInsets.all(10),
                                                                                      child: CircleAvatar(
                                                                                        backgroundColor: Colors.green[800],
                                                                                        radius: 30,
                                                                                        child: IconButton(
                                                                                            onPressed: () async {
                                                                                              setStateCustom(() {
                                                                                                isSendingMessage = true;
                                                                                              });
                                                                                              var responseUrls = [];

                                                                                              for (var element in images) {
                                                                                                var resp = await ChatSocketRepository.uploadFile(element);
                                                                                                var decodedJson = jsonDecode(resp.body);
                                                                                                responseUrls.add(decodedJson["url"]);
                                                                                              }
                                                                                              await Future.delayed(Duration(seconds: 2));
                                                                                              setStateCustom(() {
                                                                                                isSendingMessage = false;
                                                                                              });
                                                                                              Navigator.pop(dialogContext, responseUrls);
                                                                                            },
                                                                                            icon: const Icon(
                                                                                              Icons.check,
                                                                                              color: Colors.white,
                                                                                            )),
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                      ])),
                                                                );
                                                              });
                                                            }).then((valueInDialog) {
                                                          var valueListinBottomSheet =
                                                              valueInDialog
                                                                  as List;

                                                          if (valueListinBottomSheet
                                                              .isNotEmpty) {
                                                            Navigator.pop(
                                                                context,
                                                                valueListinBottomSheet);
                                                          }
                                                        });
                                                      }
                                                    }),
                                                    child: Text(
                                                      'Abrir galería',
                                                      style: TextStyle(
                                                          color: HexColor(colorPreference
                                                                          .chatBackgroundColor
                                                                          .toString())
                                                                      .computeLuminance() >
                                                                  0.5
                                                              ? Colors.black
                                                              : Colors.white),
                                                    )),
                                                TextButton(
                                                    onPressed: (() {}),
                                                    child: Text(
                                                      'Compartir un archivo',
                                                      style: TextStyle(
                                                          color: HexColor(colorPreference
                                                                          .chatBackgroundColor
                                                                          .toString())
                                                                      .computeLuminance() >
                                                                  0.5
                                                              ? Colors.black
                                                              : Colors.white),
                                                    )),
                                                TextButton(
                                                    onPressed: (() {}),
                                                    child: Text(
                                                        'Compartir ubicación',
                                                        style: TextStyle(
                                                            color: HexColor(colorPreference
                                                                            .chatBackgroundColor
                                                                            .toString())
                                                                        .computeLuminance() >
                                                                    0.5
                                                                ? Colors.black
                                                                : Colors
                                                                    .white)))
                                              ]),
                                        );
                                      },
                                      context: context,
                                      isDismissible: true,
                                      isScrollControlled: false)
                                  .then((valueInBottomSheet) {
                                var listvalueInBottomSheet =
                                    valueInBottomSheet as List;
                                if (listvalueInBottomSheet.isNotEmpty) {
                                  sendMediaMessage(listvalueInBottomSheet,
                                      MessageType.image);
                                }
                              });
                            },
                            child: Icon(
                              Icons.add_box,
                              color: HexColor(colorPreference.messageBotColor!),
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
                              filled: true,
                              fillColor: HexColor(
                                  colorPreference.chatHeaderColor.toString()),
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
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
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
                          elevation: 0,
                          shape: CircleBorder(),
                          primary: HexColor(
                              colorPreference.chatHeaderColor.toString()),
                          padding: EdgeInsets.all(15),
                        ),
                        onPressed: () async {
                          if (_textController.text.length > 0) {
                            sendMessage();
                          }
                        },
                        child: Icon(
                          Icons.send,
                          color: HexColor(colorPreference.messageBotColor!),
                        ));
                  }),
                ))
          ],
        ),
      ),
    );
  }
}
