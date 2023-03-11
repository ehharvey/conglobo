import 'dart:convert';

import 'package:http/http.dart';

import '../model/services.dart';

void main(List<String> args) {
  getServices();
}

Future<void> toggleServiceStatus(
    {required String serviceName, required bool serviceStatus}) async {
  final url = Uri.parse(
      '/active-service/toggle?title=$serviceName&status=$serviceStatus');
  final headers = {"Content-type": "application/json"};
  final response = await post(url, headers: headers);
  //print(response.body);
}

Future<Services> getServices() async {
  final url = Uri.parse('/active-service');
  final headers = {"Content-type": "application/json"};
  final response = await get(url, headers: headers);
  final data = Services.fromJson(jsonDecode(response.body));
  print(data.services['Masodon Social Platform']!.description);
  return data;
}
