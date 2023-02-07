# Laraigo Chat

Flutter dependency that implements Laraigo's services.

## Features

- Real time comunication
- Online chat customization
- Multimedia files picker
- Share location
- Multiple kinds of interactions (Text, Buttons, and Carousels)

## Getting started

You should ensure that you add the router as a dependency in your flutter project.

```yaml
dependencies:
  laraigo_chat: ^1.0.0
```

You should then run `flutter packages upgrade` or update your packages in IntelliJ.

## Example Project

There is a example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

## Usage

Need to include the import the package to the dart file where it will be used, use the below command,

```dart
import 'package:laraigo_chat/socket_action_button.dart';
```

**Circular percent indicator**

Basic Widget

```dart
  floatingActionButton: SocketActionButton(
          integrationId: 'Your Integration Id',
        )
```

Complete example

```dart
import 'package:laraigo_chat/core/widget/socket_action_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
        floatingActionButton: SocketActionButton(
          integrationId: 'Your Integration Id',
        ));
  }
}

```

Creditos: [Lino Mac Kay](https://github.com/LinoMacKay) y [Jean Aguirre](https://github.com/jeanmarko2703)
