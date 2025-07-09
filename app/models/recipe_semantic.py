from typing import List, Optional
from pydantic import BaseModel, Field

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

