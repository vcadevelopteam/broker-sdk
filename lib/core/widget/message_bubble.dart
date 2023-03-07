import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:laraigo_chat/repository/chat_socket_repository.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/message_type.dart';
import '../../model/color_preference.dart';
import '../../model/message.dart';
import '../chat_socket.dart';
import 'message_buttons.dart';
import 'message_media.dart';

/*
This widget is used for showing a single message, the widget changes between the types of messages
we can filter the message using the MessageType parameter and show different widgets 
 */
class MessageBubble extends StatefulWidget {
  final ChatSocket _socket;
  final Message message;
  final int indx;
  final ColorPreference color;
  final String imageUrl;
  const MessageBubble(
      this.message, this.indx, this.color, this.imageUrl, this._socket,
      {super.key});

  static String parseTime(int time) {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);
    return dt.toString();
  }

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isLoading = false;

  final Color textColor = Colors.black;

  Widget _getMessage(Message message, screenHeight, screenWidth, context) {
    if (message.type == MessageType.text) {
      return Text(
          message.data![0].title!.isNotEmpty
              ? message.data![0].title!
              : message.data![0].message!,
          style: TextStyle(
              color: message.isUser!
                  ? HexColor(widget.color.messageClientColor.toString())
                              .computeLuminance() >
                          0.5
                      ? Colors.black
                      : Colors.white
                  : HexColor(widget.color.messageBotColor.toString())
                              .computeLuminance() >
                          0.5
                      ? Colors.black
                      : Colors.white));
    }
    //  else if (message.type == MessageType.carousel) {
    //   return MessageCarousel(message.data!, color, _socket);
    // }
    else if (message.type == MessageType.media) {
      return MediaMessageBubble(message);
    } else if (message.type == MessageType.button) {
      return MessageButtons(message.data!, widget.color, widget._socket);
    } else if (message.type == MessageType.location) {
      return SizedBox(
        width: screenWidth * 0.5,
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(message.data![0].lat!.toDouble(),
                  message.data![0].long!.toDouble()),
              zoom: 14.4746,
            ),
            zoomControlsEnabled: false,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            markers: <Marker>{
              Marker(
                markerId: const MarkerId('place_name'),
                position: LatLng(message.data![0].lat!.toDouble(),
                    message.data![0].long!.toDouble()),
                infoWindow: const InfoWindow(
                  title: 'Mi ubicación',
                ),
              )
            },
            mapType: MapType.normal,
          ),
        ),
      );
    } else {
      return SizedBox(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 5, top: 20, bottom: 10, right: 10),
            child: TextButton(
              onPressed: () async {
                String? dir = await ChatSocketRepository.getDownloadPath();

                if (!File('$dir/${message.data![0].filename!}').existsSync()) {
                  setState(() {
                    isLoading = true;
                  });
                  var file = await ChatSocketRepository.downloadFile(
                      message.data![0].mediaUrl!, message.data![0].filename!);
                  setState(() {
                    isLoading = false;
                  });
                  await OpenFilex.open(file.path);
                } else {
                  await OpenFilex.open('$dir/${message.data![0].filename!}');
                }
              },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file_rounded,
                            color: message.isUser!
                                ? HexColor(widget.color.messageClientColor
                                                .toString())
                                            .computeLuminance() >
                                        0.5
                                    ? Colors.black
                                    : Colors.white
                                : HexColor(widget.color.messageBotColor
                                                .toString())
                                            .computeLuminance() >
                                        0.5
                                    ? Colors.black
                                    : Colors.white),

                        // SizedBox(width: 5,),
                        Flexible(
                          child: Text(
                            message.data![0].filename.toString(),
                            style: TextStyle(
                                color: message.isUser!
                                    ? HexColor(widget.color.messageClientColor
                                                    .toString())
                                                .computeLuminance() >
                                            0.5
                                        ? Colors.black
                                        : Colors.white
                                    : HexColor(widget.color.messageBotColor
                                                    .toString())
                                                .computeLuminance() >
                                            0.5
                                        ? Colors.black
                                        : Colors.white),
                          ),
                        ),
                      ],
                    ),
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('hh:mm');
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: !widget.message.isUser!
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.message.isUser!)
              CircleAvatar(
                onBackgroundImageError: (exception, stackTrace) {
                  print("No Image loaded");
                },
                backgroundImage: NetworkImage(widget.imageUrl),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Material(
                borderRadius: BorderRadius.only(
                    topRight: !widget.message.isUser!
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomLeft: const Radius.circular(10),
                    topLeft: widget.message.isUser!
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomRight: const Radius.circular(10)),
                elevation: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.7,
                    minHeight: 10,
                    maxHeight: screenHeight * 0.6,
                    minWidth: 10,
                  ),
                  decoration: BoxDecoration(
                      color: widget.message.isUser!
                          ? HexColor(widget.color.messageClientColor.toString())
                          : HexColor(widget.color.messageBotColor.toString()),
                      borderRadius: BorderRadius.only(
                          topRight: !widget.message.isUser!
                              ? const Radius.circular(10)
                              : const Radius.circular(0),
                          bottomLeft: const Radius.circular(10),
                          topLeft: widget.message.isUser!
                              ? const Radius.circular(10)
                              : const Radius.circular(0),
                          bottomRight: const Radius.circular(10))),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: widget.message.isUser!
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            fit: FlexFit.loose,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _getMessage(widget.message,
                                      screenHeight, screenWidth, context),
                                ),
                                const SizedBox(
                                  height: 40,
                                  width: 50,
                                ),
                                Positioned(
                                  left: widget.message.isUser! ? 0 : 10,
                                  right: widget.message.isUser! ? 10 : 0,
                                  bottom: 0,
                                  child: Text(
                                    f.format(DateTime.parse(
                                        MessageBubble.parseTime(
                                            widget.message.messageDate!))),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: widget.message.isUser!
                                            ? HexColor(widget.color
                                                            .messageClientColor
                                                            .toString())
                                                        .computeLuminance() >
                                                    0.5
                                                ? Colors.black
                                                : Colors.white
                                            : HexColor(widget.color
                                                            .messageBotColor
                                                            .toString())
                                                        .computeLuminance() >
                                                    0.5
                                                ? Colors.black
                                                : Colors.white,
                                        fontSize: 12),
                                  ),
                                )
                              ],
                            ))
                      ]),
                ),
              ),
            ),
            // if (message.isUser!)
            //   const CircleAvatar(
            //     backgroundImage: AssetImage(
            //       'assets/user_default.png',
            //     ),
            //     backgroundColor: Colors.white,
            //   ),
          ],
        ),
      ),
    );
  }
}
