import os
import sys
from fastapi import FastAPI
from fastapi.testclient import TestClient
import pytest

sys.path.insert(0, os.path.abspath('.'))

from app.api.recipes_semantic import router, _mock_semantic_recipes_db
from app.models.recipe_semantic import Recipe

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

@pytest.fixture
def client():
    app = FastAPI()
    app.include_router(router)
    return TestClient(app)

@pytest.fixture(autouse=True)
def clear_db():
    _mock_semantic_recipes_db.clear()
    yield
    _mock_semantic_recipes_db.clear()


def test_get_recipes_pagination(client):
    sample = Recipe(**valid_recipe)
    _mock_semantic_recipes_db.extend([sample, sample, sample])

    res = client.get('/recipes?skip=1&limit=1')
    assert res.status_code == 200
    assert len(res.json()) == 1


def test_get_recipe_by_id(client):
    sample = Recipe(**valid_recipe)
    _mock_semantic_recipes_db.append(sample)

    res = client.get(f'/recipes/{sample.recipe_id}')
    assert res.status_code == 200
    assert res.json()['recipe_id'] == sample.recipe_id


def test_get_recipe_not_found(client):
    res = client.get('/recipes/nonexistent')
    assert res.status_code == 404


def test_create_recipe(client):
    payload = valid_recipe.copy()
    payload.pop('recipe_id')

    res = client.post('/recipes', json=payload)
    assert res.status_code == 201
    data = res.json()
    assert data['recipe_id']
    assert len(_mock_semantic_recipes_db) == 1


def test_create_recipe_invalid(client):
    payload = valid_recipe.copy()
    payload.pop('recipe_id')
    payload.pop('title')

    res = client.post('/recipes', json=payload)
    assert res.status_code == 422
