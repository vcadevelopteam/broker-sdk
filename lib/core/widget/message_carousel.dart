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
        return TextButton(
            // style: ButtonStyle(padding:MaterialStatePropertyAll(EdgeInsets.zero)  ),

            onPressed: () {
              sendMessage(buttons[indx].payload.toString(),
                  buttons[indx].text.toString());
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Divider(
                  color: HexColor(color.messageClientColor!),
                ),
                Text(
                  buttons[indx].text!,
                  style: TextStyle(
                    color: HexColor(color.messageClientColor!),
                  ),
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    var screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: double.infinity,
      height: 270,
      child: ListView.builder(
        itemCount: data.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        // controller: PageController(viewportFraction: 0.95),
        itemBuilder: (context, index) {
          return Container(
            
            // padding: const EdgeInsets.only(right: 10, left: 10, top: 5),
            height: screenWidth * 0.75,
            width: 250,
            decoration: BoxDecoration(
                color: HexColor(color.messageBotColor.toString()),
                borderRadius: BorderRadius.circular(5)),
            margin: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        data[index].mediaUrl!,
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        height: 100,
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:10.0),
                    child: Column(
                      children: [
                        Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        data[index].title!, maxLines: 1,
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
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        height: 40,
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
                      child: SizedBox(
                        height: 40,
                        child: getButton(data[index].buttons!)),
                    )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
