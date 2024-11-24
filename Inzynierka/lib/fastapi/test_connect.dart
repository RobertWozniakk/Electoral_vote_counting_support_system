import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
class test_connection{
  void fetchData() async {
    final Dio dio = new Dio();
    try {
      var response = await dio.post('http://10.0.2.2:8000/test');
      print(response);
    }
    catch(e) {
      print('error caught: $e');
    };

    final body = jsonEncode({
      'param1': 'value1',
      'param2': 'value2',  // dodaj wszystkie wymagane pola
    });
  }
}

