import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:inzynierka/fastapi_utilities/api_service.dart';
import 'package:inzynierka/screens/manual_vote_screen.dart';
import 'package:inzynierka/screens/report_screen.dart';
import 'package:flutter/services.dart';
import 'package:inzynierka/fastapi_utilities/utilities.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String mask;
  final List<String> candidates;

  const CameraScreen({
    Key? key,
    required this.cameras,
    required this.mask,
    required this.candidates,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0; // Grubsza ramka

    final double width = size.width * 0.8;
    final double height = width * 1.414;
    final double x = (size.width - width) / 2;
    final double y = (size.height - height) / 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      Radius.circular(10),
    );
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  Image? _maskImage;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.ultraHigh,
      );
      _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      });
    }

    final bytes = base64Decode(widget.mask);
    setState(() {
      _maskImage = Image.memory(bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Nakieruj kwadratami na numer kandydata"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Cofnij Głos':
                  Utilities.undoLastVote(); // Cofnięcie głosu
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Ostatni głos został cofnięty")),
                  );
                  break;
                case 'Resetuj głosowanie':
                  Utilities.resetVotes(); // Resetowanie głosów
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Głosowanie zostało zresetowane")),
                  );
                  break;
                case 'Zakończ głosowanie':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VotingResultsScreen(), // Ekran wyników głosowania
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Cofnij Głos',
                child: Text('Cofnij Głos'),
              ),
              PopupMenuItem<String>(
                value: 'Resetuj głosowanie',
                child: Text('Resetuj głosowanie'),
              ),
              PopupMenuItem<String>(
                value: 'Zakończ głosowanie',
                child: Text('Zakończ głosowanie'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 0.707, // Proporcje A4
              child: CameraPreview(_controller),
            ),
          ),
          if (_maskImage != null)
            Center(
              child: AspectRatio(
                aspectRatio: 0.707, // Proporcje A4
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.2, // Półprzezroczysta maska
                      child: _maskImage,
                    ),
                  ],
                ),
              ),
            ),
          CustomPaint(
            size: Size.infinite,
            painter: BorderPainter(),
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final image = await _controller.takePicture();
                    final file = File(image.path);
                    final bytes = await file.readAsBytes();
                    final base64Image = base64Encode(bytes);

                    final result = await ApiService.getVote(base64Image);

                    if (result['status'] == 'success') {
                      final candidate = result['candidate'];
                      _showVoteSuccessDialog(context, image, candidate);
                    } else {
                      _navigateToManualVote(context, image, image.path);
                    }
                  } catch (e) {
                    print('Błąd: $e');
                  }
                },
                child: Icon(Icons.camera, size: 30),
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(15),
                  elevation: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVoteSuccessDialog(BuildContext context, XFile image, String candidate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sukces"),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(
                    File(image.path),
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.contain,
                ),
                SizedBox(height: 10), // Dodanie odstępu
                Text(
                  "Głos oddany na: $candidate\n"
                      "Aktualna liczba głosów: ${Utilities.voteCount[candidate]}",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToManualVote(context, image, candidate);
                },
                child: Text("Odrzuć wynik"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToManualVote(
      BuildContext context, XFile image, String imagePath) async {
    final manualCandidate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualVoteScreen(
          image: image.path,
          candidates: widget.candidates,
        ),
      ),
    );

    if (manualCandidate != null) {
      if (manualCandidate == "Nieważny") {
        // Obsługuje głos nieważny
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Głos uznany za nieważny")),
        );
      }
      else {
        Utilities.addManualVote(manualCandidate);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Głos ręcznie przypisany na: $manualCandidate")),
        );
      }
    }
  }

}