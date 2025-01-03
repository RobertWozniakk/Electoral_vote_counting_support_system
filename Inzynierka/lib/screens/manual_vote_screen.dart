import 'dart:io';
import 'package:flutter/material.dart';

class ManualVoteScreen extends StatelessWidget {
  final String image;
  final List<String> candidates;

  const ManualVoteScreen({
    Key? key,
    required this.image,
    required this.candidates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ręczne przypisanie głosu")),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(image)),
          ),
          Text(
            "Wybierz kandydata:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length + 1,
              itemBuilder: (context, index) {
                if (index == candidates.length) {
                  return ListTile(
                    title: Text("Głos nieważny", style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context, "Głos nieważny"); // Zwracamy "Nieważny" jako opcję
                    },
                  );
                }
                final candidate = candidates[index];
                return ListTile(
                  title: Text(candidate),
                  onTap: () {
                    Navigator.pop(context, candidate);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
