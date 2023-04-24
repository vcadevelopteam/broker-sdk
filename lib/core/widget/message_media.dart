// ignore_for_file: must_be_immutable, depend_on_referenced_packages

import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

import '../../model/message.dart';

class MediaMessageBubble extends StatefulWidget {
  Message message;
  // ignore: use_key_in_widget_constructors
  MediaMessageBubble(this.message);

  @override
  State<MediaMessageBubble> createState() => _MediaMessageBubbleState();
}

class _MediaMessageBubbleState extends State<MediaMessageBubble> {
  VideoPlayerController? controller;
  ChewieController? chewieController;

  File image = File('');
  bool isImage = false;

  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
  }

  // loadImage() async {
  //   FilePickerResult? result = await FilePicker.platform
  //       .pickFiles(allowMultiple: true, type: FileType.media);
  // }

  loadVideoPlayer() async {
    final documentDirectory = await getApplicationDocumentsDirectory();

    final mimeType = lookupMimeType(widget.message.data![0].mediaUrl!);

    final filePath = path.join(
        documentDirectory.path, widget.message.data![0].filename.toString());
    isImage = false;
    var file = File("");
    if (await File(filePath).exists()) {
      file = File(filePath);
    } else {
      final response =
          await http.get(Uri.parse(widget.message.data![0].mediaUrl!));
      final filePath = path.join(
          documentDirectory.path, widget.message.data![0].filename.toString());
      file = File(filePath);

      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      file.writeAsBytesSync(response.bodyBytes);
      file = File(filePath);
    }
    if (!await file.exists()) file = File(filePath);
    if (!mimeType!.startsWith('image/')) {
      try {
        if (!await file.exists()) file = File(filePath);
        controller = VideoPlayerController.file(file);
        await controller!.initialize();
        setState(() {
          chewieController = ChewieController(
              videoPlayerController: controller!,
              allowFullScreen: true,
              showControls: true);
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error loading video: $e');
        }
      }
    } else {
      isImage = true;
      if (!await file.exists()) file = File(filePath);
      image = file;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return isImage
        ? GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Dialog(
                        insetPadding: const EdgeInsets.all(0),
                        backgroundColor: Colors.transparent,
                        child: SizedBox(
                          width: screenWidth,
                          height: screenHeight,
                          child: PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller:
                                  PageController(viewportFraction: 0.95),
                              itemCount: 1,
                              itemBuilder: (ctx, indx) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          fit: BoxFit.contain,
                                          onError: (exception, stackTrace) {
                                            if (kDebugMode) {
                                              print("No Image loaded");
                                            }
                                          },
                                          image: FileImage(image))),
                                );
                              }),
                        ),
                      ),
                    );
                  });
            },
            child: Container(
                width: double.infinity,
                height: screenHeight * 0.25,
                decoration: const BoxDecoration(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    image,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      return child;
                    },
                  ),
                )

                //  FadeInImage(image:NetworkImage(widget.message.data![0].mediaUrl!) ,placeholder: ,)

                ))
        : controller != null && chewieController != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    if (chewieController != null)
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15)),
                          width: double.infinity,
                          height: controller!.value.size.height,
                          child: Chewie(
                            controller: chewieController!,
                          )),
                  ],
                ))
            : const CircularProgressIndicator();
  }
}
