import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'fastapi/test_connect.dart';

void main() {
  test_connection T=new test_connection();
  T.fetchData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikacja do Głosowania',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
