/// This file will provide data that mimics data we might get from the server.
/// This allows us to test functions without needing to use the real server.
///

import 'dart:io';
import 'dart:math';
import 'package:craver/support/control_values_and_color.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'dart:convert';

// generates a new Random object
final r = new Random();

void randomizeControlValues() {
  double maxNumValue = 1e12;
  for (ControlValue cv in ControlValues.allValues) {
    if (cv.type == String) {
      cv.sValue = RunStates.values[r.nextInt(RunStates.values.length)].name;
    } else {
      cv.sValue = (r.nextDouble() * maxNumValue).toString();
    }
  }
}

void setControlValues(String sValue, double numValue) {
  double maxNumValue = 1e12;
  for (ControlValue cv in ControlValues.allValues) {
    if (cv.type == String) {
      cv.sValue = sValue;
    } else {
      cv.sValue = numValue.toString();
    }
  }
}

Future<Document> getLogbookPage() async {
  File f = File('logbookPage.rdf'); // maybe move this into a getter

  String temp = await f.readAsString();
  // I just want everything to be a single class.
  temp = temp.replaceAll('<td class="list2">', '<td class="list1">');
  temp =
      temp.replaceAll('<td class="list2" nowrap>', '<td class="list1" nowrap>');
  return parse(temp);
}
