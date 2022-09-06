import 'package:html/dom.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'alert.dart';
import 'settings.dart' as settings;

const server = settings.DEVELOPMENT
    ? 'http://lbcraver-dev.cern.ch:80'
    : 'http://lbcraver.cern.ch:80';
//Local server for debuging
//const server = 'http://10.128.124.104:8080';

// We use a getter just so that we don't update the token
// without updating the header. Should maybe only update
// when the token updates, but it's almost friday.
Map<String, String> get httpHeaders => {
      HttpHeaders.contentTypeHeader: "application/json",
      "Connection": "keep-alive",
      "Keep-Alive": "timeout=5, max=1000",
      //Don't ask me about the Bearer
      "Authorization": "Bearer ${settings.idToken}",
    };

Future<String?> getServerVersions() async {
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

Future<List?> getPrometheus(PrometheusCommands command) async {
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
  return jsonDecode(response.body)['data']['result'] as List;
}

Future<dynamic> getControlPanelStates(List<String> states,
    {showError = true}) async {
  final urlString = '$server/control_panel?states=${states.join(',')}';
  http.Response? response =
      await _generalGet(urlString, serverErrorType: 'ControlPanelServerError');
  if (response == null) {
    return null;
  }
  try {
    return jsonDecode(response.body);
  } catch (e) {
    // We assume that the response here is something like
    // Not allowed state: {state}
    customServerError(
        'Error: ${response.body}\n\nSomeone needs to update the server.',
        'Not allowed command');
    return null;
  }
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
    String networkErrorType = 'NetworkError',
    String serverErrorType = 'ServerError'}) async {
  final url = Uri.parse(urlString);
  final http.Response response;
  try {
    response = await http.get(url, headers: httpHeaders);
  } catch (e) {
    if (attempts > 5) {
      defaultNetworkError(urlString, e.toString(), networkErrorType);
      return null;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    return _generalGet(urlString, attempts: attempts + 1);
  }
  if (response.statusCode == 200) {
    return response;
  } else if (response.statusCode == 401) {
    customServerError(
        'Authorization Error\nTry logging in again.', 'Authorization Error');
  } else {
    defaultServerError(urlString, response, serverErrorType);

    return null;
  }
}
