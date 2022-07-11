import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:xml/xml.dart';

const server = 'http://10.128.124.104:8080';

final Map<String, String> httpHeaders = {
  HttpHeaders.contentTypeHeader: "application/json",
  "Connection": "keep-alive",
  "Keep-Alive": "timeout=5, max=1000"
};

Future<dynamic> getPrometheusAllUp() {
  const url = '$server/prometheus_query?command=up';
  return getPrometheus(url);
}

Future<dynamic> getPrometheusNotUp() {
  const url = '$server/prometheus_query?command=up!=1';
  return getPrometheus(url);
}

Future<dynamic> getPrometheusOnlyUp() {
  const url = '$server/prometheus_query?command=up==1';
  return getPrometheus(url);
}

Future<dynamic> getPrometheus(String urlString) async {
  final url = Uri.parse(urlString);
  final http.Response response;
  try {
    response = await http.get(url, headers: httpHeaders);
  } catch (e) {
    return [
      {
        'metric': {'instance': e.toString()},
        'value': [0, 'Please try again']
      }
    ];
  }
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    final D = jsonDecode(response.body); //d is a list of json objects
    return D['data']['result'];
    //return D.map((d) => TimeSeriesSales(d.id, d.value)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}

Future<dynamic> getLbLogbook({int page = 1}) async {
  var urlString = '$server/lblogbook?page=$page';
  final url = Uri.parse(urlString);
  final http.Response response;
  try {
    response = await http.get(url, headers: httpHeaders);
  } catch (e) {
    throw Exception('This really needs to be fixed!');
  }
  if (response.statusCode == 200) {
    var temp = utf8.decode(response.bodyBytes);
    // I just want everything to be a single class.
    temp = temp.replaceAll('<td class="list2">', '<td class="list1">');
    temp = temp.replaceAll(
        '<td class="list2" nowrap>', '<td class="list1" nowrap>');
    return parse(temp);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}
