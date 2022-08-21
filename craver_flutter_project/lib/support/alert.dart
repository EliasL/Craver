import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'settings.dart' as settings;
import 'data_getter.dart';

void checkVersion() async {
  String? versions = await getServerVersion();
  // If version is null, that means that we have already
  // shown the user a network or server error, so no need
  // to show anything else.
  if (versions != null && !versions.split(',').contains(settings.VERSION)) {
    incorrectVersion(versions, settings.VERSION);
  }
}

Future<void> incorrectVersion(String serverVersions, String localVersion) {
  // We make the versions into a nice string
  String niceString = 'version';
  List<String> s1 = serverVersions.split(',');
  if (s1.length > 1) {
    niceString +=
        's ${serverVersions.replaceAll(',', ', ').replaceAll(', ${s1.last}', 'and ${s1.last}')}.';
  } else {
    niceString += ' ${s1[0]}';
  }
  // and then we show it
  return showOkayDontShowAgainDialog(
      'Incorrect version!',
      'You are using version: $localVersion, '
          'but the server is only compatible with $niceString',
      'VersionCheck');
}

Future<void> networkError(String url, error, networkErrorType) {
  return showOkayDontShowAgainDialog(
      'Network Error!', 'Unable to connect to: $url\n$error', networkErrorType);
}

Future<void> serverError(String url, http.Response response, serverErrorType) {
  return showOkayDontShowAgainDialog(
      'Server Error!',
      'Unable to connect to: $url\n'
          'Status code: ${response.statusCode}\n'
          'Reason : ${response.reasonPhrase}',
      serverErrorType);
}

Future<void> showOkayDialog(title, text) async {
  //Flutter needs to know what context to show the message in
  if (settings.messageContext == null) {
    throw Exception('Message context must be set in order to show message!');
  }
  return showDialog<void>(
    context: settings.messageContext!,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(text),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showOkayDontShowAgainDialog(title, text, messageType) async {
  //Flutter needs to know what context to show the message in
  if (settings.messageContext == null) {
    throw Exception('Message context must be set in order to show message!');
  }
  if (settings.showMessage[messageType] ?? true) {
    // We dissable this message in case another one wants to be shown
    // before the user has had time to respond
    settings.showMessage[messageType] = false;
  } else {
    return;
  }

  return showDialog<void>(
    context: settings.messageContext!,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SelectableText(text),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Don't show again"),
            onPressed: () {
              // the message is already dissabled so no need for the line below
              // settings.showMessage[messageType] = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              settings.showMessage[messageType] = true;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
