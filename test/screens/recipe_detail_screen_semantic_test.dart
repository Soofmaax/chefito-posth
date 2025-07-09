import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:chefito/screens/recipe_detail_screen_semantic.dart';
import 'package:chefito/services/recipe_api_service_semantic.dart';
import 'package:chefito/models/recipe_semantic.dart';

class MockService extends Mock implements RecipeApiServiceSemantic {}
class MockTts extends Mock implements FlutterTts {}
class MockAudio extends Mock implements AudioPlayer {}
class MockSpeech extends Mock implements stt.SpeechToText {}

Recipe sampleRecipe() => Recipe(
      recipeId: '1',
      title: 'R',
      description: 'D',
      ingredients: [
        Ingredient(id: 'i1', name: 'ing', quantity: 1, unit: 'u', category: 'c', notes: '')
      ],
      instructions: [
        Instruction(
          id: 's1',
          action: 'A1',
          details: 'D1',
          timeMinutes: null,
          safetyWarning: null,
          priority: 'high',
          ingredientsUsed: [],
          utensilsUsed: [],
          troubleshooting: [],
        ),
        Instruction(
          id: 's2',
          action: 'A2',
          details: 'D2',
          timeMinutes: null,
          safetyWarning: null,
          priority: 'high',
          ingredientsUsed: [],
          utensilsUsed: [],
          troubleshooting: [],
        ),
      ],
      variations: [],
      chefGuidance: ['utilise un fouet'],
      aiConversationPrompts: [],
      storageAndReheating: StorageAndReheating(
        refrigeratorStorage: StoragePeriod(duration: 1, instructions: ''),
        freezerStorage: StoragePeriod(duration: 1, instructions: ''),
        reheatingInstructions: '',
      ),
      commonTroubleshooting: [
        TroubleshootingTip(problem: 'pate colle', solution: 'ajouter farine', sensoryCue: '')
      ],
      successMetrics: SuccessMetrics(
          visualCues: '', textureGoal: '', flavorProfile: '', aromaIndicators: ''),
      prepTimeMinutes: null,
      cookTimeMinutes: null,
      servings: null,
      tags: [],
    );

