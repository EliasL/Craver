//https://pub.dev/documentation/background_fetch/latest/
// and
//https://github.com/MaikuB/flutter_local_notifications

// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:background_fetch/background_fetch.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

// I have no idea if i need to change this or not TODO
const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

//NB THIS VARIABLE IS ORIGINALLY NOT GLOBAL
//FOR TESTING ONLY, MAYBE...
NotificationAppLaunchDetails? notificationAppLaunchDetails;

/// IMPORTANT: running the following code on its own won't work as there is
/// setup required for each platform head project.
///
/// Please download the complete example app from the GitHub repository where
/// all the setup has been done
///
/// CRAVER has been built on this project, so it should be okay...

void initi_notifications() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('craver_logo'); //Don't use .png!

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: (
            int id,
            String? title,
            String? body,
            String? payload,
          ) async {
            didReceiveLocalNotificationSubject.add(
              ReceivedNotification(
                id: id,
                title: title,
                body: body,
                payload: payload,
              ),
            );
          });
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...

  BackgroundFetch.finish(taskId);
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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  /// This is where you will define a function that will
  /// be called in the background every 15 minutes.
  /// Remember that if the batterysetting is set to
  /// batterysaver, this function will probably only run while
  /// the app is in the forground.

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, DateTime.now());
        _status += 100;
      });

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'flutterfcm',
        'flutterfcm',
        channelDescription: 'your other channel description',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('slow_spring_board'),
        priority: Priority.high,
        importance: Importance.high,
      );
      const IOSNotificationDetails iOSPlatformChannelSpecifics =
          IOSNotificationDetails(sound: 'slow_spring_board.aiff');

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      /*await flutterLocalNotificationsPlugin.show(
        0,
        'custom sound notification title 1',
        'custom sound notification body 2',
        platformChannelSpecifics,
      );*/

      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
      setState(() {
        _status += -5000;
      });
    });

    print('[BackgroundFetch] configure success: $status');
    setState(() {
      _status += 5;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('BackgroundFetch Example',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.amberAccent,
            actions: <Widget>[
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
        bottomNavigationBar: BottomAppBar(
            child: Row(children: <Widget>[
          TextButton(onPressed: _onClickStatus, child: Text('Status')),
          Container(
              margin: EdgeInsets.only(left: 20.0), child: Text("$_status"))
        ])),
      ),
    );
  }
}
