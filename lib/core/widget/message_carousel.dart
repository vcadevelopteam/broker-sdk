// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../helpers/color_convert.dart';
import '../../model/carousel_button.dart';
import '../../model/color_preference.dart';
import '../../model/message_response.dart';
import '../chat_socket.dart';

/*
Message Widget for Carousel MessageType
 */
class MessageCarousel extends StatelessWidget {
  ColorPreference color;
  final ChatSocket _socket;
  List<MessageResponseData> data;
  MessageCarousel(this.data, this.color, this._socket, {super.key});

  void sendMessage(String text, String title) async {
    var messageSent = await ChatSocket.sendMessage(text, title);
    _socket.controller!.sink.add(messageSent);
  }

  Widget getButton(List<CarouselButton> buttons) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: buttons.length,
      itemBuilder: (context, indx) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor(color.messageClientColor!),
              ),
              onPressed: () {
                sendMessage(buttons[indx].payload.toString(),
                    buttons[indx].text.toString());
              },
              child: Text(
                buttons[indx].text!,
                style: TextStyle(
                    color: HexColor(color.messageClientColor.toString())
                                .computeLuminance() >
                            0.5
                        ? Colors.black
                        : Colors.white),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    return Container(
      constraints:
          BoxConstraints(maxHeight: screenHeight * 0.55, minHeight: 10),
      child: PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: PageController(viewportFraction: 0.95),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 5),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5)),
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        data[index].mediaUrl!,
                        fit: BoxFit.contain,
                        height: 200,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    data[index].title!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HexColor(color.messageBotColor.toString())
                                  .computeLuminance() >
                              0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.08,
                  child: SingleChildScrollView(
                    child: Text(data[index].description!,
                        maxLines: 5,
                        style: TextStyle(
                          color: HexColor(color.messageBotColor.toString())
                                      .computeLuminance() >
                                  0.5
                              ? Colors.black
                              : Colors.white,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: getButton(data[index].buttons!),
                )
              ],
            ),
          );
        },
        itemCount: data.length,
      ),
    );
  }
}
