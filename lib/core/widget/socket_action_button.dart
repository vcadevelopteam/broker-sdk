// ignore_for_file: must_be_immutable

import 'package:laraigo_chat/core/chat_socket.dart';
import 'package:laraigo_chat/core/pages/chat_page.dart';
import 'package:laraigo_chat/model/color_preference.dart';
import 'package:flutter/material.dart';

class SocketActionButton extends StatefulWidget {
  String? integrationId;
  SocketActionButton({super.key, this.integrationId});

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
      child: isInitialized
          ? const Icon(Icons.house)
          : const CircularProgressIndicator(),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatPage(socket: socket!)));
      },
    );
  }
}
