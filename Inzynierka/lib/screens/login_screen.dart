import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fastapi/api_service.dart';  // Zaimportuj ApiService do sprawdzania PESEL
import 'main_screen.dart';  // Przekierowanie po poprawnym PESEL

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peselController = TextEditingController();

  // Funkcja do walidacji PESEL
  void _validatePesel() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sprawdzanie PESEL...")),
      );

      // Użycie ApiService do walidacji PESEL
      final isValid = await ApiService.validatePesel(_peselController.text);

      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PESEL jest poprawny!")),
        );
        // Przejdź na kolejny ekran (MainScreen)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(pesel: _peselController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PESEL jest niepoprawny.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Logowanie")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _peselController,
                decoration: InputDecoration(labelText: "PESEL"),
                maxLength: 11,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Pozwól tylko na cyfry
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Wprowadź numer PESEL";
                  }
                  if (value.length != 11) {
                    return "PESEL musi mieć 11 znaków";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validatePesel,
                child: Text("Sprawdź PESEL"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
