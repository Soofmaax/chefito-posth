import os, sys
sys.path.insert(0, os.path.abspath("."))
import pytest
from app.models.recipe_semantic import Recipe, Ingredient, Instruction, TroubleshootingTip, StoragePeriod, StorageAndReheating, SuccessMetrics

valid_recipe = {
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
            'safety_warning': None,
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
}

invalid_recipe = valid_recipe.copy()
invalid_recipe.pop('title')


def test_valid_recipe_parses():
    recipe = Recipe(**valid_recipe)
    assert recipe.title == 'Test Recipe'


def test_invalid_recipe_fails():
    with pytest.raises(Exception):
        Recipe(**invalid_recipe)

