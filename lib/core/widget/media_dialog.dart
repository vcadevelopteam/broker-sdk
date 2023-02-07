// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
      child: SizedBox(
          width: screenWidth,
          height: screenHeight * 0.5,
          child: Stack(children: [
            PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: PageController(viewportFraction: 0.95),
                itemCount: widget.files.length,
                itemBuilder: (ctx, indx) {
                  return SingleMedia(
                    path: widget.files[indx].path!,
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
                                  Navigator.pop(context,
                                      {"type": MessageType.media, "data": []});
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
                                  setState(() {
                                    widget.isSendingMessage = true;
                                  });
                                  var responseUrls = [];

                                  for (var element in widget.files) {
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
}
