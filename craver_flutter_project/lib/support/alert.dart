import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'settings.dart' as settings;
import 'data_getter.dart';

void checkVersion() async {
  String? version = await getServerVersion();
  // If version is null, that means that we have already
  // shown the user a network or server error, so no need
  // to show anything else.
  if (version != null && version != settings.VERSION) {
    incorrectVersion(version, settings.VERSION);
  }
}

Future<void> incorrectVersion(serverVersion, localVersion) {
  return showOkayDontShowAgainDialog(
      'Incorrect version!',
      'You are using version: $localVersion, '
          'but the server has been updated to version $serverVersion',
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
