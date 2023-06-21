// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';
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
              // SocketElevatedButton(
              //   integrationId: '63d8224c5c8a9dde22652275',
              //   onTap: () {
              //     if (kDebugMode) {
              //       print("se ha tapeado");
              //     }
              //   },
              //   onInitialized: () {
              //     if (kDebugMode) {
              //       print("Se ha incializado ${DateTime.now()}");
              //     }
              //   },
              //   child: const Text("Prueba"),
              // ),
              // SocketTextButton(
              //   integrationId: '63d8224c5c8a9dde22652275',
              //   child: const Text("Prueba"),
              //   onTap: () {
              //     if (kDebugMode) {
              //       print("se ha tapeado");
              //     }
              //   },
              //   onInitialized: () {
              //     if (kDebugMode) {
              //       print("Se ha incializado ${DateTime.now()}");
              //     }
              //   },
              // ),
              SocketContainer(
                integrationId: '63d8224c5c8a9dde22652275',
                child: const Text("Prueba"),
                onTap: () {
                  if (kDebugMode) {
                    print("se ha tapeado");
                  }
                },
                onInitialized: () {
                  if (kDebugMode) {
                    print("Se ha incializado ${DateTime.now()}");
                  }
                },
              )
            ],
          ),
        ),
        floatingActionButton: SocketActionButton(
          integrationId: '63d8224c5c8a9dde22652275',
          icon: const Icon(Icons.read_more),
          onTap: () {
            if (kDebugMode) {
              print("se ha tapeado");
            }
          },
          onInitialized: () {
            if (kDebugMode) {
              print("Se ha incializado ${DateTime.now()}");
            }
          },
        ));
  }
}
