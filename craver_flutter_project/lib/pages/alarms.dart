import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

final Map<String, String> httpHeaders = {
  HttpHeaders.contentTypeHeader: "application/json",
  "Connection": "keep-alive",
  "Keep-Alive": "timeout=5, max=1000"
};

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // This has been done in main.dart
  //await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class Alarms extends StatefulWidget {
  const Alarms({Key? key}) : super(key: key);

  @override
  _AlarmsState createState() => _AlarmsState();
}

class _AlarmsState extends State<Alarms> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings? settings;

  void init_notification_settings() async {
    settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings!.authorizationStatus}');
  }

  @override
  void initState() {
    super.initState();
    init_notification_settings();
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
    } else {
      print('[BackgroundFetch] stop success:');
    }
    ;
  }

  void _onClick() async {
    final functions = FirebaseFunctions.instance;
    //TODO remember to remove this when running on real server
    //functions.useFunctionsEmulator("10.0.2.2", 5001);
    try {
      final result = await functions.httpsCallable('helloWorld').call();
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('subscribed?',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.amberAccent,
            actions: <Widget>[
              TextButton(onPressed: _onClick, child: const Text('Check')),
              Switch(value: _enabled, onChanged: _onClickEnable),
            ],
            systemOverlayStyle: SystemUiOverlayStyle.dark),
        body: Container(
          color: Colors.black,
          child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (BuildContext context, int index) {
                DateTime timestamp = _events[index];
                return InputDecorator(
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                        labelStyle: TextStyle(
                            color: Colors.amberAccent, fontSize: 20.0),
                        labelText: "[background fetch event]"),
                    child: Text(timestamp.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 16.0)));
              }),
        ),
      ),
    );
  }
}
