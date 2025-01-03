import 'package:flutter/material.dart';
import 'package:inzynierka/fastapi_utilities/utilities.dart';

class VotingResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, int> voteResults = Utilities.voteCount;

    return Scaffold(
      appBar: AppBar(
        title: Text("Wyniki głosowania"),
      ),
      body: ListView.builder(
        itemCount: voteResults.length,
        itemBuilder: (context, index) {
          final candidate = voteResults.keys.elementAt(index);
          final votes = voteResults[candidate];
          return ListTile(
            title: Text(candidate),
            trailing: Text("$votes głosów"),
          );
        },
      ),
    );
  }
}