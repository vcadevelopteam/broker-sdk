// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../model/color_preference.dart';
import '../chat_socket.dart';
import '../pages/chat_page.dart';

/*
This widget is used as main widget for calling or initalizing the whole package for chat
 */
class SocketActionButton extends StatefulWidget {
  String? integrationId;
  Icon icon;
  SocketActionButton(
      {super.key, required this.integrationId, required this.icon});

  @override
  State<SocketActionButton> createState() => _SocketActionButtonState();
}

class _SocketActionButtonState extends State<SocketActionButton> {
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
    return FloatingActionButton(
      child: isInitialized ? widget.icon : const CircularProgressIndicator(),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatPage(socket: socket!)));
      },
    );
  }
}
