// ignore_for_file: constant_identifier_names

library craver.globals;

import 'package:flutter/cupertino.dart';

const bool DEVELOPMENT = true;
const String VERSION = '1.0';
const String SUPPORT_EMAIL = 'lbonsupp@cern.ch';

/// Local Preferences
/// These variables will be stored localy on the
/// users phone and each require a key to access.
/// This list is used purely to ensure that the same key is used all the time
/// and that the request for a variable isn't accidentally misspelled.
List<String> settingKeys = ['controlColors', 'theme'];

ColorSchemes controlColors = ColorSchemes.ECS;
ValueNotifier<Brightness> theme = ValueNotifier<Brightness>(Brightness.dark);

String defaultTitle = 'Craver';
ValueNotifier<String> title = ValueNotifier<String>(defaultTitle);

enum ColorSchemes {
  // The name here will be displayed, so make it look nice
  // (not ecs and craver)
  ECS, //Experiment control system
  Craver,
}

/// This is the core variable of determening whether or not to show a message.
/// If a user has clicked don't show again on a message of a certain type,
/// (for example type NetworkConnectionControlPanel), then this message won't
/// be shown again.
///
/// Another example is if a quick timer attempts to call the server often. What
/// could happen is that many dialogs pop up before the user has time to press
/// 'Don't show again'. Therefore, we disable the message as soon as the message
/// pops up, but then if the user presses 'Okay' instead of 'Don't show again',
/// we reenable the message.
Map<String, bool> showMessage = {};

/// We share this messageContext with all the other pages
/// to show error messages in. This way we are also
/// probably safe to ignore the: "Do not use BuildContexts across async gaps."
/// warning. I think this warning come from that the context we give might no
/// longer be the relative context because of the async. But so long as we
/// always use this context, it should be fine i think.
BuildContext? messageContext;

String userName = 'Not logged in';
String idToken = '';
