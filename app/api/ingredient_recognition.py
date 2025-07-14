from typing import List
from io import BytesIO

from fastapi import APIRouter, UploadFile, File, HTTPException
from pydantic import BaseModel
from PIL import Image


router = APIRouter()


class RecognizedItem(BaseModel):
    name: str
    confidence: float
    visual_description: str
    tactile_description: str
    olfactory_description: str


class RecognitionResponse(BaseModel):
    recognized_items: List[RecognizedItem]


COLOR_RULES = {
    'red': {
        'name': 'tomate',
        'descriptions': (
            'rouge et ronde',
            'lisse et ferme',
            'légèrement sucrée'
        ),
        'confidence': 0.8,
    },
    'orange': {
        'name': 'carotte',
        'descriptions': (
            'orange et allongée',
            'rugueuse',
            'odeur terreuse'
        ),
        'confidence': 0.75,
    },
}


def _dominant_color(image: Image.Image) -> str:
    small = image.resize((1, 1))
    r, g, b = small.getpixel((0, 0))
    if r > 200 and g < 100 and b < 100:
        return 'red'
    if r > 200 and g > 100 and b < 50:
        return 'orange'
    return 'unknown'


def recognize_ingredients_from_image(image_bytes: bytes) -> List[RecognizedItem]:
    try:
        img = Image.open(BytesIO(image_bytes)).convert('RGB')
    except Exception:
        raise HTTPException(status_code=422, detail='Invalid image file')

    color = _dominant_color(img)
    rule = COLOR_RULES.get(color)
    if not rule:
        return []

    name = rule['name']
    desc = rule['descriptions']
    confidence = rule['confidence']
    return [
        RecognizedItem(
            name=name,
            confidence=confidence,
            visual_description=desc[0],
            tactile_description=desc[1],
            olfactory_description=desc[2],
        )
    ]


@router.post('/ingredients/recognize', response_model=RecognitionResponse)
async def recognize_ingredients(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=415, detail='File must be an image')

    data = await file.read()
    items = recognize_ingredients_from_image(data)
    return RecognitionResponse(recognized_items=items)

