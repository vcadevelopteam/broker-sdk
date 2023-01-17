import 'package:brokersdk/core/chat_socket.dart';
import 'package:flutter/material.dart';

class SocketActionButton extends StatefulWidget {
  String? integrationId;
  SocketActionButton({this.integrationId});

  @override
  State<SocketActionButton> createState() => _SocketActionButtonState();
}

class _SocketActionButtonState extends State<SocketActionButton> {
  ChatSocket? socket;
  @override
  void initState() {
    _initchatSocket();
    super.initState();
  }

  _initchatSocket() async {
    socket = await ChatSocket.getInstance(widget.integrationId!);
    socket!.connect();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.read_more),
      onPressed: () {},
    );
  }
}
