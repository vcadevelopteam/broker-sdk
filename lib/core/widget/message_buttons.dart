import 'package:brokersdk/helpers/color_convert.dart';
import 'package:brokersdk/model/color_preference.dart';
import 'package:brokersdk/model/message_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MessageButtons extends StatelessWidget {
  List<MessageResponseData> data;
  ColorPreference color;

  MessageButtons(this.data, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(data[0].message!),
        ListView.builder(
          shrinkWrap: true,
          itemCount: data[0].buttons!.length,
          itemBuilder: (context, indx) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: HexColor(color.messageBotColor!),
                  ),
                  onPressed: () {},
                  child: Text(
                    data[0].buttons![indx].text!,
                    style: TextStyle(
                        color: HexColor(color.messageBotColor.toString())
                                    .computeLuminance() >
                                0.5
                            ? Colors.black
                            : Colors.white),
                  ),
                ));
          },
        )
      ],
    );
  }
}
