// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:craver/authentication.dart';
import 'package:craver/main.dart';
import 'package:craver/support/control_values_and_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Uh oh I tink i put Craver somewhere where maybe
// there should have been craver_flutter_project, but everything
// still works... so not a problem!
// ignore: depend_on_referenced_packages
import 'package:craver/pages/control_panel.dart';
import 'package:craver/bottom_nav.dart';
import 'moch_server.dart' as mochServer;

void main() {
  //TODO split into multiple tests
  testWidgets('Test the entire app', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // We are now at the login page
    // We are going to try to cheat by getting past
    // the login.
    expect(find.text('Log in'), findsOneWidget);
    print(find.byType(Text).first);
    expect(find.byType(Text), findsNWidgets(2));
    await tester.tap(find.text('Sneak in'));

    // We are now in the control panel

    // Fill the control values with random values
    mochServer.setControlValues('test', 1);
    ControlValues.updater.value += 1;

    // if nothing has crashed, i'm happy
    // Verify that our counter starts at 0.
    //expect(find.text('LHCb: test'), findsOneWidget);
    print(find.byType(Text).first);
    expect(find.byType(Text), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
