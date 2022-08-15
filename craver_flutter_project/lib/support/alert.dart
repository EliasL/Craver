import 'dart:ffi';

import 'package:flutter/material.dart';

Future<void> incorrectVersion(context, server_version, local_version) {
  return showMyDialog(
      context,
      'Incorrect version!',
      'You are using version: $local_version, '
          'but the server has been updated to version $server_version');
}

Future<void> showMyDialog(context, title, text) async {
  return showDialog<void>(
    context: context,
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
