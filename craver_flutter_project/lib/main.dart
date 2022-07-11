import 'package:flutter/material.dart';
import 'bottom_nav.dart';

//Base:
//https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/

void main() {
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
