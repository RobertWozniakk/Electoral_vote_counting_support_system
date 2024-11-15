import 'package:flutter/material.dart';
import 'report_screen.dart';

class MainScreen extends StatelessWidget {
  final String username;

  MainScreen({required this.username});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ekran Główny")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Witaj, $username!",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportScreen(username: username),
                  ),
                );
              },
              child: Text("Generuj Raport"),
            ),
          ],
        ),
      ),
    );
  }
}


