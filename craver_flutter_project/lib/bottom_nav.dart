import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'pages/control_panel.dart';
import 'pages/lb_logbook.dart';
import 'pages/instances.dart';
import 'pages/alarms.dart';
import 'support/settings.dart' as settings;

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

enum PAGES { controllPanel, lbLogbook, instances, alarms }

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  String title = '';

  //The order in this list MUST match the order in PAGES
  //TODO: Make these pages build lazily when clicked on
  //Not all pages at once when the app loads
  static List<Widget> _pages = <Widget>[
    ControlPanel(),
    LbLogbook(),
    Instances(),
    Alarms(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pages[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    checkVersion(context);
    return Scaffold(
      appBar: AppBar(
        leading: FractionallySizedBox(
            heightFactor: 0.6,
            child: Image.asset('assets/icon/craver_logo.png')),
        centerTitle: true,
        title: ValueListenableBuilder(
            valueListenable: LbLogbook.currentPage,
            builder: (context, value, widget) {
              String title = 'CRAVER ${settings.FULLVERSION}';
              if (_selectedIndex == PAGES.lbLogbook.index) {
                title += ': Logbook - page ${LbLogbook.currentPage.value}';
              }
              return Text(title);
            }),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 20,
        selectedIconTheme: const IconThemeData(color: Colors.amberAccent),
        selectedItemColor: Colors.amberAccent,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Logbook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Servers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
