import 'package:flutter/material.dart';

import 'main_overview.dart';
import 'lb_logbook.dart';
import 'instances.dart';
import 'alarms.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  String title = 'CRAVER ${LbLogbook.currentPage}';

  static const List<Widget> _pages = <Widget>[
    Main_overview(),
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
              //TODO here you can setState or whatever you need
              String title = 'CRAVER';
              if (_selectedIndex == 1) {
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
            icon: Icon(Icons.show_chart),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Logbook',
            //TODO longpress: https://lblogbook.cern.ch/Shift/
            //I give up. Problems with viewing in browser. Could not
            //open in default browser (like chrome). Could not put
            //gestureDetector on lable, and could not remove lable even
            //with showSelectedLabels, showUnselectedLabels. It was just
            // visual
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
