from typing import List
from io import BytesIO

import logging
from fastapi import APIRouter, UploadFile, File, HTTPException
from pydantic import BaseModel
from PIL import Image

logger = logging.getLogger(__name__)

router = APIRouter()

class RecognizedItem(BaseModel):
    name: str
    confidence: float
    visual_description: str
    tactile_description: str
    olfactory_description: str

class RecognitionResponse(BaseModel):
    recognized_items: List[RecognizedItem]


def recognize_ingredients_from_image(image_bytes: bytes) -> List[RecognizedItem]:
    """Attempt to recognize basic ingredients based on dominant color."""
    color_db = {
        'pomme': {
            'rgb': (220, 0, 0),
            'desc': ('pomme', 'rouge et ronde', 'lisse et ferme', 'légèrement sucrée'),
        },
        'carotte': {
            'rgb': (255, 140, 0),
            'desc': ('carotte', 'orange et allongée', 'rugueuse', 'odeur terreuse'),
        },
        'oeuf': {
            'rgb': (245, 245, 220),
            'desc': ('œuf', 'blanc et ovale', 'lisse', 'neutre'),
        },
        'farine': {
            'rgb': (250, 250, 250),
            'desc': ('farine', 'poudre blanche', 'poudreuse', 'neutre'),
        },
    }

    try:
        img = Image.open(BytesIO(image_bytes)).convert('RGB')
    except Exception:
        return []

    # compute average color
    avg_color = img.resize((1, 1)).getpixel((0, 0))

    def color_distance(c1, c2):
        return sum((a - b) ** 2 for a, b in zip(c1, c2)) ** 0.5

    recognized: List[RecognizedItem] = []
    max_dist = (3 * (255 ** 2)) ** 0.5
    for info in color_db.values():
        dist = color_distance(avg_color, info['rgb'])
        confidence = max(0.0, 1 - dist / max_dist)
        if confidence >= 0.8:
            desc = info['desc']
            recognized.append(
                RecognizedItem(
                    name=desc[0],
                    confidence=round(confidence, 2),
                    visual_description=desc[1],
                    tactile_description=desc[2],
                    olfactory_description=desc[3],
                )
            )

    return recognized


@router.post('/ingredients/recognize', response_model=RecognitionResponse)
async def recognize_ingredients(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=415, detail='File must be an image')
    try:
        data = await file.read()
        Image.open(BytesIO(data))
    except Exception as exc:
        logger.warning("invalid image upload: %s", exc)
        raise HTTPException(status_code=422, detail='Invalid image file')

    try:
        items = recognize_ingredients_from_image(data)
    except Exception as exc:
        logger.exception("recognition failed: %s", exc)
        raise HTTPException(status_code=500, detail='Recognition error')

    return RecognitionResponse(recognized_items=items)
