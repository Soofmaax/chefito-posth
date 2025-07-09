import os
import sys
from io import BytesIO

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from PIL import Image

sys.path.insert(0, os.path.abspath('.'))

from app.api.ingredient_recognition_semantic import router


@pytest.fixture
def client():
    app = FastAPI()
    app.include_router(router)
    return TestClient(app)


def create_test_image() -> bytes:
    img = Image.new('RGB', (10, 10), color='red')
    buf = BytesIO()
    img.save(buf, format='PNG')
    return buf.getvalue()


def test_recognize_valid_image(client):
    img_bytes = create_test_image()
    files = {'file': ('carrot.png', img_bytes, 'image/png')}
    res = client.post('/ingredients/recognize', files=files)
    assert res.status_code == 200
    data = res.json()
    assert data['recognized_items']
    assert data['recognized_items'][0]['name'] == 'carotte'


def test_recognize_invalid_file(client):
    files = {'file': ('note.txt', b'not an image', 'text/plain')}
    res = client.post('/ingredients/recognize', files=files)
    assert res.status_code == 400

