from typing import List
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.models.recipe_semantic import Recipe
from app.api.recipes_semantic import _mock_semantic_recipes_db

router = APIRouter()

class AdaptationRequest(BaseModel):
    constraint: str

class AdaptedRecipeResponse(BaseModel):
    original_recipe_id: str
    constraint_applied: str
    suggested_changes_text: List[str]
    adapted_recipe: Recipe


def _find_recipe(recipe_id: str) -> Recipe:
    for r in _mock_semantic_recipes_db:
        if r.recipe_id == recipe_id:
            return r
    raise HTTPException(status_code=404, detail="Recipe not found")


def _adapt_no_eggs(recipe: Recipe) -> (Recipe, List[str]):
    adapted = recipe.copy(deep=True)
    suggestions = []
    egg_found = False
    for ing in adapted.ingredients:
        if "oeuf" in ing.name.lower() or "egg" in ing.name.lower():
            egg_found = True
            suggestions.append(
                f"Remplacez {ing.name} par un substitut d'oeuf (1/4 tasse de pur\u00e9e de banane ou 1 c.\u00e0s de graines de lin moulues + 3 c.\u00e0s d'eau). La texture pourrait \u00eatre l\u00e9g\u00e8rement diff\u00e9rente."
            )
            ing.name = "Substitut d'oeuf"
    if egg_found:
        for instr in adapted.instructions:
            if "oeuf" in instr.details.lower() or "egg" in instr.details.lower():
                instr.details = instr.details.replace("oeuf", "substitut d'oeuf").replace(
                    "egg", "substitut d'oeuf"
                )
    else:
        suggestions.append("Aucun oeuf trouv\u00e9 dans la recette.")
    return adapted, suggestions


def _adapt_no_oven(recipe: Recipe) -> (Recipe, List[str]):
    adapted = recipe.copy(deep=True)
    suggestions = []
    changed = False
    for instr in adapted.instructions:
        if "four" in instr.action.lower() or "four" in instr.details.lower() or "oven" in instr.action.lower() or "oven" in instr.details.lower():
            changed = True
            suggestions.append(
                f"Remplacez l\u00e9tape '{instr.action}' par une cuisson alternative \u00e0 la po\u00eale ou vapeur. La texture pourrait \u00eatre diff\u00e9rente."
            )
            instr.action = instr.action.replace("four", "cuisson alternative").replace(
                "oven", "cuisson alternative"
            )
            instr.details = instr.details.replace("four", "po\u00eale").replace(
                "oven", "po\u00eale"
            )
    if not changed:
        suggestions.append("Aucune utilisation du four d\u00e9tect\u00e9e.")
    return adapted, suggestions


def _adapt_lactose_free(recipe: Recipe) -> (Recipe, List[str]):
    adapted = recipe.copy(deep=True)
    suggestions = []
    dairy_terms = ["lait", "beurre", "cream", "cheese"]
    changed = False
    for ing in adapted.ingredients:
        if ing.category.lower() == "dairy" or any(term in ing.name.lower() for term in dairy_terms):
            changed = True
            suggestions.append(
                f"Remplacez {ing.name} par une alternative sans lactose (lait v\u00e9g\u00e9tal, margarine...). La saveur pourrait \u00eatre l\u00e9g\u00e8rement diff\u00e9rente."
            )
            ing.name = f"Substitut sans lactose pour {ing.name}"
    if not changed:
        suggestions.append("Aucun ingr\u00e9dient laitier d\u00e9tect\u00e9.")
    return adapted, suggestions


@router.post("/recipes/{recipe_id}/adapt", response_model=AdaptedRecipeResponse)
def adapt_recipe(recipe_id: str, req: AdaptationRequest):
    recipe = _find_recipe(recipe_id)

    constraint = req.constraint.lower()
    if "oeuf" in constraint or "egg" in constraint:
        adapted, suggestions = _adapt_no_eggs(recipe)
        applied = "pas d'oeufs"
    elif "four" in constraint or "oven" in constraint:
        adapted, suggestions = _adapt_no_oven(recipe)
        applied = "pas de four"
    elif "lactose" in constraint:
        adapted, suggestions = _adapt_lactose_free(recipe)
        applied = "sans lactose"
    else:
        raise HTTPException(status_code=400, detail="Contrainte non reconnue")

    return AdaptedRecipeResponse(
        original_recipe_id=recipe_id,
        constraint_applied=applied,
        suggested_changes_text=suggestions,
        adapted_recipe=adapted,
    )
