// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'dart:math';

import 'package:craver/authentication.dart';
import 'package:craver/bottom_nav.dart';
import 'package:craver/main.dart';
import 'package:craver/pages/help.dart';
import 'package:craver/pages/instances.dart';
import 'package:craver/pages/lb_logbook.dart';
import 'package:craver/pages/preferences.dart';
import 'package:craver/support/alert.dart';
import 'package:craver/support/control_values_and_color.dart';
import 'package:craver/support/settings.dart' as settings;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Maybe this would make a better moch server
// https://blog.logrocket.com/unit-testing-flutter-code-mockito/
import 'package:craver/pages/control_panel.dart';
import 'package:intl/intl_standalone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'moch_server.dart' as moch_server;

void main() {
  group('Craver backend', () {
    testWidgets('Test main', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp());
      // You should be taken to the login page
      await tester.pumpAndSettle();
      expect(find.text('Continue as guest'), findsOneWidget);
    });

    testWidgets('Test bottom_nav', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MaterialApp(
        home: BottomNav(),
      ));
      //We need to stop the timer in order for the test to move on
      ControlPanel.stopTimer();
      // You should be taken to the control panel
      await tester.pump();
      expect(find.text('Logbook'), findsOneWidget);
      await tester.tap(find.text('Logbook'));
      // Because we have a timer when we check the version
      // and we can't check the version, we can't use pump and settle
      //await tester.pumpAndSettle();
      //expect(find.text('Not logged in!'), findsOneWidget);
    });

    testWidgets('Test authentication', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: Authentication(),
      ));
      expect(settings.loggedIn, false);
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Continue as guest'), findsOneWidget);
      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();
      expect(settings.loggedIn, false);
      //?
      //expect(find.text('Status'), findsOneWidget);
    });
  });
  group('Craver pages', () {
    testWidgets('Test control panel', (WidgetTester tester) async {
      // Values could have been set by other tests,
      // here we expect null values.
      moch_server.setControlValues(null, null);
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MaterialApp(
        home: ControlPanel(),
      ));

      //Check that we have some buttons
      expect(find.text('LHCb: '), findsWidgets);

      // Fill the control values with random values
      moch_server.setControlValues('test', 1);
      // Here we update the widget values
      ControlValues.updater.value += 1;
      // Here we tell the tester to update the widgets
      await tester.pump();
      // Now we should find that the button has an updated value
      expect(find.text('LHCb: test'), findsOneWidget);
      // Let's quickly check that the subdetector page also works
      // We swipe to the left
      await tester.drag(find.text('LHCb: test'), const Offset(-500.0, 0.0));
      // Build the widget until the swipe animation ends.
      await tester.pumpAndSettle();
      // Check that the buttons here have also been updated
      expect(find.textContaining('RICH1: test'), findsOneWidget);
    });

    testWidgets('Test help page', (WidgetTester tester) async {
      // Everything in the help page is constant, so just building it is
      // a good test i guess
      await tester.pumpWidget(const MaterialApp(
        home: Help(),
      ));
      expect(find.byType(ElevatedButton), findsNothing);
      await tester.tap(find.text('How to log out'));
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Test instances', (WidgetTester tester) async {
      // Should be expanded
      await tester.pumpWidget(const MaterialApp(
        home: Instances(),
      ));
      expect(find.text('Refresh'), findsOneWidget);
    });
    testWidgets('Test logbook', (WidgetTester tester) async {
      // Should be expanded
      await tester.pumpWidget(const MaterialApp(
        home: LbLogbook(),
      ));
      expect(find.text('Refresh'), findsOneWidget);
    });
    testWidgets('Test preferences', (WidgetTester tester) async {
      // Should be expanded
      await tester.pumpWidget(const MaterialApp(
        home: Preferences(),
      ));

      expect(find.byType(CheckboxListTile), findsNothing);
      await tester.tap(find.text('Control panel color scheme'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
      await tester.tap(find.text('Craver'));
      await tester.pumpAndSettle();
      expect(settings.controlColors, settings.ColorSchemes.Craver);
      await tester.tap(find.text('ECS'));
      await tester.pumpAndSettle();
      expect(settings.controlColors, settings.ColorSchemes.ECS);

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsNWidgets(2 + 2));
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(settings.theme.value, Brightness.light);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(settings.theme.value, Brightness.dark);

      await tester.tap(find.text('Credits'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Elias Lundheim'), findsOneWidget);
    });
  });

  group('Craver support', () {
    testWidgets('Test control values', (WidgetTester tester) async {
      // Fill the control values with random values
      moch_server.randomizeControlValues();
      // If this is okay... then i guess it's all okay
      // I'm not sure exactly what to test here, but
      // just as an example

      // If test fails, the randomizeControlValues function
      // is probably wrong

      for (ControlValue cv in ControlValues.allValues) {
        expect(cv.sValue.runtimeType, String);
        if (cv.type == String) {
          expect(RunStates.values.map((e) => e.name).contains(cv.sValue), true);
        } else {
          expect(double.tryParse(cv.sValue!) != null, true);
        }
      }
    });

    testWidgets('Test alert', (WidgetTester tester) async {
      //Don't trust this test. it's terrible. rewrite
      await tester.pumpWidget(const MaterialApp(
        home: BottomNav(),
      ));
      //We need to stop the timer in order for the test to move on
      ControlPanel.stopTimer();

      // We open a dialog
      showOkayDialog('title', 'test', messageType: 'A');
      await tester.pump();

      expect(find.text('test'), findsOneWidget);
      int number_of_things = tester.allElements.length;
      // Now we don't expect to se another message
      showOkayDialog('title', 'test', messageType: 'A');
      await tester.pump();
      expect(tester.allElements.length, number_of_things);
      // Now we DO expect to see more stuff
      showOkayDialog('title', 'test', messageType: 'B');
      await tester.pump();
      expect(tester.allElements.length != number_of_things, true);
    });

    testWidgets('Test settings', (WidgetTester tester) async {
      // When testing, this DEVELOPMENT should default to true
      expect(settings.DEVELOPMENT, true);
      // You should have a support email
      expect(settings.SUPPORT_EMAIL != '', true);
    });
  });
}
