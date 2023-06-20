// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:laraigo_chat/core/pages/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/util.dart';
import '../../model/color_preference.dart';
import '../../repository/chat_socket_repository.dart';
import '../chat_socket.dart';

class SocketTextButton extends StatefulWidget {
  Widget child;
  String? integrationId;
  Color? circularProgressIndicatorColor;
  double? height;
  double? width;
  VoidCallback? onInitialized;
  Function? onTap;
  String customMessage;

  SocketTextButton(
      {required this.child,
      required this.integrationId,
      this.circularProgressIndicatorColor,
      this.onInitialized,
      this.onTap,
      this.width,
      this.customMessage = "",
      this.height});

  @override
  State<SocketTextButton> createState() => _SocketTextButtonState();
}

class _SocketTextButtonState extends State<SocketTextButton> {
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
      var prefs = await SharedPreferences.getInstance();
      if (widget.onInitialized != null &&
          (prefs.getBool("isIntialized") == false ||
              prefs.getBool("isIntialized") == null)) {
        widget.onInitialized!();
        await prefs.setBool("isIntialized", isInitialized);
      }

      setState(() {
        isInitialized = true;
      });
    } catch (exception, _) {
      Utils.retryFuture(initchatSocketInButton, 15000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final connection = await ChatSocketRepository.hasNetwork();
        if (socket != null && connection) {
          if (widget.onTap != null) {
            await widget.onTap!();
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        socket: socket!,
                        customMessage: widget.customMessage,
                      )));
        }
      },
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
    );
  }
}
