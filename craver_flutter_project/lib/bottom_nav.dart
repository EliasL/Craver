import 'package:flutter/material.dart';

import 'pages/controll_panel.dart';
import 'pages/lb_logbook.dart';
import 'pages/instances.dart';
import 'pages/alarms.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

enum PAGES { controllPanel, lbLogbook, instances, alarms }

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  String title = 'CRAVER ${LbLogbook.currentPage}';

  //The order in this list MUST match the order in PAGES
  //TODO: Make these pages build lazily when clicked on
  //Not all pages at once when the app loads
  static const List<Widget> _pages = <Widget>[
    ControllPanel(),
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ValueListenableBuilder(
            valueListenable: LbLogbook.currentPage,
            builder: (context, value, widget) {
              String title = 'CRAVER';
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
            label: 'Data',
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
