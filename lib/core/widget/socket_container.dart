// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:laraigo_chat/core/pages/chat_page.dart';

import '../../model/color_preference.dart';
import '../chat_socket.dart';

class SocketContainer extends StatefulWidget {
  Widget child;
  String? integrationId;
  Color? circularProgressIndicatorColor;
  double? height;
  double? width;
  String customMessage;

  SocketContainer(
      {required this.child,
      required this.integrationId,
      this.circularProgressIndicatorColor,
      this.width,
      this.customMessage = "",
      this.height});

  @override
  State<SocketContainer> createState() => _SocketContainerState();
}

class _SocketContainerState extends State<SocketContainer> {
  ChatSocket? socket;
  bool isInitialized = false;
  ColorPreference colorPreference = ColorPreference();

  @override
  void initState() {
    _initchatSocket();
    super.initState();
  }

  _initchatSocket() async {
    socket = await ChatSocket.getInstance(widget.integrationId!);
    colorPreference = socket!.integrationResponse!.metadata!.color!;
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (socket != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        socket: socket!,
                        customMessage: widget.customMessage,
                      )));
        }
      },
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: isInitialized
            ? widget.child
            : Container(
                padding: const EdgeInsets.all(10),
                width: 50,
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(
                    color: widget.circularProgressIndicatorColor,
                  ),
                ),
              ),
      ),
    );
  }
}
