// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:laraigo_chat/helpers/util.dart';

import '../../helpers/message_type.dart';
import '../../repository/chat_socket_repository.dart';
import 'single_media.dart';

/*
The media dialog widget allow user to update files and preview it.
This widget only appears when a media file is uploaded or recieved and allow to have a preview
 */
class MediaDialog extends StatefulWidget {
  List<PlatformFile> files;
  Function setStateCustom;
  bool isSendingMessage;
  MediaDialog(this.files, this.setStateCustom, this.isSendingMessage,
      {super.key});

  @override
  State<MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends State<MediaDialog> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          width: screenWidth,
          height: screenHeight * 0.5,
          child: Stack(children: [
            PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: PageController(viewportFraction: 0.95),
                itemCount: widget.files.length,
                itemBuilder: (ctx, indx) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleMedia(
                        path: widget.files[indx].path!,
                        indx: indx + 1,
                      ),
                      if (widget.files.length > 1)
                        SizedBox(
                          width: screenWidth,
                          height: 10,
                          child: Center(
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.files.length,
                                itemBuilder: (context, indexSecond) {
                                  return indx != indexSecond
                                      ? Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            border: Border.all(),
                                          ),
                                        )
                                      : Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black,
                                            border: Border.all(),
                                          ),
                                        );
                                }),
                          ),
                        ),
                    ],
                  );
                }),
            widget.isSendingMessage
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context,
                                    {"type": MessageType.media, "data": []});
                              },
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () async {
                                setState(() {
                                  widget.isSendingMessage = true;
                                });
                                var responseUrls = [];
                                var compressedImages =
                                    await Utils.compressImages(widget.files);

                                for (var element in compressedImages) {
                                  var resp =
                                      await ChatSocketRepository.uploadFile(
                                          element);
                                  var decodedJson = jsonDecode(resp.body);
                                  responseUrls.add(decodedJson["url"]);
                                }
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                setState(() {
                                  widget.isSendingMessage = false;
                                });
                                //Pop is used for passing the data to the previous widget without any state manager
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context, {
                                  "type": MessageType.media,
                                  "data": responseUrls
                                });
                              },
                              child: const Text('Enviar')),
                        ],
                      ),
                    ),
                  ),
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.all(40),
                  child: const Text(
                    'Enviar multimedia',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ))
          ])),
    );
  }
}
