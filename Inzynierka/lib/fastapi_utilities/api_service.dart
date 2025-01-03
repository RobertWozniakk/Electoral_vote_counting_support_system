import 'package:dio/dio.dart';
import 'package:inzynierka/fastapi_utilities/utilities.dart';
import 'package:inzynierka/fastapi_utilities/ip.dart';

class ApiService {
  static final Dio _dio = Dio();

  static Future<bool> validatePesel(String pesel) async {
    try {
      final response = await _dio.post(
        'http://${Config.ipAddress}/login/$pesel',
      );

      if (response.statusCode == 200) {
        return response.data['valid'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("Błąd w połączeniu: $e");
      return false;
    }
  }

  static Future<String?> generateMask(int candidates) async {
    try {
      final response = await _dio.post(
        'http://${Config.ipAddress}/mask/$candidates',
        data: candidates,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return response.data['mask'];
      }
    } catch (e) {
      print("Błąd podczas generowania maski: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>> getVote(String base64vote) async {
    try {
      final response = await _dio.post(
        'http://${Config.ipAddress}/read',
        data: {
          "img": base64vote,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data.containsKey('name')) {
          String candidate = data['name'];

          if (Utilities.voteCount.containsKey(candidate)) {
            Utilities.voteCount[candidate] = Utilities.voteCount[candidate]! + 1;
            Utilities.voteHistory.add(candidate);
          } else {
            Utilities.voteCount[candidate] = 1;
            Utilities.voteHistory.add(candidate);
          }

          print("Głos na $candidate został dodany. Aktualna liczba: ${Utilities.voteCount[candidate]}");
          return {"status": "success", "candidate": candidate};
        }

        if (data.containsKey('error')) {
          return {"status": "error", "message": data['error']};
        }

        return {"status": "error", "message": "Nieoczekiwany format odpowiedzi"};
      } else {
        print("Błąd: Odpowiedź z serwera nie była sukcesem.");
        return {"status": "error", "message": "Serwer zwrócił błąd"};
      }
    } catch (e) {
      print("Błąd podczas przetwarzania danych: $e");
      return {"status": "error", "message": "Nie udało się połączyć z serwerem"};
    }
  }


  static Future<bool> sendCandidates(List<String> candidates) async {
    try {
      final response = await _dio.post(
        'http://${Config.ipAddress}/add_candidates',
        data: {"candidates": candidates},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        print("Lista kandydatów wysłana pomyślnie: ${response.data}");
        return true;
      } else {
        print("Błąd wysyłania listy kandydatów: ${response.data}");
        return false;
      }
    } catch (e) {
      print("Błąd: $e");
      return false;
    }
  }

}
