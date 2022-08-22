import 'package:flutter/material.dart';
import 'bottom_nav.dart';
//import 'pages/alarms.dart';
import 'support/settings.dart' as settings;

//Base:
//https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/

void main() async {
  //initiNotifications();
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
    return ValueListenableBuilder(
        valueListenable: settings.theme,
        builder: (BuildContext context, dynamic theme, Widget? child) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.teal,
              brightness: theme,
            ),
            debugShowCheckedModeBanner: false,
            home: const BottomNav(),
          );
        });
  }
}
