import os
import sys
from fastapi.testclient import TestClient
import pytest

sys.path.insert(0, os.path.abspath('.'))

os.environ["DATABASE_URL"] = "sqlite:///:memory:"
from app.database import Base, engine, SessionLocal
from app.api import create_app
from app.models.recipe_semantic import RecipeDB, Recipe

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
    app = create_app()
    return TestClient(app)

@pytest.fixture(autouse=True)
def prepare_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


def test_get_recipes_pagination(client):
    session = SessionLocal()
    for _ in range(3):
        db_recipe = RecipeDB(
            recipe_id=str(_),
            title="T",
            description="D",
            variations=[],
            chef_guidance=[],
            ai_conversation_prompts=[],
            storage_and_reheating={},
            common_troubleshooting=[],
            success_metrics={},
        )
        session.add(db_recipe)
    session.commit()
    session.close()

    res = client.get('/recipes?skip=1&limit=1')
    assert res.status_code == 200
    assert len(res.json()) == 1


def test_get_recipe_by_id(client):
    session = SessionLocal()
    db_recipe = RecipeDB(
        recipe_id="abc",
        title="T",
        description="D",
        variations=[],
        chef_guidance=[],
        ai_conversation_prompts=[],
        storage_and_reheating={},
        common_troubleshooting=[],
        success_metrics={},
    )
    session.add(db_recipe)
    session.commit()
    session.close()

    res = client.get(f'/recipes/{db_recipe.recipe_id}')
    assert res.status_code == 200
    assert res.json()['recipe_id'] == db_recipe.recipe_id


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
    session = SessionLocal()
    count = session.query(RecipeDB).count()
    session.close()
    assert count == 1


def test_create_recipe_invalid(client):
    payload = valid_recipe.copy()
    payload.pop('recipe_id')
    payload.pop('title')

    res = client.post('/recipes', json=payload)
    assert res.status_code == 422
