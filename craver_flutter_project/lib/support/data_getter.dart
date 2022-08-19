import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'alert.dart';

const server = 'http://lbcraver.cern.ch:80';

final Map<String, String> httpHeaders = {
  HttpHeaders.contentTypeHeader: "application/json",
  "Connection": "keep-alive",
  "Keep-Alive": "timeout=5, max=1000"
};

Future<String?> getServerVersion() async {
  const urlString = '$server/version';
  http.Response? response =
      await _generalGet(urlString, serverErrorType: 'VersionServerError');
  if (response == null) {
    return null;
  }
  return response.body;
}

enum PrometheusCommands {
  up,
  notUp,
  onlyUp,
}

Future<dynamic> getPrometheus(PrometheusCommands command) async {
  String urlString;
  switch (command) {
    case PrometheusCommands.up:
      urlString = '$server/prometheus_query?command=up';
      break;

    case PrometheusCommands.notUp:
      urlString = '$server/prometheus_query?command=up!=1';
      break;

    case PrometheusCommands.onlyUp:
      urlString = '$server/prometheus_query?command=up==1';
      break;
    default:
      throw Exception('Unimplemented prometheus command.');
  }
  http.Response? response =
      await _generalGet(urlString, serverErrorType: 'PrometheusServerError');
  if (response == null) {
    return null;
  }
  return jsonDecode(response.body)['data']['result'];
}

Future<dynamic> getControlPanelStates(List<String> states, context,
    {showError = true}) async {
  final urlString = '$server/control_panel?states=${states.join(',')}';
  http.Response? response =
      await _generalGet(urlString, serverErrorType: 'ControlPanelServerError');
  if (response == null) {
    return null;
  }
  return jsonDecode(response.body);
}

Future<Document?> getLbLogbook({int page = 1, int attempts = 0}) async {
  var urlString = '$server/lblogbook?page=$page';
  http.Response? response =
      await _generalGet(urlString, serverErrorType: 'LbLogbookServerError');
  if (response == null) {
    return null;
  }
  var temp = utf8.decode(response.bodyBytes);
  // I just want everything to be a single class.
  temp = temp.replaceAll('<td class="list2">', '<td class="list1">');
  temp =
      temp.replaceAll('<td class="list2" nowrap>', '<td class="list1" nowrap>');
  return parse(temp);
}

Future<http.Response?> _generalGet(String urlString,
    {int attempts = 0,
    networkErrorType = 'NetworkError',
    serverErrorType = 'ServerError'}) async {
  final url = Uri.parse(urlString);
  final http.Response response;
  try {
    response = await http.get(url, headers: httpHeaders);
  } catch (e) {
    if (attempts > 5) {
      networkError(urlString, e.toString(), networkErrorType);
      return null;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    return _generalGet(urlString, attempts: attempts + 1);
  }
  if (response.statusCode == 200) {
    return response;
  } else {
    serverError(urlString, response, serverErrorType);

    return null;
  }
}
