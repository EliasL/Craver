import 'package:flutter/material.dart';
import 'bottom_nav.dart';
//import 'pages/alarms.dart';
import 'support/settings.dart' as settings;
import 'pages/preferences.dart';
import 'support/control_values_and_color.dart';
//Base:
//https://blog.logrocket.com/how-to-build-a-bottom-navigation-bar-in-flutter/

void main() async {
  //initiNotifications();

  // Seems like there is a general issue with flutter
  // Without the time delay, the control panel sometimes doesn't show up.
  //https://github.com/flutter/flutter/issues/105037
  //https://github.com/flutter/flutter/issues/101007
  //https://github.com/flutter/flutter/issues/99680
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(milliseconds: 1000));
  // I added 1000 ms, but I guess less than 1000 ms will also work.
  runApp(const MyApp());
}

Future<void> loadSettings() async {
  loadPreferences();
  ControlValues.loadColorScheme();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: settings.theme,
        builder: (BuildContext context, Brightness theme, Widget? child) {
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
