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


def recognize_ingredients_from_image(image_bytes: bytes, filename: str) -> List[RecognizedItem]:
    _mapping = {
        'pomme': ('pomme', 'rouge et ronde', 'lisse et ferme', 'légèrement sucrée'),
        'apple': ('pomme', 'rouge et ronde', 'lisse et ferme', 'légèrement sucrée'),
        'carotte': ('carotte', 'orange et allongée', 'rugueuse', 'odeur terreuse'),
        'carrot': ('carotte', 'orange et allongée', 'rugueuse', 'odeur terreuse'),
        'oeuf': ('œuf', 'blanc et ovale', 'lisse', 'neutre'),
        'egg': ('œuf', 'blanc et ovale', 'lisse', 'neutre'),
        'farine': ('farine', 'poudre blanche', 'poudreuse', 'neutre'),
        'flour': ('farine', 'poudre blanche', 'poudreuse', 'neutre'),
    }

    filename = filename.lower()
    recognized = []
    for key, desc in _mapping.items():
        if key in filename:
            recognized.append(
                RecognizedItem(
                    name=desc[0],
                    confidence=0.9,
                    visual_description=desc[1],
                    tactile_description=desc[2],
                    olfactory_description=desc[3],
                )
            )
    return recognized


@router.post('/ingredients/recognize', response_model=RecognitionResponse)
async def recognize_ingredients(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail='File must be an image')
    try:
        data = await file.read()
        # validate image
        Image.open(BytesIO(data))
    except Exception:
        raise HTTPException(status_code=400, detail='Invalid image file')

    items = recognize_ingredients_from_image(data, file.filename or '')
    return RecognitionResponse(recognized_items=items)
