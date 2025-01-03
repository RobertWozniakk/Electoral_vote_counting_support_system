import 'camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import '../fastapi_utilities/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String pesel;

  MainScreen({required this.pesel});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> candidates = [];
  final int maxCandidates = 14;
  final int maxConfigurations = 4;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedOption = "Dodaj kandydatów";
  Map<String, List<String>> savedConfigurations = {};

  @override
  void initState() {
    super.initState();
    _loadSavedConfigurations();
  }
  void _addCandidate(String name) {
    if (candidates.length < maxCandidates) {
      setState(() {
        candidates.add(name);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Osiągnięto maksymalną liczbę kandydatów ($maxCandidates).")),
      );
    }
  }

  void _removeCandidate(int index) {
    setState(() {
      candidates.removeAt(index);
    });
  }

  Future<void> _saveCurrentConfiguration(String configName) async {
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nie można zapisać pustej listy kandydatów.")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (savedConfigurations.length >= maxConfigurations) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Możesz zapisać jednocześnie do 4 konfiguracji.")),
      );
      return;
    }

    savedConfigurations[configName] = List.from(candidates);
    await prefs.setStringList("config_$configName", candidates);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Konfiguracja '$configName' zapisana pomyślnie.")),
    );
  }

  Future<void> _loadConfiguration(String configName) async {
    if (savedConfigurations.containsKey(configName)) {
      setState(() {
        candidates.clear();
        candidates.addAll(savedConfigurations[configName]!);
        _selectedOption = "Dodaj kandydatów";
      });
    }
  }

  Future<void> _loadSavedConfigurations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith("config_")) {
        String configName = key.replaceFirst("config_","");
        List<String>? candidateList = prefs.getStringList(key);
        if (candidateList != null) {
          savedConfigurations[configName] = candidateList;
        }
      }
    }
    setState(() {});
  }

  Future<void> _deleteConfiguration(String configName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedConfigurations.remove(configName);
    await prefs.remove("config_$configName");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Konfiguracja '$configName' została usunięta."))
    );
    setState(() {});
  }
  // Funkcja do otwierania dialogu
  void _showAddCandidateDialog() {
    _nameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Dodaj kandydata"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Imię i nazwisko"),
            keyboardType: TextInputType.text,
            enableSuggestions: false,
            autocorrect: false,
            enableInteractiveSelection: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zĄąĆćĘęŁłŃńÓóŚśŹźŻż\s-]')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij dialog
              },
              child: Text("Anuluj"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _addCandidate(_nameController.text); // Dodaj kandydata
                  Navigator.of(context).pop(); // Zamknij dialog
                }
              },
              child: Text("Dodaj"),
            ),
          ],
        );
      },
    );
  }
  void _showSaveConfigurationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _configNameController = TextEditingController();
        return AlertDialog(
          title: Text("Podaj nazwę konfiguracji"),
          content: TextField(
            controller: _configNameController,
            decoration: InputDecoration(labelText: "Nazwa konfiguracji"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Anuluj"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_configNameController.text.isNotEmpty) {
                  _saveCurrentConfiguration(_configNameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Zapisz"),
            ),
          ],
        );
      },
    );
  }
  Future<void> _navigateToCameraScreen() async {
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dodaj co najmniej jednego kandydata przed przejściem do kamery!")),
      );
      return;
    }
    bool success = await ApiService.sendCandidates(candidates);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd wysyłania listy kandydatów na backend.")),
      );
      return;
    }
    String? mask = await ApiService.generateMask(candidates.length);
    if (mask != null) {
      final cameras = await availableCameras().catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nie udało się uzyskać dostępu do kamery.")),
        );
        return null;
      });

      if (cameras != null && cameras.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(
              mask: mask,
              candidates: candidates,
              cameras: cameras,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd podczas generowania maski.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ekran Główny"),
        actions: [
          DropdownButton<String>(
            value: _selectedOption,
            onChanged: (String? newValue) {
              setState(() {
                _selectedOption = newValue;
              });
            },
            items: <String>[
              "Dodaj kandydatów",
              "Zapisane konfiguracje",
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedOption == "Dodaj kandydatów") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Witaj, ${widget.pesel}, wprowadź dane kandydatów.",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showAddCandidateDialog,
            child: Text("Dodaj kandydata"),
          ),
          SizedBox(height: 20),
          Text(
            "Lista kandydatów:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${index+1}. ${candidates[index]}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCandidate(index),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _showSaveConfigurationDialog,
                child: Text("Zapisz", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              ),
              ElevatedButton(
                onPressed: _navigateToCameraScreen,
                child: Text("Skanuj", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      );
    } else if (_selectedOption == "Zapisane konfiguracje") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Zapisane konfiguracje:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: savedConfigurations.keys.length,
              itemBuilder: (context, index) {
                String configName = savedConfigurations.keys.elementAt(index);
                return ListTile(
                  title: Text(configName),
                  subtitle: Text(savedConfigurations[configName]!.join(", ")),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _deleteConfiguration(configName),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                      IconButton(
                        onPressed: () => _loadConfiguration(configName),
                        icon: Icon(Icons.upload, color: Colors.green),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Text("Wybierz opcję z menu."),
      );
    }
  }
}





