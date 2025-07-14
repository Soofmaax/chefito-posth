from typing import List, Optional
from uuid import uuid4

import logging
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError

from app.models.recipe_semantic import (
    Recipe,
    Ingredient,
    Instruction,
    TroubleshootingTip,
    StorageAndReheating,
    SuccessMetrics,
    RecipeDB,
    IngredientDB,
    InstructionDB,
)
from app.database import get_db

logger = logging.getLogger(__name__)

router = APIRouter()


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


def convert_db_recipe(db_recipe: RecipeDB) -> Recipe:
    ingredients = [
        Ingredient(
            id=str(i.id),
            name=i.name,
            quantity=i.quantity,
            unit=i.unit,
            category=i.category,
            notes=i.notes,
        )
        for i in db_recipe.ingredients
    ]

    instructions = [
        Instruction(
            id=str(ins.id),
            action=ins.action,
            details=ins.details,
            time_minutes=ins.time_minutes,
            safety_warning=ins.safety_warning,
            priority=ins.priority,
            ingredients_used=[str(x) for x in (ins.ingredients_used or [])],
            utensils_used=ins.utensils_used or [],
            troubleshooting=[TroubleshootingTip(**t) for t in ins.troubleshooting or []],
        )
        for ins in db_recipe.instructions
    ]

    return Recipe(
        recipe_id=str(db_recipe.recipe_id),
        title=db_recipe.title,
        description=db_recipe.description,
        ingredients=ingredients,
        instructions=instructions,
        variations=db_recipe.variations or [],
        chef_guidance=db_recipe.chef_guidance or [],
        ai_conversation_prompts=db_recipe.ai_conversation_prompts or [],
        storage_and_reheating=StorageAndReheating(**db_recipe.storage_and_reheating),
        common_troubleshooting=[
            TroubleshootingTip(**t) for t in db_recipe.common_troubleshooting or []
        ],
        success_metrics=SuccessMetrics(**db_recipe.success_metrics),
        prep_time_minutes=db_recipe.prep_time_minutes,
        cook_time_minutes=db_recipe.cook_time_minutes,
        servings=db_recipe.servings,
        tags=db_recipe.tags or [],
    )


@router.get("/recipes", response_model=List[Recipe])
def list_recipes(
    skip: int = 0, limit: int = 10, db: Session = Depends(get_db)
):
    try:
        records = db.query(RecipeDB).offset(skip).limit(limit).all()
        return [convert_db_recipe(rec) for rec in records]
    except SQLAlchemyError as exc:
        logger.exception("DB error: %s", exc)
        raise HTTPException(status_code=503, detail="Database error")


@router.get("/recipes/{recipe_id}", response_model=Recipe)
def get_recipe(recipe_id: str, db: Session = Depends(get_db)):
    try:
        rec = (
            db.query(RecipeDB)
            .filter(RecipeDB.recipe_id == recipe_id)
            .first()
        )
        if not rec:
            raise HTTPException(status_code=404, detail="Recipe not found")
        return convert_db_recipe(rec)
    except SQLAlchemyError as exc:
        logger.exception("DB error: %s", exc)
        raise HTTPException(status_code=503, detail="Database error")


@router.post("/recipes", response_model=Recipe, status_code=201)
def create_recipe(recipe_in: RecipeCreate, db: Session = Depends(get_db)):
    try:
        db_recipe = RecipeDB(
            recipe_id=str(uuid4()),
            title=recipe_in.title,
            description=recipe_in.description,
            variations=recipe_in.variations,
            chef_guidance=recipe_in.chef_guidance,
            ai_conversation_prompts=recipe_in.ai_conversation_prompts,
            storage_and_reheating=recipe_in.storage_and_reheating.dict(),
            common_troubleshooting=[t.dict() for t in recipe_in.common_troubleshooting],
            success_metrics=recipe_in.success_metrics.dict(),
            prep_time_minutes=recipe_in.prep_time_minutes,
            cook_time_minutes=recipe_in.cook_time_minutes,
            servings=recipe_in.servings,
            tags=recipe_in.tags,
        )
        db.add(db_recipe)
        db.flush()

        for ing in recipe_in.ingredients:
            db_ing = IngredientDB(
                id=str(uuid4()),
                recipe_id=db_recipe.recipe_id,
                name=ing.name,
                quantity=ing.quantity,
                unit=ing.unit,
                category=ing.category,
                notes=ing.notes,
            )
            db.add(db_ing)

        for inst in recipe_in.instructions:
            db_inst = InstructionDB(
                id=str(uuid4()),
                recipe_id=db_recipe.recipe_id,
                action=inst.action,
                details=inst.details,
                time_minutes=inst.time_minutes,
                safety_warning=inst.safety_warning,
                priority=inst.priority,
                ingredients_used=inst.ingredients_used,
                utensils_used=inst.utensils_used,
                troubleshooting=[t.dict() for t in inst.troubleshooting],
            )
            db.add(db_inst)

        db.commit()
        db.refresh(db_recipe)
        return convert_db_recipe(db_recipe)
    except SQLAlchemyError as exc:
        logger.exception("DB error: %s", exc)
        db.rollback()
        raise HTTPException(status_code=503, detail="Database error")
