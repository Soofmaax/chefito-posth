import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../services/recipe_api_service_semantic.dart';
import '../models/recognition_result.dart';

class IngredientRecognitionScreen extends StatefulWidget {
  final RecipeApiServiceSemantic apiService;
  final FlutterTts tts;
  final ImagePicker picker;
  const IngredientRecognitionScreen({Key? key, required this.apiService, FlutterTts? tts, ImagePicker? picker})
      : tts = tts ?? const FlutterTts(),
        picker = picker ?? const ImagePicker(),
        super(key: key);

  @override
  State<IngredientRecognitionScreen> createState() => _IngredientRecognitionScreenState();
}

class _IngredientRecognitionScreenState extends State<IngredientRecognitionScreen> {
  RecognitionResponse? _result;
  bool _loading = false;
  String? _error;

  Future<void> _pick() async {
    final XFile? file = await widget.picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resp = await widget.apiService.recognizeIngredients(File(file.path));
      await widget.tts.speak(resp.recognizedItems.map((e) => e.name).join(', '));
      setState(() => _result = resp);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } on NetworkException catch (_) {
      setState(() => _error = 'Problème réseau');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reconnaissance d\'ingrédients')),
      body: Center(
        child: _loading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [CircularProgressIndicator(), Text('Analyse en cours...')],
              )
            : _error != null
                ? Text(_error!)
                : _result == null
                    ? const Text('Prenez une photo pour commencer')
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _result!.recognizedItems
                            .map((e) => Text('${e.name} - ${(e.confidence * 100).toStringAsFixed(0)}%'))
                            .toList(),
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pick,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

