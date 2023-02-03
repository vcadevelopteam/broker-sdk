// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:brokersdk/core/widget/media_dialog.dart';
import 'package:brokersdk/helpers/color_convert.dart';
import 'package:brokersdk/helpers/locationManager.dart';
import 'package:brokersdk/helpers/message_type.dart';
import 'package:brokersdk/model/color_preference.dart';
import 'package:brokersdk/repository/chat_socket_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class MediaInputModal extends StatefulWidget {
  ColorPreference colorPreference;

  MediaInputModal(this.colorPreference);

  @override
  State<MediaInputModal> createState() => _MediaInputModalState();
}

class _MediaInputModalState extends State<MediaInputModal> {
  @override
  void initState() {
    super.initState();
  }

  var isSendingMessage = false;

  Widget fileDialog(_screenWidth, _screenHeight, List<PlatformFile> files,
      dialogContext, setStateCustom) {
    return Dialog(
      child: Container(
          width: _screenWidth,
          height: _screenHeight * 0.5,
          color: Colors.white,
          child: Column(children: [
            Text("Archivos a compartir"),
            ListView.builder(
              itemCount: files.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Text(files[index].name);
              },
            ),
            isSendingMessage
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        padding: const EdgeInsets.all(10),
                        child: const CircularProgressIndicator()))
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

                                  for (var element in files) {
                                    var resp =
                                        await ChatSocketRepository.uploadFile(
                                            element);
                                    var decodedJson = jsonDecode(resp.body);
                                    responseUrls.add(decodedJson["url"]);
                                  }
                                  await Future.delayed(Duration(seconds: 2));
                                  setStateCustom(() {
                                    isSendingMessage = false;
                                  });
                                  Navigator.pop(dialogContext, {
                                    "type": MessageType.file,
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
  }

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
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(allowMultiple: true, type: FileType.media);
                  if (result != null) {
                    if (result!.files.isNotEmpty) {
                      showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return StatefulBuilder(
                                builder: (dialogContext, setStateCustom) {
                              return MediaDialog(result!.files, setStateCustom,
                                  isSendingMessage);
                            });
                          }).then((valueInDialog) {
                        var dataToReturn = valueInDialog;

                        if (dataToReturn["data"].isNotEmpty) {
                          Navigator.pop(context, dataToReturn);
                        }
                      });
                    }
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
                onPressed: (() async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                          allowMultiple: true,
                          type: FileType.custom,
                          allowedExtensions: [
                        "pdf",
                        "xlsx",
                        "xls",
                        "doc",
                        "docx",
                        "pptx",
                        "csv",
                        "txt"
                      ]);
                  if (result != null) {
                    if (result!.files.isNotEmpty) {
                      showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return StatefulBuilder(
                                builder: (dialogContext, setStateCustom) {
                              return fileDialog(_screenWidth, _screenHeight,
                                  result!.files, dialogContext, setStateCustom);
                            });
                          }).then((valueInDialog) {
                        var dataToReturn = valueInDialog;

                        if (dataToReturn["data"].isNotEmpty) {
                          Navigator.pop(context, dataToReturn);
                        }
                      });
                    }
                  }
                }),
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
                onPressed: (() async {
                  showDialog(
                      context: context,
                      builder: (locationDialogContext) {
                        return Dialog(
                          child: Container(
                            width: _screenWidth * 0.2,
                            height: _screenHeight * 0.1,
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Obteniendo Ubicacion..."),
                                CircularProgressIndicator()
                              ],
                            )),
                          ),
                        );
                      }).then((value) {
                    Navigator.pop(
                        context, {"type": MessageType.location, "data": value});
                  });
                  Position location = await LocationManager.determinePosition();

                  Navigator.pop(context,
                      {"type": MessageType.location, "data": location});
                }),
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
