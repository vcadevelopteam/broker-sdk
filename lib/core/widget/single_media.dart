// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';

/*
This widget is used for show a single media file in the media dialog 
 */
class SingleMedia extends StatefulWidget {
  String path;
  int indx;
  SingleMedia({super.key, required this.path, required this.indx});

  @override
  State<SingleMedia> createState() => _SingleMediaState();
}

class _SingleMediaState extends State<SingleMedia> {
  VideoPlayerController? controller;
  ChewieController? chewieController;
  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
  }

  loadVideoPlayer() async {
    final mimeType = lookupMimeType(widget.path);

    if (!mimeType!.startsWith('image/')) {
      controller = VideoPlayerController.file(File(widget.path));
      await controller!.initialize();
      setState(() {
        chewieController = ChewieController(
            videoPlayerController: controller!,
            allowFullScreen: true,
            showControls: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return controller == null && chewieController == null
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    height: 200,
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(widget.path))))),
                // SizedBox(
                //   width: size.width,
                //   height: 20,
                //   child: Center(
                //     child: ListView.builder(
                //         shrinkWrap: true,
                //         scrollDirection: Axis.horizontal,
                //         itemCount: widget.indx,
                //         itemBuilder: (context, index) {
                //           return const Icon(Icons.panorama_fisheye_outlined);
                //         }),
                //   ),
                // )
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    if (chewieController != null)
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          height: size.height * 0.26,
                          child: Chewie(
                            controller: chewieController!,
                          )),
                  ],
                )));
  }
}
