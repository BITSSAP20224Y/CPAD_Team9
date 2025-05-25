import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:js/js.dart';
import 'js_bridge.dart';

void main() {

  runApp(const ObjectDetectionApp());
  
}

class ObjectDetectionApp extends StatelessWidget {
  const ObjectDetectionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Object Detection App',
      home: ObjectDetectionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({super.key});
  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  List<dynamic> _predictions = [];
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    flutterInjectPredictions = allowInterop((String jsonResult) {
      final decoded = jsonDecode(jsonResult);
      setState(() {
        _predictions = decoded;
      });
    });
  }

Future<void> _pickImage() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null && result.files.single.bytes != null) {
    Uint8List fileBytes = result.files.single.bytes!;
    final base64Image = 'data:image/png;base64,${base64Encode(fileBytes)}';

    setState(() {
      _imageBytes = fileBytes;
      _predictions = [];
    });

    // Call JS object detection
    runDetectionWithBase64(base64Image);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Object Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageBytes != null) ...[
              const Text("Uploaded Image:"),
              const SizedBox(height: 10),
              Image.memory(_imageBytes!, width: 300),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            const Text('Predictions:'),
            for (var pred in _predictions)
              Text("${pred['class']} - ${((pred['score'] ?? 0) * 100).toStringAsFixed(1)}%"),
          ],
        ),
      ),
    );
  }
}
