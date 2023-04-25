// ignore_for_file: depend_on_referenced_packages, library_prefixes, non_constant_identifier_names

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:intl/intl.dart';
import 'package:laraigo_chat/repository/chat_socket_repository.dart';
import 'package:open_filex/open_filex.dart';
import 'package:latlong2/latlong.dart' as latLng;

import '../../helpers/color_convert.dart';
import '../../helpers/message_type.dart';
import '../../model/models.dart';
import '../chat_socket.dart';
import 'message_media.dart';

/*
This widget is used for showing a single message, the widget changes between the types of messages
we can filter the message using the MessageType parameter and show different widgets 
 */
class MessageBubble extends StatefulWidget {
  final ChatSocket _socket;
  final Message message;
  final bool? isLastMessage;
  final int indx;

  final ColorPreference color;
  final String imageUrl;
  const MessageBubble(this.message, this.indx, this.color, this.imageUrl,
      this._socket, this.isLastMessage,
      {super.key});

  static String parseTime(int time) {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);
    return dt.toString();
  }

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final mapbox_token =
      'pk.eyJ1IjoiamVhbnZjYSIsImEiOiJjbGdwb2s0eG8xMWVhM2ZxYXd4NW1wNDkwIn0.ZsNwO1RKrbqOPoToiby0tw';
  final mapbox_style = 'mapbox/streets-v12';
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
    } else if (message.type == MessageType.location) {
      return SizedBox(
        width: screenWidth * 0.5,
        height: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: FlutterMap(
            options: MapOptions(
                zoom: 16,
                onTap: null,
                onLongPress: null,
                interactiveFlags: InteractiveFlag.none,
                center: latLng.LatLng(message.data![0].lat!.toDouble(),
                    message.data![0].long!.toDouble())),
            nonRotatedChildren: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: {
                  'accessToken': mapbox_token,
                  'id': mapbox_style
                },
              ),
              MarkerLayer(
                markers: [
                  Marker(
                      point: latLng.LatLng(message.data![0].lat!.toDouble(),
                          message.data![0].long!.toDouble()),
                      // width: 80,
                      // height: 80,
                      builder: (_) {
                        return const SizedBox(
                          height: 25,
                          width: 25,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 23,
                          ),
                        );
                      }),
                ],
              ),
            ],
          ),
          // GoogleMap(
          //   myLocationButtonEnabled: false,
          //   initialCameraPosition: CameraPosition(
          //     target: LatLng(message.data![0].lat!.toDouble(),
          //         message.data![0].long!.toDouble()),
          //     zoom: 14.4746,
          //   ),
          //   zoomControlsEnabled: false,
          //   rotateGesturesEnabled: false,
          //   scrollGesturesEnabled: false,
          //   markers: <Marker>{
          //     Marker(
          //       markerId: const MarkerId('place_name'),
          //       position: LatLng(message.data![0].lat!.toDouble(),
          //           message.data![0].long!.toDouble()),
          //       infoWindow: const InfoWindow(
          //         title: 'Mi ubicación',
          //       ),
          //     )
          //   },
          //   mapType: MapType.normal,
          // ),
        ),
      );
    } else {
      return SizedBox(
        child: Padding(
            padding:
                const EdgeInsets.only(left: 5, top: 0, bottom: 0, right: 10),
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

  generateIconPhoto() {
    if (widget.message.haveIcon) {
      return SizedBox(
        width: 30,
        height: 30,
        child: CircleAvatar(
          onBackgroundImageError: (exception, stackTrace) {
            if (kDebugMode) {
              print("No Image loaded");
            }
          },
          backgroundImage: NetworkImage(widget.imageUrl),
        ),
      );
    } else {
      return const SizedBox(width: 30);
    }
  }

  generateTitle(String systemOS) {
    if (widget.message.haveTitle) {
      return Row(
        children: [
          Text(
            '${widget._socket.integrationResponse!.metadata!.personalization!.headerTitle} - $systemOS',
            style: TextStyle(
              color: HexColor(widget.color.messageBotColor.toString())
                          .computeLuminance() >
                      0.5
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Extra extraOptions =
        widget._socket.integrationResponse!.metadata!.extra!;

    final f = DateFormat('hh:mm');
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final String systemOS = Platform.isAndroid ? 'Android' : 'iOS';

    return Align(
      alignment:
          (!widget.message.isUser! && widget.message.type != MessageType.button)
              ? Alignment.centerLeft
              : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            generateIconPhoto(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Material(
                color: HexColor(widget.color.chatBackgroundColor.toString()),
                borderRadius: BorderRadius.only(
                    topRight: !widget.message.isUser!
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomLeft: widget.message.isUser!
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    topLeft: const Radius.circular(10),
                    bottomRight: const Radius.circular(10)),
                // elevation: widget.message.type != MessageType.button
                //     ? ((widget.message.type == MessageType.media ||
                //                 widget.message.type == MessageType.location) &&
                //             extraOptions.withBorder == false)
                //         ? 0
                //         : 5
                //     : 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        generateTitle(systemOS),
                        Container(
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(
                            maxWidth: widget.message.type == MessageType.button
                                ? screenWidth * 0.8
                                : screenWidth * 0.75,
                            minHeight: 10,
                            maxHeight: screenHeight * 0.6,
                            minWidth: 10,
                          ),
                          decoration: BoxDecoration(
                              color: (widget.message.isUser!)
                                  ? ((widget.message.type ==
                                                  MessageType.media ||
                                              widget.message.type ==
                                                  MessageType.location) &&
                                          extraOptions.withBorder == false)
                                      ? HexColor(widget
                                          .color.chatBackgroundColor
                                          .toString())
                                      : HexColor(widget.color.messageClientColor.toString())
                                          .withOpacity(
                                              widget.message.isSent ? 1.0 : 0.5)
                                  : (widget.message.type == MessageType.button
                                      ? HexColor(widget
                                          .color.chatBackgroundColor
                                          .toString())
                                      : HexColor(widget.color.messageBotColor
                                          .toString())),
                              borderRadius: BorderRadius.only(
                                  topRight: !widget.message.isUser!
                                      ? const Radius.circular(10)
                                      : const Radius.circular(0),
                                  bottomLeft: widget.message.isUser!
                                      ? const Radius.circular(10)
                                      : const Radius.circular(0),
                                  topLeft: const Radius.circular(10),
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
                                          padding: extraOptions.withHour == true
                                              ? const EdgeInsets.only(
                                                  bottom: 20)
                                              : const EdgeInsets.only(),
                                          child: _getMessage(
                                              widget.message,
                                              screenHeight,
                                              screenWidth,
                                              context),
                                        ),
                                        extraOptions.withHour == true
                                            ? const SizedBox(
                                                height: 40,
                                                width: 50,
                                              )
                                            : const SizedBox(),
                                        extraOptions.withHour == true
                                            ? Positioned(
                                                left: widget.message.isUser!
                                                    ? 0
                                                    : 10,
                                                right: widget.message.isUser!
                                                    ? 10
                                                    : 0,
                                                bottom: 0,
                                                child: Text(
                                                  f.format(DateTime.parse(
                                                      MessageBubble.parseTime(
                                                          widget.message
                                                              .messageDate!))),
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color: widget
                                                              .message.isUser!
                                                          ? HexColor(widget
                                                                          .color
                                                                          .messageClientColor
                                                                          .toString())
                                                                      .computeLuminance() >
                                                                  0.5
                                                              ? Colors.black
                                                              : Colors.white
                                                          : HexColor(widget
                                                                          .color
                                                                          .messageBotColor
                                                                          .toString())
                                                                      .computeLuminance() >
                                                                  0.5
                                                              ? Colors.black
                                                              : Colors.white,
                                                      fontSize: 12),
                                                ),
                                              )
                                            : const SizedBox()
                                      ],
                                    ))
                              ]),
                        ),
                      ],
                    ),
                    if (!widget.message.isSent && widget.message.isUser!)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Enviando...",
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.grey[500]),
                          )
                        ],
                      )
                  ],
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
