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
  Color? backgroundColor;
  Icon icon;
  SocketActionButton(
      {super.key,
      required this.integrationId,
      required this.icon,
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
    _initchatSocket();
    super.initState();
  }

  _initchatSocket() async {
    try {
      socket = await ChatSocket.getInstance(widget.integrationId!);
      colorPreference = socket!.integrationResponse!.metadata!.color!;
      setState(() {
        isInitialized = true;
      });
    } catch (exception, stacktrace) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Error de conexión'),
            content: Text(
                'Por favor verifique su conexión de internet e intentelo nuevamente'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.backgroundColor ?? Colors.purple,
      child: isInitialized ? widget.icon : const CircularProgressIndicator(),
      onPressed: () {
        if (socket != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(socket: socket!)));
        }
      },
    );
  }
}
