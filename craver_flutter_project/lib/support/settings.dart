library craver.globals;

import 'package:flutter/cupertino.dart';

const bool DEVELOPMENT = true;
const String VERSION = '0.5'; //This must match SERVER_VERSION on the server
const String FULLVERSION = '$VERSION${DEVELOPMENT ? '-dev' : ''}';
const ColorSchemes COLORSETTING = ColorSchemes.ECSColors;

enum ColorSchemes {
  ECSColors, //Experiment control system
  craverColors,
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

BuildContext? messageContext;
