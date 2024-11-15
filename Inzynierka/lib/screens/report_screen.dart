import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  final String username;

  ReportScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Raport")),
      body: Center(
        child: Text(
          "Raport dla użytkownika: $username",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
