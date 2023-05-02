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
                integrationId: '642de154273d5f64e3daf7e2',
                customMessage: "Averias",
                onInitialized: () {
                  print("Se ha incializado");
                },
                child: const Text("Prueba"),
              ),
              SocketTextButton(
                integrationId: '642de154273d5f64e3daf7e2',
                customMessage: "Averias",
                child: const Text("Prueba"),
                onInitialized: () {
                  print("Se ha incializado");
                },
              ),
              SocketContainer(
                integrationId: '642de154273d5f64e3daf7e2',
                customMessage: "Averias",
                child: const Text("Prueba"),
                onInitialized: () {
                  print("Se ha incializado");
                },
              )
            ],
          ),
        ),
        floatingActionButton: SocketActionButton(
          integrationId: '642de154273d5f64e3daf7e2',
          customMessage: "Averias",
          icon: const Icon(Icons.read_more),
          onInitialized: () {
            print("fasdfadsfadsfads");
          },
        ));
  }
}
