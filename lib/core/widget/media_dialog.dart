import 'dart:convert';

import 'package:laraigo_chat/core/widget/single_media.dart';
import 'package:laraigo_chat/helpers/message_type.dart';
import 'package:laraigo_chat/repository/chat_socket_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MediaDialog extends StatefulWidget {
  List<PlatformFile> files;
  Function setStateCustom;
  bool isSendingMessage;
  MediaDialog(this.files, this.setStateCustom, this.isSendingMessage);

  @override
  State<MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends State<MediaDialog> {
  @override
  Widget build(BuildContext context) {
    var _screenWidth = MediaQuery.of(context).size.width;
    var _screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      child: SizedBox(
          width: _screenWidth,
          height: _screenHeight * 0.5,
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
                                        await ChatSocketRepository.uploadImage(
                                            element);
                                    var decodedJson = jsonDecode(resp.body);
                                    responseUrls.add(decodedJson["url"]);
                                  }
                                  await Future.delayed(Duration(seconds: 2));
                                  setState(() {
                                    widget.isSendingMessage = false;
                                  });
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
    ;
  }
}
