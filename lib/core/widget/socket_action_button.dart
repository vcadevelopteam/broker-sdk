// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    } catch (exception, _) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Error de conexión'),
            content: Text(
                'Por favor verifique su conexión de internet e intentelo nuevamente'),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      retryFuture(_initchatSocket, 15000);
    }
  }

  retryFuture(future, delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
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
                      ))).then((value) async {
            var prefs = await SharedPreferences.getInstance();
            if (prefs.getBool("cerradoManualmente")! == false) {
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
          });
        }
      },
    );
  }
}
