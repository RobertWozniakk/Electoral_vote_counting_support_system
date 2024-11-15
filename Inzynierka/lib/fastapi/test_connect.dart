import 'package:http/http.dart' as http;
import 'dart:convert';
class test_connection{
  void fetchData() async {
    final url = Uri.parse('http://10.0.2.2:8000/test'); // dla Androida emulatora
    // Dla iOS (emulator): Uri.parse('http://localhost:8000/api/data');
    // Dla urządzenia fizycznego: Uri.parse('http://192.168.x.x:8000/api/data');
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'param1': 'value1',
      'param2': 'value2',  // dodaj wszystkie wymagane pola
    });

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("Data: $data");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception caught: $e");
    }
  }
}

