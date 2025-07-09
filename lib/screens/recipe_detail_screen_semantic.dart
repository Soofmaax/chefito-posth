import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/recipe_api_service_semantic.dart';
import '../models/recipe_semantic.dart';

typedef VibrateCallback = Future<void> Function(int duration);

class RecipeDetailScreenSemantic extends StatefulWidget {
  final RecipeApiServiceSemantic apiService;
  final String recipeId;
  final FlutterTts tts;
  final AudioPlayer audioPlayer;
  final VibrateCallback vibrate;
  final stt.SpeechToText speech;

  RecipeDetailScreenSemantic({
    Key? key,
    required this.apiService,
    required this.recipeId,
    FlutterTts? tts,
    AudioPlayer? audioPlayer,
    VibrateCallback? vibrate,
    stt.SpeechToText? speech,
  })  : tts = tts ?? FlutterTts(),
        audioPlayer = audioPlayer ?? AudioPlayer(),
        vibrate = vibrate ?? ((d) => Vibration.vibrate(duration: d)),
        speech = speech ?? stt.SpeechToText(),
        super(key: key);

  @override
  State<RecipeDetailScreenSemantic> createState() => _RecipeDetailScreenSemanticState();
}

class _RecipeDetailScreenSemanticState extends State<RecipeDetailScreenSemantic> {
  Recipe? _recipe;
  bool _loading = true;
  String? _error;
  int _index = 0;
  late final PageController _pageController;
  late final stt.SpeechToText _speech;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _speech = widget.speech;
    _initSpeech();
    _load();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (_speechAvailable && _speech.hasPermission) {
      await _speech.listen(onResult: _onSpeechResult);
    } else {
      setState(() => _speechAvailable = false);
    }
  }

  Future<void> _load() async {
    try {
      _recipe = await widget.apiService.fetchRecipe(widget.recipeId);
    } catch (_) {
      _error = 'Failed to load recipe';
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _speakCurrent() async {
    await widget.audioPlayer.setAsset('assets/sounds/double_tap.mp3');
    await widget.audioPlayer.play();
    await widget.vibrate(50);
    await widget.tts.speak(_recipe!.instructions[_index].details);
  }

  Future<void> _onPageChanged(int i) async {
    setState(() => _index = i);
    await widget.vibrate(30);
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Liste Ingrédients'),
            onTap: () {
              Navigator.pop(context);
              // placeholder
            },
          ),
          ListTile(
            title: const Text('Conseils'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Dépannage'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Répéter'),
            onTap: () {
              Navigator.pop(context);
              _speakCurrent();
            },
          ),
        ],
      ),
    );
  }

  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    if (result.finalResult) {
      widget.audioPlayer.setAsset('assets/sounds/command.mp3');
      widget.audioPlayer.play();
      widget.vibrate(30);
      _handleCommand(result.recognizedWords.toLowerCase());
      if (_speechAvailable && !_speech.isListening) {
        _speech.listen(onResult: _onSpeechResult);
      }
    }
  }

  void _handleCommand(String command) {
    final recipe = _recipe;
    if (recipe == null) return;
    if (command.contains('étape suivante')) {
      _nextStep();
    } else if (command.contains('étape précédente')) {
      _prevStep();
    } else if (command.contains('répète')) {
      _speakCurrent();
    } else if (command.contains('va') && RegExp(r'étape\s*(\d+)').hasMatch(command)) {
      final m = RegExp(r'étape\s*(\d+)').firstMatch(command);
      if (m != null) _gotoStep(int.parse(m.group(1)!));
    } else if (command.contains("où en suis-je")) {
      _speak('Vous êtes à l\'étape ${_index + 1} sur ${recipe.instructions.length}');
    } else if (command.contains("combien d'étapes restent")) {
      final remain = recipe.instructions.length - _index - 1;
      _speak('Il reste $remain étapes');
    } else if (command.contains('liste des ingrédients')) {
      final names = recipe.ingredients.map((e) => e.name).join(', ');
      _speak(names);
    } else if (command.startsWith('quantité de')) {
      final name = command.replaceFirst('quantité de', '').trim();
      final ing = recipe.ingredients.firstWhere(
        (i) => i.name.toLowerCase() == name,
        orElse: () => Ingredient(
            id: '', name: '', quantity: 0, unit: '', category: '', notes: ''),
      );
      if (ing.id.isNotEmpty) {
        _speak('${ing.quantity} ${ing.unit} de ${ing.name}');
      } else {
        _speak('Ingrédient non trouvé');
      }
    } else if (RegExp(r'ingr[éè]dient.*étape\s*(\d+)').hasMatch(command)) {
      final m = RegExp(r'ingr[éè]dient.*étape\s*(\d+)').firstMatch(command);
      if (m != null) {
        final idx = int.parse(m.group(1)!);
        if (idx >= 1 && idx <= recipe.instructions.length) {
          final ids = recipe.instructions[idx - 1].ingredientsUsed;
          final names = recipe.ingredients
              .where((i) => ids.contains(i.id))
              .map((e) => e.name)
              .join(', ');
          _speak(names.isEmpty ? 'Aucun ingrédient pour cette étape' : names);
        }
      }
    } else if (command.contains('temps de cuisson total')) {
      if (recipe.cookTimeMinutes != null) {
        _speak('${recipe.cookTimeMinutes} minutes');
      }
    } else if (command.contains('combien de temps pour cette étape')) {
      final t = recipe.instructions[_index].timeMinutes;
      _speak(t != null ? '$t minutes' : 'Pas de temps indiqué');
    } else if (command.startsWith('conseil pour')) {
      final q = command.replaceFirst('conseil pour', '').trim();
      final tip = recipe.chefGuidance.firstWhere(
        (g) => g.toLowerCase().contains(q),
        orElse: () => recipe.chefGuidance.isNotEmpty ? recipe.chefGuidance.first : '',
      );
      if (tip.isNotEmpty) _speak(tip);
    } else if (command.startsWith('que faire si')) {
      final q = command.replaceFirst('que faire si', '').trim();
      final t = recipe.commonTroubleshooting.firstWhere(
          (t) => t.problem.toLowerCase().contains(q),
          orElse: () => recipe.commonTroubleshooting.isNotEmpty
              ? recipe.commonTroubleshooting.first
              : TroubleshootingTip(problem: '', solution: '', sensoryCue: ''));
      if (t.solution.isNotEmpty) _speak(t.solution);
    } else if (command.contains("pas d'oeuf") ||
        command.contains("pas d'œuf") ||
        command.contains('sans oeuf') ||
        command.contains('je n\'ai pas d\'oeufs')) {
      _requestAdaptation("pas d'oeufs");
    } else if (command.contains('pas de four') || command.contains('sans four')) {
      _requestAdaptation('pas de four');
    } else if (command.contains('sans lactose') ||
        command.contains('allergique au lactose')) {
      _requestAdaptation('sans lactose');
    }
  }

  Future<void> _speak(String text) async {
    await widget.tts.speak(text);
  }

  void _nextStep() {
    if (_index < _recipe!.instructions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_index > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _gotoStep(int step) {
    if (step >= 1 && step <= _recipe!.instructions.length) {
      _pageController.jumpToPage(step - 1);
    }
  }

  Future<void> _requestAdaptation(String constraint) async {
    await _speak("D'accord, je cherche une adaptation...");
    try {
      final resp =
          await widget.apiService.adaptRecipe(widget.recipeId, constraint);
      await widget.audioPlayer.setAsset('assets/sounds/command.mp3');
      await widget.audioPlayer.play();
      await widget.vibrate(40);
      await _speak(resp.suggestedChangesText.join('. '));
      setState(() {
        _recipe = resp.adaptedRecipe;
        _index = 0;
      });
    } catch (_) {
      await _speak("Erreur lors de l'adaptation");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }
    final recipe = _recipe!;
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: _openMenu,
        child: const Icon(Icons.menu),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ingrédients:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ...recipe.ingredients.map((i) => Text(i.name, style: const TextStyle(fontSize: 18))),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: recipe.instructions.length,
                  itemBuilder: (context, index) {
                    final instr = recipe.instructions[index];
                    return GestureDetector(
                      onDoubleTap: _speakCurrent,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Étape ${index + 1} sur ${recipe.instructions.length}', style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 16),
                            Text(instr.action, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(instr.details, style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              _speech.isListening ? Icons.mic : Icons.mic_off,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
