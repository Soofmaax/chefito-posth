import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:chefito/screens/recipe_list_screen_semantic.dart';
import 'package:chefito/services/recipe_api_service_semantic.dart';
import 'package:chefito/models/recipe_semantic.dart';

class MockService extends Mock implements RecipeApiServiceSemantic {}

void main() {
  testWidgets('shows loading indicator', (tester) async {
    final service = MockService();
    when(service.fetchRecipes()).thenAnswer((_) async => []);
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeListScreenSemantic(apiService: service),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows recipes when loaded', (tester) async {
    final service = MockService();
    when(service.fetchRecipes()).thenAnswer((_) async => [
          Recipe(
            recipeId: '1',
            title: 'R',
            description: 'D',
            ingredients: [],
            instructions: [],
            variations: [],
            chefGuidance: [],
            aiConversationPrompts: [],
            storageAndReheating: StorageAndReheating(
              refrigeratorStorage:
                  StoragePeriod(duration: 1, instructions: ''),
              freezerStorage: StoragePeriod(duration: 1, instructions: ''),
              reheatingInstructions: '',
            ),
            commonTroubleshooting: [],
            successMetrics: SuccessMetrics(
                visualCues: '',
                textureGoal: '',
                flavorProfile: '',
                aromaIndicators: ''),
            prepTimeMinutes: null,
            cookTimeMinutes: null,
            servings: null,
            tags: [],
          )
        ]);
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeListScreenSemantic(apiService: service),
      ),
    );
    await tester.pump();
    expect(find.text('R'), findsOneWidget);
  });

  testWidgets('shows error message on failure', (tester) async {
    final service = MockService();
    when(service.fetchRecipes()).thenThrow(Exception('fail'));
    await tester.pumpWidget(
      MaterialApp(
        home: RecipeListScreenSemantic(apiService: service),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Failed'), findsOneWidget);
  });

  testWidgets('taps recipe navigates', (tester) async {
    final service = MockService();
    when(service.fetchRecipes()).thenAnswer((_) async => [
          Recipe(
            recipeId: '1',
            title: 'R',
            description: 'D',
            ingredients: [],
            instructions: [],
            variations: [],
            chefGuidance: [],
            aiConversationPrompts: [],
            storageAndReheating: StorageAndReheating(
              refrigeratorStorage:
                  StoragePeriod(duration: 1, instructions: ''),
              freezerStorage: StoragePeriod(duration: 1, instructions: ''),
              reheatingInstructions: '',
            ),
            commonTroubleshooting: [],
            successMetrics: SuccessMetrics(
                visualCues: '',
                textureGoal: '',
                flavorProfile: '',
                aromaIndicators: ''),
            prepTimeMinutes: null,
            cookTimeMinutes: null,
            servings: null,
            tags: [],
          )
        ]);
    final observer = TestNavigatorObserver();
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        routes: {
          '/recipe/1': (_) => const Scaffold(body: Text('detail')),
        },
        home: RecipeListScreenSemantic(apiService: service),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('R'));
    await tester.pumpAndSettle();
    expect(observer.pushedRoutes.contains('/recipe/1'), isTrue);
  });
}

class TestNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route.settings.name ?? '');
    super.didPush(route, previousRoute);
  }
}
