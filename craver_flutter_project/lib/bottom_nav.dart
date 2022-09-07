import 'package:craver/authentication.dart';
import 'package:flutter/material.dart';

import 'pages/control_panel.dart';
import 'pages/lb_logbook.dart';
import 'pages/instances.dart';
//import 'pages/alarms.dart';
import 'pages/preferences.dart';
import 'support/settings.dart' as settings;
import 'support/alert.dart';
import 'package:is_lock_screen/is_lock_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

enum PAGES { controllPanel, lbLogbook, instances } //, alarms }

class _BottomNavState extends State<BottomNav> with WidgetsBindingObserver {
  PAGES selectedPage = PAGES.controllPanel;

  //The order in this list MUST match the order in PAGES
  static final List<Widget> _pages = <Widget>[
    const ControlPanel(),
    const LbLogbook(),
    const Instances(),
    //Alarms(),
  ];

  void _onItemTapped(int index) {
    // We only allow users that have logged in to go to
    // other pages than the control panel
    if (!settings.loggedIn) {
      // Since the control panel is the defautl page, we just
      // don't let them change at all
      showOkayDialog('Not logged in!',
          'Guests are not allowed to view other pages. Please login with your CERN account.');
      return;
    }
    selectedPage = PAGES.values[index];
    //_pages[index];
    settings.title.value = settings.defaultTitle;
    switch (selectedPage) {
      case PAGES.controllPanel:
        ControlPanel.startTimer();
        break;
      case PAGES.instances:
        ControlPanel.stopTimer();
        Instances.refresh();
        break;
      case PAGES.lbLogbook:
        ControlPanel.stopTimer();
        LbLogbook.updateTitle(); //Overwrite default title
        LbLogbook.refresh();
        break;
      default:
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (selectedPage == PAGES.controllPanel) {
      ControlPanel.startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // This checks if the phone is locked (Or the screen is off)
    // We should stop updating data while the screen is off
    // We should also refresh the athentication token in case
    // it has expired
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      ControlPanel.stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      if (selectedPage == PAGES.controllPanel) {
        ControlPanel.startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /// We share this messageContext with all the other pages
    /// to show error messages in. This way we are also
    /// probably safe to ignore the: "Do not use BuildContexts across async gaps."
    /// warning. I think this warning come from that the context we give might no
    /// longer be the relative context because of the async. But so long as we
    /// always use this messageContext, it should be fine i think.
    settings.messageContext = context;
    checkVersion();

    Color selectedItemColor;
    switch (settings.theme.value) {
      case Brightness.dark:
        selectedItemColor = Colors.amberAccent;
        break;
      case Brightness.light:
        selectedItemColor = Colors.teal;
        break;
      default:
        selectedItemColor = Colors.amberAccent;
    }

    return Scaffold(
      appBar: AppBar(
        leading: FractionallySizedBox(
            heightFactor: 0.6,
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Preferences()),
                  );
                },
                child: Image.asset('assets/icon/craver_logo_icon.png'))),
        centerTitle: true,
        title: ValueListenableBuilder(
            valueListenable: settings.title,
            builder: (context, String title, widget) {
              return Text(title);
            }),
        elevation: 0,
      ),
      body: IndexedStack(
        index: selectedPage.index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 20,
        selectedIconTheme: IconThemeData(color: selectedItemColor),
        selectedItemColor: selectedItemColor,
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.alarm),
          //   label: 'Alarms',
          // ),
        ],
        currentIndex: selectedPage.index,
        onTap: _onItemTapped,
      ),
    );
  }
}
