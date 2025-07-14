import os
import sys
from io import BytesIO

import pytest
from fastapi.testclient import TestClient
from PIL import Image

sys.path.insert(0, os.path.abspath('.'))

from app.api import create_app


@pytest.fixture
def client():
    app = create_app()
    return TestClient(app)


def create_test_image(color='red') -> bytes:
    img = Image.new('RGB', (10, 10), color=color)
    buf = BytesIO()
    img.save(buf, format='PNG')
    return buf.getvalue()


def test_recognize_red_image(client):
    img_bytes = create_test_image('red')
    files = {'file': ('img.png', img_bytes, 'image/png')}
    res = client.post('/ingredients/recognize', files=files)
    assert res.status_code == 200
    names = [item['name'] for item in res.json()['recognized_items']]
    assert 'tomate' in names


def test_recognize_orange_image(client):
    img_bytes = create_test_image('orange')
    files = {'file': ('img.png', img_bytes, 'image/png')}
    res = client.post('/ingredients/recognize', files=files)
    assert res.status_code == 200
    names = [item['name'] for item in res.json()['recognized_items']]
    assert 'carotte' in names


def test_invalid_file_type(client):
    files = {'file': ('note.txt', b'hello', 'text/plain')}
    res = client.post('/ingredients/recognize', files=files)
    assert res.status_code == 415
