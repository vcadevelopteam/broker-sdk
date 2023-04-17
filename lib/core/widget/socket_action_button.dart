// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';

import '../../helpers/util.dart';
import '../../model/color_preference.dart';
import '../../repository/chat_socket_repository.dart';
import '../chat_socket.dart';
import '../pages/chat_page.dart';

/*
This widget is used as main widget for calling or initalizing the whole package for chat
 */
class SocketActionButton extends StatefulWidget {
  String? integrationId;
  Color? backgroundColor;
  Icon icon;
  String customMessage;
  SocketActionButton(
      {super.key,
      required this.integrationId,
      required this.icon,
      this.customMessage = "",
      this.backgroundColor});

  @override
  State<SocketActionButton> createState() => _SocketActionButtonState();
}

class _SocketActionButtonState extends State<SocketActionButton> {
  ChatSocket? socket;
  bool isInitialized = false;
  ColorPreference colorPreference = ColorPreference();
  @override
  void initState() {
    initchatSocketInButton();
    super.initState();
  }

  initchatSocketInButton() async {
    try {
      socket = await ChatSocket.getInstance(widget.integrationId!);
      colorPreference = socket!.integrationResponse!.metadata!.color!;
      setState(() {
        isInitialized = true;
      });
    } catch (exception, _) {
      Utils.retryFuture(initchatSocketInButton, 15000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.backgroundColor ?? Colors.purple,
      child: isInitialized ? widget.icon : const CircularProgressIndicator(),
      onPressed: () async {
        final connection = await ChatSocketRepository.hasNetwork();
        if (socket != null && connection) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        socket: socket!,
                        customMessage: widget.customMessage,
                      )));
        }
      },
    );
  }
}
