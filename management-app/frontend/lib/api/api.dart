import 'dart:convert';

import 'package:http/http.dart';

import '../model/apps.dart';

void main(List<String> args) {
  getApps();
}

Future<void> activateApp({required String appName}) async {
  final url = Uri.parse('http://localhost:8080/conglobo/apps/$appName');
  final response = await post(url);
}

Future<void> deactivateApp({required String appName}) async {
  final url = Uri.parse('http://localhost:8080/conglobo/apps/$appName');
  final response = await delete(url);
}

Future<Apps> getApps() async {
  final url = Uri.parse('http://localhost:8080/conglobo/apps');
  final response = await get(url);
  final data = Apps.fromJson(jsonDecode(response.body));
  return data;
}
