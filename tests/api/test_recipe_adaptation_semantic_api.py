import os
import sys
from fastapi import FastAPI
from fastapi.testclient import TestClient
import pytest

sys.path.insert(0, os.path.abspath('.'))

from app.api.recipes_semantic import router as recipes_router, _mock_semantic_recipes_db
from app.api.recipe_adaptation_semantic import router as adapt_router
from app.models.recipe_semantic import Recipe


base_recipe = {
    'recipe_id': '1111-2222',
    'title': 'Cake',
    'description': 'Test cake',
    'ingredients': [
        {
            'id': '1',
            'name': 'Flour',
            'quantity': 2.0,
            'unit': 'cups',
            'category': 'Grain',
            'notes': ''
        },
        {
            'id': '2',
            'name': 'Eggs',
            'quantity': 2,
            'unit': 'pcs',
            'category': 'Dairy',
            'notes': ''
        },
        {
            'id': '3',
            'name': 'Milk',
            'quantity': 1,
            'unit': 'cup',
            'category': 'Dairy',
            'notes': ''
        }
    ],
    'instructions': [
        {
            'id': 'i1',
            'action': 'M\u00e9langer',
            'details': 'M\u00e9langer les \u0153ufs et la farine',
            'time_minutes': 5,
            'safety_warning': None,
            'priority': 'high',
            'ingredients_used': ['1', '2'],
            'utensils_used': ['bowl'],
            'troubleshooting': []
        },
        {
            'id': 'i2',
            'action': 'Cuire au four',
            'details': 'Mettre au four pendant 20 minutes',
            'time_minutes': 20,
            'safety_warning': None,
            'priority': 'medium',
            'ingredients_used': ['1', '2', '3'],
            'utensils_used': ['oven'],
            'troubleshooting': []
        }
    ],
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
    'prep_time_minutes': 5,
    'cook_time_minutes': 20,
    'servings': 2,
    'tags': []
}

@pytest.fixture
def client():
    app = FastAPI()
    app.include_router(recipes_router)
    app.include_router(adapt_router)
    return TestClient(app)

@pytest.fixture(autouse=True)
def clear_db():
    _mock_semantic_recipes_db.clear()
    yield
    _mock_semantic_recipes_db.clear()


def test_no_eggs_adaptation(client):
    sample = Recipe(**base_recipe)
    _mock_semantic_recipes_db.append(sample)
    res = client.post(f"/recipes/{sample.recipe_id}/adapt", json={"constraint": "pas d'oeufs"})
    assert res.status_code == 200
    data = res.json()
    assert data['constraint_applied'] == "pas d'oeufs"
    assert any('banane' in s or 'graines de lin' in s for s in data['suggested_changes_text'])
    assert any('Substitut' in ing['name'] for ing in data['adapted_recipe']['ingredients'])


def test_no_oven_adaptation(client):
    sample = Recipe(**base_recipe)
    _mock_semantic_recipes_db.append(sample)
    res = client.post(f"/recipes/{sample.recipe_id}/adapt", json={"constraint": "pas de four"})
    assert res.status_code == 200
    data = res.json()
    assert data['constraint_applied'] == 'pas de four'
    assert any('po\u00eale' in s for s in data['suggested_changes_text'])
    assert any('po\u00eale' in instr['details'] for instr in data['adapted_recipe']['instructions'])


def test_lactose_free_adaptation(client):
    sample = Recipe(**base_recipe)
    _mock_semantic_recipes_db.append(sample)
    res = client.post(f"/recipes/{sample.recipe_id}/adapt", json={"constraint": "sans lactose"})
    assert res.status_code == 200
    data = res.json()
    assert data['constraint_applied'] == 'sans lactose'
    assert any('sans lactose' in ing['name'] for ing in data['adapted_recipe']['ingredients'])


def test_unknown_constraint(client):
    sample = Recipe(**base_recipe)
    _mock_semantic_recipes_db.append(sample)
    res = client.post(f"/recipes/{sample.recipe_id}/adapt", json={"constraint": "inconnu"})
    assert res.status_code == 400

