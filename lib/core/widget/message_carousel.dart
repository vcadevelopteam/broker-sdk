import 'package:brokersdk/model/carousel_button.dart';
import 'package:brokersdk/model/color_preference.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../helpers/color_convert.dart';

class MessageCarousel extends StatelessWidget {
  ColorPreference color;
  List<MessageResponseData> data;
  MessageCarousel(this.data, this.color);

  Widget getButton(List<CarouselButton> buttons) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: buttons.length,
      itemBuilder: (context, indx) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: ElevatedButton(
              style:  ElevatedButton.styleFrom(
        primary: HexColor(color.messageBotColor!),),
              onPressed: () {},
              child: Text(
                buttons[indx].text!, style: TextStyle(color: HexColor(color.messageBotColor
                                                      .toString())
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black
                                          : Colors.white ),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _screenWidth = MediaQuery.of(context).size.width;
    var _screenHeight = MediaQuery.of(context).size.height - kToolbarHeight;
    return Container(
      margin: EdgeInsets.only(bottom: 20),
        // padding: EdgeInsets.only(bottom: 15),
        width: _screenWidth * 0.9,
        height: _screenHeight * 0.35,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.95),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.only(right: 10,left: 10, top: 5),
              decoration: BoxDecoration(color: HexColor(color.messageBotColor
                                                      .toString())
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black
                                          : Colors.white, borderRadius: BorderRadius.circular(5)),
              margin: const EdgeInsets.only(right: 8),
              
              child: Column(
                children: [
                  Image.network(data[index].mediaUrl!),
                  Text(data[index].title!, style: TextStyle(color:  HexColor(color.messageBotColor
                                                      .toString())
                                                  .computeLuminance() <
                                              0.5
                                          ? Colors.black
                                          : Colors.white,),),
                  Text(data[index].description!, style: TextStyle(color:  HexColor(color.messageBotColor
                                                      .toString())
                                                  .computeLuminance() <
                                              0.5
                                          ? Colors.black
                                          : Colors.white,)),
                  getButton(data[index].buttons!)
                ],
              ),
            );
          },
          itemCount: data.length,
        ));
  }
}
