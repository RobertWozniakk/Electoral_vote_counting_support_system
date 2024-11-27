import 'package:flutter/material.dart';
import 'package:camera/camera.dart';


class MainScreen extends StatefulWidget {
  final String pesel;

  MainScreen({required this.pesel});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> candidates = []; // String przechowujący listę kandydatów
  final int maxCandidates = 14;
  // Dodawanie kandydatów
  void _addCandidate(String name) {
    if (candidates.length < maxCandidates) {
      setState(() {
        candidates.add(name);
      });
    } else {
      // Wyświetl komunikat, że osiągnięto limit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Osiągnięto maksymalną liczbę kandydatów ($maxCandidates).")),
      );
    }
  }

  // Usuwanie kandydatów
  void _removeCandidate(int index) {
    setState(() {
      candidates.removeAt(index);
    });
  }

  // Funkcja do otwierania dialogu
  void _showAddCandidateDialog() {
    final TextEditingController _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Dodaj kandydata"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Imię i nazwisko"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ekran Główny")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    title: Text(candidates[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeCandidate(index),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Pobierz dostępne kamery
                  final cameras = await availableCameras();

                  // Przejdź do ekranu kamery
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(cameras: cameras),
                    ),
                  );
                },
                child: Text("Przejdź do skanowania kart wyborczych"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ekran kamery
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraScreen({required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        widget.cameras[0], // Wybierz pierwszą dostępną kamerę
        ResolutionPreset.low,
      );
      _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text("Skanuj kartę wyborczą")),
      body: Stack(
        children: [
          CameraPreview(_controller),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final image = await _controller.takePicture();
                    // Tutaj możesz zapisać lub przetworzyć zdjęcie
                    print('Zdjęcie zapisane w: ${image.path}');
                  } catch (e) {
                    print('Błąd: $e');
                  }
                },
                child: Icon(Icons.camera, size: 30),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



