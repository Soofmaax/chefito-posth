import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:chefito/screens/ingredient_recognition_screen.dart';
import 'package:chefito/services/recipe_api_service_semantic.dart';
import 'package:chefito/models/recognition_result.dart';

class MockService extends Mock implements RecipeApiServiceSemantic {}
class MockPicker extends Mock implements ImagePicker {}
class MockTts extends Mock implements FlutterTts {}

void main() {
  testWidgets('shows results after recognition', (tester) async {
    final service = MockService();
    final picker = MockPicker();
    final tts = MockTts();
    when(picker.pickImage(source: ImageSource.camera)).thenAnswer((_) async =>
        XFile('test.png'));
    when(service.recognizeIngredients(any)).thenAnswer((_) async =>
        RecognitionResponse(recognizedItems: [
          RecognizedItem(
              name: 'tomate',
              confidence: 0.8,
              visualDescription: 'rouge',
              tactileDescription: 'lisse',
              olfactoryDescription: 'sucree')
        ]));
    await tester.pumpWidget(MaterialApp(
      home: IngredientRecognitionScreen(
        apiService: service,
        tts: tts,
        picker: picker,
      ),
    ));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    verify(tts.speak('tomate')).called(1);
    await tester.pump();
    expect(find.textContaining('tomate'), findsOneWidget);
  });

  testWidgets('shows error on failure', (tester) async {
    final service = MockService();
    final picker = MockPicker();
    when(picker.pickImage(source: ImageSource.camera)).thenAnswer((_) async =>
        XFile('test.png'));
    when(service.recognizeIngredients(any)).thenThrow(ApiException('fail'));
    await tester.pumpWidget(MaterialApp(
      home: IngredientRecognitionScreen(apiService: service, picker: picker),
    ));
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('fail'), findsOneWidget);
  });
}
