from typing import List, Optional
from pydantic import BaseModel

from fastapi import APIRouter, HTTPException
from uuid import uuid4

from app.models.recipe_semantic import (
    Recipe,
    Ingredient,
    Instruction,
    TroubleshootingTip,
    StorageAndReheating,
    SuccessMetrics,
)

router = APIRouter()

# Simulated MongoDB collection
_mock_semantic_recipes_db: List[Recipe] = []


class RecipeCreate(BaseModel):
    title: str
    description: str
    ingredients: List[Ingredient]
    instructions: List[Instruction]
    variations: List[str]
    chef_guidance: List[str]
    ai_conversation_prompts: List[str]
    storage_and_reheating: StorageAndReheating
    common_troubleshooting: List[TroubleshootingTip]
    success_metrics: SuccessMetrics
    prep_time_minutes: Optional[int] = None
    cook_time_minutes: Optional[int] = None
    servings: Optional[int] = None
    tags: List[str]


@router.get("/recipes", response_model=List[Recipe])
def list_recipes(skip: int = 0, limit: int = 10):
    return _mock_semantic_recipes_db[skip : skip + limit]


@router.get("/recipes/{recipe_id}", response_model=Recipe)
def get_recipe(recipe_id: str):
    for recipe in _mock_semantic_recipes_db:
        if recipe.recipe_id == recipe_id:
            return recipe
    raise HTTPException(status_code=404, detail="Recipe not found")


@router.post("/recipes", response_model=Recipe, status_code=201)
def create_recipe(recipe_in: RecipeCreate):
    new_recipe = Recipe(recipe_id=str(uuid4()), **recipe_in.dict())
    _mock_semantic_recipes_db.append(new_recipe)
    return new_recipe
