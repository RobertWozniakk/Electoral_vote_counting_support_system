import 'dart:convert'; // Do kodowania/odkodowywania base64
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio();

  static Future<bool> validatePesel(String pesel) async {
    try {
      final response = await _dio.post(
        'http://10.0.2.2:8000/login/$pesel', // Używaj localhosta dla emulatora
      );

      if (response.statusCode == 200) {
        // Zwróć wartość 'valid' z odpowiedzi API
        return response.data['valid'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("Błąd w połączeniu: $e");
      return false;
    }
  }

  // Wysyłanie listy kandydatów i odbieranie wygenerowanej maski
  static Future<String?> generateMask(int candidates) async {
    try {
      final response = await _dio.post(
        'http://10.0.2.2:8000/mask',
        data: candidates,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return response.data['mask']; // Zwróć maskę w formacie base64
      }
    } catch (e) {
      print("Błąd podczas generowania maski: $e");
    }
    return null;
  }
}
