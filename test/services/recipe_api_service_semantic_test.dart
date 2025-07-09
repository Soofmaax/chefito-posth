import 'dart:convert';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:chefito/services/recipe_api_service_semantic.dart';
import 'package:chefito/models/recipe_semantic.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('RecipeApiServiceSemantic', () {
    late MockClient client;
    late RecipeApiServiceSemantic service;

    setUp(() {
      client = MockClient();
      service = RecipeApiServiceSemantic(baseUrl: 'http://example.com', client: client);
    });

    test('fetchRecipes returns list on success', () async {
      final sample = [
        {
          'recipe_id': '1',
          'title': 'T',
          'description': 'D',
          'ingredients': [],
          'instructions': [],
          'variations': [],
          'chef_guidance': [],
          'ai_conversation_prompts': [],
          'storage_and_reheating': {
            'refrigerator_storage': {'duration': 1, 'instructions': ''},
            'freezer_storage': {'duration': 1, 'instructions': ''},
            'reheating_instructions': ''
          },
          'common_troubleshooting': [],
          'success_metrics': {
            'visual_cues': '',
            'texture_goal': '',
            'flavor_profile': '',
            'aroma_indicators': ''
          },
          'tags': []
        }
      ];
      when(client.get(Uri.parse('http://example.com/recipes')))
          .thenAnswer((_) async => http.Response(json.encode(sample), 200));

      final recipes = await service.fetchRecipes();
      expect(recipes, hasLength(1));
      expect(recipes.first.title, 'T');
    });

    test('fetchRecipes throws on failure', () async {
      when(client.get(Uri.parse('http://example.com/recipes')))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(service.fetchRecipes(), throwsException);
    });

    test('fetchRecipe returns single recipe', () async {
      final sample = {
        'recipe_id': '1',
        'title': 'T',
        'description': 'D',
        'ingredients': [],
        'instructions': [],
        'variations': [],
        'chef_guidance': [],
        'ai_conversation_prompts': [],
        'storage_and_reheating': {
          'refrigerator_storage': {'duration': 1, 'instructions': ''},
          'freezer_storage': {'duration': 1, 'instructions': ''},
          'reheating_instructions': ''
        },
        'common_troubleshooting': [],
        'success_metrics': {
          'visual_cues': '',
          'texture_goal': '',
          'flavor_profile': '',
          'aroma_indicators': ''
        },
        'tags': []
      };
      when(client.get(Uri.parse('http://example.com/recipes/1')))
          .thenAnswer((_) async => http.Response(json.encode(sample), 200));

      final recipe = await service.fetchRecipe('1');
      expect(recipe.recipeId, '1');
    });

    test('fetchRecipe throws on failure', () async {
      when(client.get(Uri.parse('http://example.com/recipes/1')))
          .thenAnswer((_) async => http.Response('err', 404));

      expect(service.fetchRecipe('1'), throwsException);
    });

    test('adaptRecipe returns response on success', () async {
      final sampleRecipe = {
        'recipe_id': '1',
        'title': 'T',
        'description': 'D',
        'ingredients': [],
        'instructions': [],
        'variations': [],
        'chef_guidance': [],
        'ai_conversation_prompts': [],
        'storage_and_reheating': {
          'refrigerator_storage': {'duration': 1, 'instructions': ''},
          'freezer_storage': {'duration': 1, 'instructions': ''},
          'reheating_instructions': ''
        },
        'common_troubleshooting': [],
        'success_metrics': {
          'visual_cues': '',
          'texture_goal': '',
          'flavor_profile': '',
          'aroma_indicators': ''
        },
        'tags': []
      };
      final resp = {
        'original_recipe_id': '1',
        'constraint_applied': "pas d'oeufs",
        'suggested_changes_text': ['replace eggs'],
        'adapted_recipe': sampleRecipe
      };
      when(client.post(Uri.parse('http://example.com/recipes/1/adapt'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(json.encode(resp), 200));

      final result =
          await service.adaptRecipe('1', "pas d'oeufs");
      expect(result.constraintApplied, "pas d'oeufs");
    });

    test('adaptRecipe throws on failure', () async {
      when(client.post(Uri.parse('http://example.com/recipes/1/adapt'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('err', 500));

      expect(service.adaptRecipe('1', 'c'), throwsException);
    });
  });
}
