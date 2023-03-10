// ignore_for_file: prefer_final_fields

import 'package:laraigo_chat/core/widget/socket_action_button.dart';
import 'package:flutter/material.dart';
import 'package:laraigo_chat/core/widget/socket_container.dart';
import 'package:laraigo_chat/core/widget/socket_text_button.dart';

import 'core/widget/socket_elevated_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SocketElevatedButton(
                child: Text("fasdfa"),
                integrationId: '63fe5143762b546856d9deb0',
                customMessage: "Hola",
              ),
              SocketTextButton(
                child: Text("fasdfa"),
                integrationId: '63fe5143762b546856d9deb0',
                customMessage: "Hola",
              ),
              SocketContainer(
                child: Text("fasdfa"),
                integrationId: '63fe5143762b546856d9deb0',
                customMessage: "Hola",
              )
            ],
          ),
        ),
        floatingActionButton: SocketActionButton(
          integrationId: '63fe5143762b546856d9deb0',
          icon: const Icon(Icons.read_more),
        ));
  }
}
