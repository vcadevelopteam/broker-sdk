// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:brokersdk/helpers/color_convert.dart';
import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/model/color_preference.dart';
import 'package:brokersdk/repository/chat_socket_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';

class MediaInputModal extends StatefulWidget {
  ColorPreference colorPreference;

  MediaInputModal(this.colorPreference);

  @override
  State<MediaInputModal> createState() => _MediaInputModalState();
}

class _MediaInputModalState extends State<MediaInputModal> {
  var isSendingMessage = false;

  @override
  Widget build(BuildContext context) {
    var _screenWidth = MediaQuery.of(context).size.width;
    var _screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escoja una opción',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: HexColor(widget.colorPreference.chatBackgroundColor
                                  .toString())
                              .computeLuminance() >
                          0.5
                      ? Colors.black
                      : Colors.white),
            ),
            TextButton(
                onPressed: (() async {
                  final ImagePicker _picker = ImagePicker();

                  final List<XFile> images = await _picker.pickMultiImage();

                  if (images.isNotEmpty) {
                    showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return StatefulBuilder(
                              builder: (dialogContext, setStateCustom) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(0),
                              backgroundColor: Colors.transparent,
                              child: SizedBox(
                                  width: _screenWidth,
                                  height: _screenHeight * 0.5,
                                  child: Stack(children: [
                                    PageView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        controller: PageController(
                                            viewportFraction: 0.95),
                                        itemCount: images.length,
                                        itemBuilder: (ctx, indx) {
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: FileImage(File(
                                                        images[indx].path)))),
                                          );
                                        }),
                                    isSendingMessage
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Colors.white),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child:
                                                    const CircularProgressIndicator()))
                                        : Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.red[800],
                                                    radius: 30,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              dialogContext,
                                                              []);
                                                        },
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.green[800],
                                                    radius: 30,
                                                    child: IconButton(
                                                        onPressed: () async {
                                                          setStateCustom(() {
                                                            isSendingMessage =
                                                                true;
                                                          });
                                                          var responseUrls = [];

                                                          for (var element
                                                              in images) {
                                                            var resp =
                                                                await ChatSocketRepository
                                                                    .uploadFile(
                                                                        element);
                                                            var decodedJson =
                                                                jsonDecode(
                                                                    resp.body);
                                                            responseUrls.add(
                                                                decodedJson[
                                                                    "url"]);
                                                          }
                                                          await Future.delayed(
                                                              Duration(
                                                                  seconds: 2));
                                                          setStateCustom(() {
                                                            isSendingMessage =
                                                                false;
                                                          });
                                                          Navigator.pop(
                                                              dialogContext, {
                                                            "type": MessageType
                                                                .image,
                                                            "data": responseUrls
                                                          });
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
                      var dataToReturn = valueInDialog;

                      if (dataToReturn["data"].isNotEmpty) {
                        Navigator.pop(context, dataToReturn);
                      }
                    });
                  }
                }),
                child: Text(
                  'Abrir galería',
                  style: TextStyle(
                      color: HexColor(widget.colorPreference.chatBackgroundColor
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
                      color: HexColor(widget.colorPreference.chatBackgroundColor
                                      .toString())
                                  .computeLuminance() >
                              0.5
                          ? Colors.black
                          : Colors.white),
                )),
            TextButton(
                onPressed: (() {}),
                child: Text('Compartir ubicación',
                    style: TextStyle(
                        color: HexColor(widget
                                        .colorPreference.chatBackgroundColor
                                        .toString())
                                    .computeLuminance() >
                                0.5
                            ? Colors.black
                            : Colors.white)))
          ]),
    );
    ;
  }
}
