import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';

class SingleMedia extends StatefulWidget {
  String path;
  SingleMedia({super.key, required this.path});

  @override
  State<SingleMedia> createState() => _SingleMediaState();
}

class _SingleMediaState extends State<SingleMedia> {
  VideoPlayerController? controller;

  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
  }

  loadVideoPlayer() {
    final mimeType = lookupMimeType(widget.path);

    if (!mimeType!.startsWith('image/')) {
      controller = VideoPlayerController.file(File(widget.path));
      controller!.addListener(() {});
      controller!.initialize().then((value) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return controller == null
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                    fit: BoxFit.cover, image: FileImage(File(widget.path)))))
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: VideoPlayer(controller!),
              ),
              Container(
                //duration of video
                child: Text(
                    "Total Duration: " + controller!.value.duration.toString()),
              ),
              Container(
                  child: VideoProgressIndicator(controller!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        backgroundColor: Colors.redAccent,
                        playedColor: Colors.green,
                        bufferedColor: Colors.purple,
                      ))),
              Container(
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          if (controller!.value.isPlaying) {
                            controller!.pause();
                          } else {
                            controller!.play();
                          }

                          setState(() {});
                        },
                        icon: Icon(controller!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow)),
                    IconButton(
                        onPressed: () {
                          controller!.seekTo(Duration(seconds: 0));

                          setState(() {});
                        },
                        icon: Icon(Icons.stop))
                  ],
                ),
              )
            ]));
  }
}