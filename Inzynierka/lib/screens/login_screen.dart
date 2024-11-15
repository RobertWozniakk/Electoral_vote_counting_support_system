import 'package:flutter/material.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logowanie...")),
      );

      await Future.delayed(Duration(seconds: 1)); // Symulacja opóźnienia

      const mockUsername = "testuser";
      const mockPassword = "testpassword";

      if (_usernameController.text == mockUsername &&
          _passwordController.text == mockPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Zalogowano pomyślnie")),
        );

        // Przejdź do MainScreen z nazwą użytkownika
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(username: _usernameController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Niepoprawna nazwa użytkownika lub hasło")),
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
                controller: _usernameController,
                decoration: InputDecoration(labelText: "LOGIN"),
                autocorrect: false,
                enableSuggestions: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Wprowadź nazwę użytkownika";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Hasło"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Wprowadź hasło";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text("Zaloguj się"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
