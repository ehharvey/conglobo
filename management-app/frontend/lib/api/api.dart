import 'dart:convert';

import 'package:http/http.dart';

import '../model/services.dart';

void main(List<String> args) {
  //getServices();
}

const urlPrefix = 'http://localhost:8000';

Future<void> toggleServiceStatus(
    {required String serviceID, required bool serviceStatus}) async {
  final url = Uri.parse(
      '$urlPrefix/active-service/toggle?title=$serviceID&status=$serviceStatus');
  final headers = {"Content-type": "application/json"};
  final response = await post(url, headers: headers);
  //print(response.body);
}

Future<ServiceStatuses> getServices() async {
  final url = Uri.parse('$urlPrefix/active-service');
  final headers = {"Content-type": "application/json"};
  final response = await get(url, headers: headers);
  final data = ServiceStatuses.fromJson(jsonDecode(response.body));
  return data;
}
