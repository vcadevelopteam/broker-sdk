import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../helpers/color_convert.dart';
import '../../helpers/message_type.dart';
import '../../model/color_preference.dart';
import '../../model/message.dart';
import '../chat_socket.dart';
import 'message_buttons.dart';
import 'message_carousel.dart';

/*
This widget is used for showing a single message, the widget changes between the types of messages
we can filter the message using the MessageType parameter and show different widgets 
 */
class MessageBubble extends StatelessWidget {
  final ChatSocket _socket;
  final Message message;
  final int indx;
  final ColorPreference color;
  final Color textColor = Colors.black;
  final String imageUrl;
  const MessageBubble(
      this.message, this.indx, this.color, this.imageUrl, this._socket,
      {super.key});

  static String parseTime(int time) {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);
    return dt.toString();
  }

  Widget _getMessage(Message message, screenHeight, screenWidth, context) {
    if (message.type == MessageType.text) {
      return Text(
          message.data![0].title!.isNotEmpty
              ? message.data![0].title!
              : message.data![0].message!,
          style: TextStyle(
              color: message.isUser!
                  ? HexColor(color.messageClientColor.toString())
                              .computeLuminance() >
                          0.5
                      ? Colors.black
                      : Colors.white
                  : HexColor(color.messageBotColor.toString())
                              .computeLuminance() >
                          0.5
                      ? Colors.black
                      : Colors.white));
    } else if (message.type == MessageType.carousel) {
      return MessageCarousel(message.data!, color, _socket);
    } else if (message.type == MessageType.media) {
      return GestureDetector(
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
                          controller: PageController(viewportFraction: 0.95),
                          itemCount: 1,
                          itemBuilder: (ctx, indx) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: NetworkImage(
                                          message.data![0].mediaUrl!))),
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
                  image: NetworkImage(message.data![0].mediaUrl!))),
        ),
      );
    } else if (message.type == MessageType.button) {
      return MessageButtons(message.data!, color, _socket);
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file_rounded,
                color: HexColor(color.messageClientColor.toString())
                            .computeLuminance() >
                        0.5
                    ? Colors.black
                    : Colors.white,
              ),

              // SizedBox(width: 5,),
              Text(
                message.data![0].filename.toString(),
                style: TextStyle(
                    color: HexColor(color.messageClientColor.toString())
                                .computeLuminance() >
                            0.5
                        ? Colors.black
                        : Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('hh:mm');
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment:
          !message.isUser! ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!message.isUser!)
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Material(
                borderRadius: BorderRadius.only(
                    topRight: !message.isUser!
                        ? const Radius.circular(10)
                        : const Radius.circular(0),
                    bottomLeft: const Radius.circular(10),
                    topLeft: message.isUser!
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
                      color: message.isUser!
                          ? HexColor(color.messageClientColor.toString())
                          : HexColor(color.messageBotColor.toString()),
                      borderRadius: BorderRadius.only(
                          topRight: !message.isUser!
                              ? const Radius.circular(10)
                              : const Radius.circular(0),
                          bottomLeft: const Radius.circular(10),
                          topLeft: message.isUser!
                              ? const Radius.circular(10)
                              : const Radius.circular(0),
                          bottomRight: const Radius.circular(10))),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: message.isUser!
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            fit: FlexFit.loose,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _getMessage(message, screenHeight,
                                      screenWidth, context),
                                ),
                                const SizedBox(
                                  height: 40,
                                  width: 50,
                                ),
                                Positioned(
                                  left: message.isUser! ? 0 : 10,
                                  right: message.isUser! ? 10 : 0,
                                  bottom: 0,
                                  child: Text(
                                    f.format(DateTime.parse(
                                        parseTime(message.messageDate!))),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        color: message.isUser!
                                            ? HexColor(color.messageClientColor
                                                            .toString())
                                                        .computeLuminance() >
                                                    0.5
                                                ? Colors.black
                                                : Colors.white
                                            : HexColor(color.messageBotColor
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
