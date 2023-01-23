import 'package:brokersdk/model/message_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MessageCarousel extends StatelessWidget {
  List<MessageResponseData> data;
  MessageCarousel(this.data);

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
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: [
                  Image.network(data[index].mediaUrl!),
                  Text(data[index].title!),
                  Text(data[index].description!),
                  ElevatedButton(onPressed: () {}, child: const Text("fasdfa"))
                ],
              ),
            );
          },
          itemCount: data.length,
        ));
  }
}
