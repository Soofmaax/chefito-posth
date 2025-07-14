from typing import List, Optional
from uuid import uuid4
from pydantic import BaseModel, Field

from sqlalchemy import (
    Column,
    String,
    Integer,
    Float,
    ForeignKey,
    Text,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB, ARRAY
from sqlalchemy.orm import relationship

from app.database import Base

class TroubleshootingTip(BaseModel):
    problem: str
    solution: str
    sensory_cue: str

class Ingredient(BaseModel):
    id: str
    name: str
    quantity: float
    unit: str
    category: str
    notes: str

class Instruction(BaseModel):
    id: str
    action: str
    details: str
    time_minutes: Optional[int] = None
    safety_warning: Optional[str] = None
    priority: str
    ingredients_used: List[str]
    utensils_used: List[str]
    troubleshooting: List[TroubleshootingTip]

class StoragePeriod(BaseModel):
    duration: int
    instructions: str

class StorageAndReheating(BaseModel):
    refrigerator_storage: StoragePeriod
    freezer_storage: StoragePeriod
    reheating_instructions: str

class SuccessMetrics(BaseModel):
    visual_cues: str
    texture_goal: str
    flavor_profile: str
    aroma_indicators: str

class Recipe(BaseModel):
    recipe_id: str
    title: str
    description: str
    ingredients: List[Ingredient]
    instructions: List[Instruction]
    variations: List[str]
    chef_guidance: List[str] = Field(alias='chef_guidance')
    ai_conversation_prompts: List[str]
    storage_and_reheating: StorageAndReheating
    common_troubleshooting: List[TroubleshootingTip]
    success_metrics: SuccessMetrics
    prep_time_minutes: Optional[int] = None
    cook_time_minutes: Optional[int] = None
    servings: Optional[int] = None
    tags: List[str]

    class Config:
        allow_population_by_field_name = True


# SQLAlchemy models -------------------------------------------------------


class RecipeDB(Base):
    __tablename__ = "recipes"

    recipe_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    variations = Column(ARRAY(String))
    chef_guidance = Column(ARRAY(String))
    ai_conversation_prompts = Column(ARRAY(String))
    storage_and_reheating = Column(JSONB)
    common_troubleshooting = Column(JSONB)
    success_metrics = Column(JSONB)
    prep_time_minutes = Column(Integer)
    cook_time_minutes = Column(Integer)
    servings = Column(Integer)
    tags = Column(ARRAY(String))

    ingredients = relationship(
        "IngredientDB", back_populates="recipe", cascade="all, delete-orphan"
    )
    instructions = relationship(
        "InstructionDB", back_populates="recipe", cascade="all, delete-orphan"
    )


class IngredientDB(Base):
    __tablename__ = "ingredients"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    recipe_id = Column(
        UUID(as_uuid=True), ForeignKey("recipes.recipe_id", ondelete="CASCADE"), index=True
    )
    name = Column(String, nullable=False)
    quantity = Column(Float, nullable=False)
    unit = Column(String, nullable=False)
    category = Column(String)
    notes = Column(Text)

    recipe = relationship("RecipeDB", back_populates="ingredients")


class InstructionDB(Base):
    __tablename__ = "instructions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    recipe_id = Column(
        UUID(as_uuid=True), ForeignKey("recipes.recipe_id", ondelete="CASCADE"), index=True
    )
    action = Column(String, nullable=False)
    details = Column(Text, nullable=False)
    time_minutes = Column(Integer)
    safety_warning = Column(Text)
    priority = Column(String)
    ingredients_used = Column(ARRAY(UUID(as_uuid=True)))
    utensils_used = Column(ARRAY(String))
    troubleshooting = Column(JSONB)

    recipe = relationship("RecipeDB", back_populates="instructions")

