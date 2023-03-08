// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, must_be_immutable, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laraigo_chat/helpers/permissions_handler.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/location_manager.dart';
import '../../helpers/message_type.dart';
import '../../model/color_preference.dart';
import '../../repository/chat_socket_repository.dart';
import 'media_dialog.dart';

/*
This widget is used for picking what kind of files are going to upload. You can pick between
files, location or multimedia files, the widget is rendered in a bottom sheet
 */
class MediaInputModal extends StatefulWidget {
  ColorPreference colorPreference;

  MediaInputModal(this.colorPreference);

  @override
  State<MediaInputModal> createState() => _MediaInputModalState();
}

class _MediaInputModalState extends State<MediaInputModal> {
  AndroidDeviceInfo? _osAndroidDevice;

  @override
  void initState() {
    super.initState();
    getAndroidInfo();
  }

  Future<void> getAndroidInfo() async {
    _osAndroidDevice = await DeviceInfoPlugin().androidInfo;
  }

  var isSendingMessage = false;

  Widget fileDialog(_screenWidth, _screenHeight, List<PlatformFile> files,
      dialogContext, setStateCustom) {
    return Dialog(
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          width: _screenWidth,
          height: _screenHeight * 0.5,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              const Text(
                "Archivos a compartir",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: files.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Text(files[index].name);
                  },
                ),
              ),
              const Expanded(child: SizedBox()),
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
                                    await Future.delayed(
                                        const Duration(seconds: 2));
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
            ]),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _screenWidth = MediaQuery.of(context).size.width;
    var _screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    bool locationRequest = true;
    bool storageRequest = true;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: HexColor(
                      widget.colorPreference.chatBackgroundColor.toString()),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Escoja una opción',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: HexColor(widget.colorPreference
                                                    .chatBackgroundColor
                                                    .toString())
                                                .computeLuminance() >
                                            0.5
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: (() async {
                            if (storageRequest) {
                              storageRequest = false;
                              bool photoPermission = true;

                              if (Platform.isAndroid &&
                                  _osAndroidDevice!.version.sdkInt >= 31) {
                                photoPermission = true;
                              } else {
                                photoPermission = await askStorage();
                              }

                              if (photoPermission) {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                        allowMultiple: true,
                                        type: FileType.media);
                                if (result != null) {
                                  if (result.files.isNotEmpty) {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (dialogContext) {
                                          return StatefulBuilder(builder:
                                              (dialogContext, setStateCustom) {
                                            return MediaDialog(
                                                result.files,
                                                setStateCustom,
                                                isSendingMessage);
                                          });
                                        }).then((valueInDialog) {
                                      var dataToReturn = valueInDialog;

                                      try {
                                        if (dataToReturn["data"].isNotEmpty) {
                                          Navigator.pop(context, dataToReturn);
                                        }
                                      } catch (e) {
                                        Navigator.pop(context, dataToReturn);
                                      }
                                    });
                                  }
                                }
                              } else {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (locationDialogContext) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Librería de archivos denegada'),
                                        content: const Text(
                                            'Por favor brinde acceso a su librería de archivos desde los ajustes, para que pueda compartir su imagen.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cerrar'))
                                        ],
                                      );
                                    });
                              }
                            }
                            storageRequest = true;
                          }),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: HexColor('#8c8c8e'),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Icon(Icons.photo,
                                    color: HexColor(
                                        widget.colorPreference.iconsColor!)),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Abrir galería',
                                style: TextStyle(
                                    color: HexColor(widget.colorPreference
                                                    .chatBackgroundColor
                                                    .toString())
                                                .computeLuminance() >
                                            0.5
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ],
                          )),
                      TextButton(
                          onPressed: (() async {
                            if (storageRequest) {
                              storageRequest = false;
                              bool storagePermission = true;

                              if (Platform.isAndroid &&
                                  _osAndroidDevice!.version.sdkInt >= 31) {
                                storagePermission = true;
                              } else {
                                storagePermission = await askStorage();
                              }

                              if (storagePermission) {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
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
                                  if (result.files.isNotEmpty) {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (dialogContext) {
                                          return StatefulBuilder(builder:
                                              (dialogContext, setStateCustom) {
                                            return fileDialog(
                                                _screenWidth,
                                                _screenHeight,
                                                result.files,
                                                dialogContext,
                                                setStateCustom);
                                          });
                                        }).then((valueInDialog) {
                                      var dataToReturn = valueInDialog;

                                      try {
                                        if (dataToReturn["data"].isNotEmpty) {
                                          Navigator.pop(context, dataToReturn);
                                        }
                                      } catch (e) {
                                        Navigator.pop(context, dataToReturn);
                                      }
                                    });
                                  }
                                }
                              } else {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (locationDialogContext) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Librería de archivos denegada'),
                                        content: const Text(
                                            'Por favor brinde acceso a su librería de archivos desde los ajustes, para que pueda compartir su archivo.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cerrar'))
                                        ],
                                      );
                                    });
                              }
                            }
                            storageRequest = true;
                          }),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: HexColor('#8c8c8e'),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Icon(Icons.attach_file_rounded,
                                    color: HexColor(
                                        widget.colorPreference.iconsColor!)),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Compartir un archivo',
                                style: TextStyle(
                                    color: HexColor(widget.colorPreference
                                                    .chatBackgroundColor
                                                    .toString())
                                                .computeLuminance() >
                                            0.5
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ],
                          )),
                      TextButton(
                          onPressed: (() async {
                            if (locationRequest) {
                              locationRequest = false;
                              final bool gpsAvailable= await gpsVerification(context);

                              if ( gpsAvailable == false) return;
                              bool locationPermission = Platform.isAndroid
                                  ? await askGps()
                                  : await askGpsForIos();
                              if (locationPermission) {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (locationDialogContext) {
                                      return Dialog(
                                        child: SizedBox(
                                          width: _screenWidth * 0.2,
                                          height: _screenHeight * 0.1,
                                          child: Center(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text("Obteniendo Ubicacion..."),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              CircularProgressIndicator()
                                            ],
                                          )),
                                        ),
                                      );
                                    }).then((value) {
                                  Navigator.pop(context, value);
                                });
                                Position location =
                                    await LocationManager.determinePosition();

                                Navigator.pop(context, {
                                  "type": MessageType.location,
                                  "data": [location]
                                });
                              } else {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (locationDialogContext) {
                                      return AlertDialog(
                                        title: const Text('Ubicación denegada'),
                                        content: const Text(
                                            'Por favor brinde acceso a su ubicación desde ajustes, para que pueda compartirla.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cerrar'))
                                        ],
                                      );
                                    });
                              }
                            }
                            locationRequest = true;
                          }),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: HexColor('#8c8c8e'),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Icon(Icons.location_on,
                                    color: HexColor(
                                        widget.colorPreference.iconsColor!)),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text('Compartir ubicación',
                                  style: TextStyle(
                                      color: HexColor(widget.colorPreference
                                                      .chatBackgroundColor
                                                      .toString())
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black
                                          : Colors.white)),
                            ],
                          )),
                    ]),
              ),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                    HexColor(
                        widget.colorPreference.chatBackgroundColor.toString()),
                  )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Cancelar',
                        style: TextStyle(
                            color: HexColor(widget
                                            .colorPreference.chatBackgroundColor
                                            .toString())
                                        .computeLuminance() >
                                    0.5
                                ? Colors.black
                                : Colors.white),
                      )
                    ],
                  )),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.cancel,
                  color: HexColor(widget.colorPreference.chatBackgroundColor
                                  .toString())
                              .computeLuminance() >
                          0.5
                      ? Colors.black
                      : Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}