void main() {
  testWidgets('shows loading indicator', (tester) async {
    final service = MockService();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(apiService: service, recipeId: '1'),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows recipe when loaded', (tester) async {
    final service = MockService();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(apiService: service, recipeId: '1'),
    ));
    await tester.pump();
    expect(find.text('R'), findsOneWidget);
    expect(find.textContaining('Étape 1'), findsOneWidget);
  });

  testWidgets('swipe navigates between instructions and vibrates', (tester) async {
    final service = MockService();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    bool vibrated = false;
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        vibrate: (d) async {
          vibrated = true;
        },
      ),
    ));
    await tester.pump();
    expect(find.text('A1'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('A2'), findsOneWidget);
    expect(vibrated, isTrue);
  });

  testWidgets('double tap speaks instruction', (tester) async {
    final service = MockService();
    final tts = MockTts();
    final audio = MockAudio();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        tts: tts,
        audioPlayer: audio,
        vibrate: (_) async {},
      ),
    ));
    await tester.pump();
    final gesture = await tester.startGesture(tester.getCenter(find.byType(GestureDetector)));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.down(tester.getCenter(find.byType(GestureDetector)));
    await gesture.up();
    await tester.pump();
    verify(tts.speak('D1')).called(1);
    verify(audio.play()).called(1);
  });

  testWidgets('shows error message on failure', (tester) async {
    final service = MockService();
    when(service.fetchRecipe('1')).thenThrow(Exception('fail'));
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(apiService: service, recipeId: '1'),
    ));
    await tester.pump();
    expect(find.textContaining('Failed'), findsOneWidget);
  });

  testWidgets('floating button opens menu', (tester) async {
    final service = MockService();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(apiService: service, recipeId: '1'),
    ));
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Liste Ingrédients'), findsOneWidget);
  });

  testWidgets('speech service initializes', (tester) async {
    final service = MockService();
    final speech = MockSpeech();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    when(speech.initialize()).thenAnswer((_) async => true);
    when(speech.listen(onResult: anyNamed('onResult'))).thenAnswer((_) async => true);
    when(speech.hasPermission).thenReturn(true);
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        speech: speech,
      ),
    ));
    await tester.pump();
    verify(speech.initialize()).called(1);
    verify(speech.listen(onResult: anyNamed('onResult'))).called(1);
  });

  testWidgets('voice command next step', (tester) async {
    final service = MockService();
    final speech = MockSpeech();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    when(speech.initialize()).thenAnswer((_) async => true);
    late void Function(stt.SpeechRecognitionResult) onResult;
    when(speech.listen(onResult: anyNamed('onResult'))).thenAnswer((invocation) async {
      onResult = invocation.namedArguments[#onResult] as void Function(stt.SpeechRecognitionResult);
      return true;
    });
    when(speech.hasPermission).thenReturn(true);
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        speech: speech,
        vibrate: (_) async {},
      ),
    ));
    await tester.pump();
    expect(find.text('A1'), findsOneWidget);
    onResult(stt.SpeechRecognitionResult('étape suivante', true));
    await tester.pumpAndSettle();
    expect(find.text('A2'), findsOneWidget);
  });

  testWidgets('voice command ingredient quantity', (tester) async {
    final service = MockService();
    final speech = MockSpeech();
    final tts = MockTts();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    when(speech.initialize()).thenAnswer((_) async => true);
    late void Function(stt.SpeechRecognitionResult) onResult;
    when(speech.listen(onResult: anyNamed('onResult'))).thenAnswer((invocation) async {
      onResult = invocation.namedArguments[#onResult] as void Function(stt.SpeechRecognitionResult);
      return true;
    });
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        speech: speech,
        tts: tts,
        vibrate: (_) async {},
      ),
    ));
    await tester.pump();
    onResult(stt.SpeechRecognitionResult('quantité de ing', true));
    await tester.pump();
    verify(tts.speak('1 u de ing')).called(1);
  });

  testWidgets('voice command goto step', (tester) async {
    final service = MockService();
    final speech = MockSpeech();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    when(speech.initialize()).thenAnswer((_) async => true);
    late void Function(stt.SpeechRecognitionResult) onResult;
    when(speech.listen(onResult: anyNamed('onResult'))).thenAnswer((invocation) async {
      onResult = invocation.namedArguments[#onResult] as void Function(stt.SpeechRecognitionResult);
      return true;
    });
    when(speech.hasPermission).thenReturn(true);
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        speech: speech,
        vibrate: (_) async {},
      ),
    ));
    await tester.pump();
    onResult(stt.SpeechRecognitionResult("va à l'étape 2", true));
    await tester.pumpAndSettle();
    expect(find.text('A2'), findsOneWidget);
  });

  testWidgets('voice command troubleshooting tip', (tester) async {
    final service = MockService();
    final speech = MockSpeech();
    final tts = MockTts();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    when(speech.initialize()).thenAnswer((_) async => true);
    late void Function(stt.SpeechRecognitionResult) onResult;
    when(speech.listen(onResult: anyNamed('onResult'))).thenAnswer((invocation) async {
      onResult = invocation.namedArguments[#onResult] as void Function(stt.SpeechRecognitionResult);
      return true;
    });
    when(speech.hasPermission).thenReturn(true);
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        speech: speech,
        tts: tts,
        vibrate: (_) async {},
      ),
    ));
    await tester.pump();
    onResult(stt.SpeechRecognitionResult('que faire si pate colle', true));
    await tester.pump();
    verify(tts.speak('ajouter farine')).called(1);
  });

  testWidgets('voice command adaptation success', (tester) async {
    final service = MockService();
    final speech = MockSpeech();
    final tts = MockTts();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    when(service.adaptRecipe('1', "pas d'oeufs")).thenAnswer((_) async =>
        AdaptedRecipeResponse(
            originalRecipeId: '1',
            constraintApplied: "pas d'oeufs",
            suggestedChangesText: ['ok'],
            adaptedRecipe: sampleRecipe()));
    when(speech.initialize()).thenAnswer((_) async => true);
    late void Function(stt.SpeechRecognitionResult) onResult;
    when(speech.listen(onResult: anyNamed('onResult'))).thenAnswer((invocation)
        async {
      onResult =
          invocation.namedArguments[#onResult] as void Function(stt.SpeechRecognitionResult);
      return true;
    });
    when(speech.hasPermission).thenReturn(true);
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        speech: speech,
        tts: tts,
        vibrate: (_) async {},
      ),
    ));
    await tester.pump();
    onResult(stt.SpeechRecognitionResult("je n'ai pas d'oeufs", true));
    await tester.pumpAndSettle();
    verify(service.adaptRecipe('1', "pas d'oeufs")).called(1);
    verify(tts.speak(contains('ok'))).called(1);
  });

  testWidgets('voice command adaptation failure', (tester) async {
    final service = MockService();
    final speech = MockSpeech();
    final tts = MockTts();
    when(service.fetchRecipe('1')).thenAnswer((_) async => sampleRecipe());
    when(service.adaptRecipe('1', 'pas de four'))
        .thenThrow(Exception('fail'));
    when(speech.initialize()).thenAnswer((_) async => true);
    late void Function(stt.SpeechRecognitionResult) onResult;
    when(speech.listen(onResult: anyNamed('onResult'))).thenAnswer((invocation)
        async {
      onResult =
          invocation.namedArguments[#onResult] as void Function(stt.SpeechRecognitionResult);
      return true;
    });
    when(speech.hasPermission).thenReturn(true);
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailScreenSemantic(
        apiService: service,
        recipeId: '1',
        speech: speech,
        tts: tts,
        vibrate: (_) async {},
      ),
    ));
    await tester.pump();
    onResult(stt.SpeechRecognitionResult('pas de four', true));
    await tester.pump();
    verify(tts.speak(contains('Erreur'))).called(1);
  });
}
