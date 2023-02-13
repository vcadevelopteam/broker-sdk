// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

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
  bool startedPlaying = false;
  bool isImage = true;

  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
  }

  loadVideoPlayer() async {
    final mimeType = lookupMimeType(widget.message.data![0].mediaUrl!);

    if (!mimeType!.startsWith('image/')) {
      setState(() {
        isImage = false;
      });
      final response =
          await http.get(Uri.parse(widget.message.data![0].mediaUrl!));

      final documentDirectory = await getApplicationDocumentsDirectory();

      final file = File(
          documentDirectory.path + widget.message.data![0].filename.toString());

      file.writeAsBytesSync(response.bodyBytes);

      controller = VideoPlayerController.file(file);
      controller!.initialize();
      setState(() {
        startedPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                          image: NetworkImage(widget
                                              .message.data![0].mediaUrl!))),
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
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.message.data![0].mediaUrl!))),
            ))
        : startedPlaying
            ? GestureDetector(
                onTap: () async {
                  if (controller!.value.isPlaying) {
                    controller!.pause();
                    startedPlaying = false;
                  } else {
                    controller!.play();
                    startedPlaying = true;
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: controller!.value.aspectRatio,
                            child: VideoPlayer(controller!),
                          ),
                        ),
                      ])),
                ),
              )
            : const CircularProgressIndicator();
  }
}
