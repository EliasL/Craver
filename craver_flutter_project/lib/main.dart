import 'package:flutter/material.dart';
import 'bottom_nav.dart';
import 'pages/alarms.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//Base:
//https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/

void main() async {
  initi_notifications();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const BottomNav(),
    );
  }
}
