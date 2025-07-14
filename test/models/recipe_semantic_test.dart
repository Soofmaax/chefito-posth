import 'package:test/test.dart';
import 'package:chefito/models/recipe_semantic.dart';

void main() {
  group('Recipe serialization', () {
    final Map<String, dynamic> recipeJson = {
      'recipe_id': '123e4567-e89b-12d3-a456-426614174000',
      'title': 'Test Recipe',
      'description': 'A simple test recipe',
      'ingredients': [
        {
          'id': '1',
          'name': 'Flour',
          'quantity': 2.0,
          'unit': 'cups',
          'category': 'Grain',
          'notes': 'Use all-purpose flour'
        }
      ],
      'instructions': [
        {
          'id': 'step1',
          'action': 'Mix',
          'details': 'Mix all ingredients',
          'time_minutes': 5,
          'safety_warning': null,
          'priority': 'high',
          'ingredients_used': ['1'],
          'utensils_used': ['bowl'],
          'troubleshooting': [
            {
              'problem': 'Too dry',
              'solution': 'Add water',
              'sensory_cue': 'crumbly'
            }
          ]
        }
      ],
      'variations': ['Add vanilla'],
      'chef_guidance': ['Be gentle'],
      'ai_conversation_prompts': ['How do I mix?'],
      'storage_and_reheating': {
        'refrigerator_storage': {
          'duration': 3,
          'instructions': 'Store covered'
        },
        'freezer_storage': {
          'duration': 1,
          'instructions': 'Freeze tightly'
        },
        'reheating_instructions': 'Microwave for 1 min'
      },
      'common_troubleshooting': [
        {
          'problem': 'Burnt',
          'solution': 'Lower heat',
          'sensory_cue': 'smell'
        }
      ],
      'success_metrics': {
        'visual_cues': 'Golden brown',
        'texture_goal': 'Soft',
        'flavor_profile': 'Sweet',
        'aroma_indicators': 'Pleasant'
      },
      'prep_time_minutes': 10,
      'cook_time_minutes': 20,
      'servings': 4,
      'tags': ['dessert']
    };

    test('fromJson and toJson', () {
      final recipe = Recipe.fromJson(recipeJson);
      expect(recipe.title, equals('Test Recipe'));
      final roundtrip = recipe.toJson();
      expect(roundtrip, equals(recipeJson));
    });
  });
}
