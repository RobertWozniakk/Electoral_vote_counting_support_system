class Utilities {
  static Map<String, int> voteCount = {};
  static List<String> voteHistory = [];
  static void addManualVote(String candidate) {
    if (candidate == "Głos nieważny") {
      if (voteCount.containsKey("Głos nieważny")) {
        voteCount["Głos nieważny"] = voteCount["Głos nieważny"]! + 1;
        voteHistory.add(candidate);
      } else {
        voteCount["Głos nieważny"] = 1;
        voteHistory.add(candidate);
      }
      print("Głos uznany za nieważny, liczba głosów nieważnych: ${voteCount["Głos nieważny"]}");
      return;
    }

    if (voteCount.containsKey(candidate)) {
      voteCount[candidate] = voteCount[candidate]! + 1;
    } else {
      voteCount[candidate] = 1;
    }
    print("Głos na $candidate został dodany. Aktualna liczba: ${voteCount[candidate]}");
  }

  static void undoLastVote() {
    if (voteHistory.isNotEmpty) {
      String lastVote = voteHistory.removeLast();
      if (voteCount.containsKey(lastVote)) {
        voteCount[lastVote] = voteCount[lastVote]! - 1;
        if (voteCount[lastVote] == 0) {
          voteCount.remove(lastVote);
        }
      }
    }
  }

  static void resetVotes() {
    voteCount.clear();
    voteHistory.clear();
  }
}