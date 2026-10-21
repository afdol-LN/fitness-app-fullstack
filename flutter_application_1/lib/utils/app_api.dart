
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_application_1/config/app.config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAPI{
  static Future get(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(
      Uri.parse("${AppConfig.apiBaseUrl}$url"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'authorization': 'Bearer ${prefs.getString("access_token")}'
      },
    );

    return response;
  } 


  static Future post(String uri, Map<String, dynamic> body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse("${AppConfig.apiBaseUrl}$uri"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'authorization': 'Bearer ${prefs.getString("access_token")}'
      },
      body: jsonEncode(body),
    );

    return response;
  }
}