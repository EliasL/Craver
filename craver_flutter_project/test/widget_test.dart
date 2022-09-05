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
import 'moch_server.dart' as mochServer;

void main() {
  group('Craver test', () {
    testWidgets('Test control values', (WidgetTester tester) async {
      // Fill the control values with random values
      mochServer.randomizeControlValues();
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

    testWidgets('Test control panel', (WidgetTester tester) async {
      // Values could have been set by other tests,
      // here we expect null values.
      mochServer.setControlValues(null, null);
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MaterialApp(
        home: ControlPanel(),
      ));

      //Check that we have some buttons
      expect(find.text('LHCb: '), findsWidgets);

      // Fill the control values with random values
      mochServer.setControlValues('test', 1);
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
  });
}
