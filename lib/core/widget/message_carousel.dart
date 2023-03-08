// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:laraigo_chat/helpers/single_tap.dart';

import '../../helpers/color_convert.dart';
import '../../model/carousel_button.dart';
import '../../model/color_preference.dart';
import '../../model/message_response.dart';
import '../chat_socket.dart';

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
    return buttons.length > 1
        ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: buttons.length,
            itemBuilder: (context, indx) {
              return SingleTapEventElevatedButton(
                  loader: const SizedBox(
                      height: 10,
                      width: 10,
                      child: CircularProgressIndicator()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, elevation: 0),
                  onPressed: () {
                    sendMessage(buttons[indx].payload.toString(),
                        buttons[indx].text.toString());
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Divider(
                        color: HexColor(color.messageClientColor!),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          buttons[0].text!,
                          style: TextStyle(
                              color: HexColor(color.messageClientColor!)),
                        ),
                      ),
                    ],
                  ));
            },
          )
        : SingleTapEventElevatedButton(
            loader: const SizedBox(
                height: 10, width: 10, child: CircularProgressIndicator()),
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor(color.messageBotColor!),
              elevation: 0,
            ),
            onPressed: () {
              sendMessage(
                  buttons[0].payload.toString(), buttons[0].text.toString());
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Divider(
                  color: HexColor(color.messageClientColor!),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    buttons[0].text!,
                    style:
                        TextStyle(color: HexColor(color.messageClientColor!)),
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    // var screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
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
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            data[index].title!,
                            maxLines: 1,
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
                                  color:
                                      HexColor(color.messageBotColor.toString())
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
