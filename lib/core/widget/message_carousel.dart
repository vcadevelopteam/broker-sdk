import 'package:brokersdk/model/carousel_button.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MessageCarousel extends StatelessWidget {
  List<MessageResponseData> data;
  MessageCarousel(this.data);

  Widget getButton(List<CarouselButton> buttons) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: buttons.length,
      itemBuilder: (context, indx) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                buttons[indx].text!,
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
        width: _screenWidth * 0.9,
        height: _screenHeight * 0.35,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.95),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20, right: 8),
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: [
                  Image.network(data[index].mediaUrl!),
                  Text(data[index].title!),
                  Text(data[index].description!),
                  getButton(data[index].buttons!)
                ],
              ),
            );
          },
          itemCount: data.length,
        ));
  }
}
