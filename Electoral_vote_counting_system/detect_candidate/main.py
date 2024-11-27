import base64
import os
from fastapi import FastAPI
from pydantic import BaseModel
from read_name import read_name
from generate_mask import generate_mask
from util import check_pesel
from consts import BACKGROUND, MASK_PATH
app = FastAPI()


class ImgModel(BaseModel):
    img: str


@app.get('/')
async def root():
    return {}


@app.post('/read', response_model=dict)
async def get_candidate(image: ImgModel):
    try:
        img_data = base64.b64decode(image.img)
        with open('assets/ballot.jpg', 'wb') as f:
            f.write(img_data)
        name = read_name('assets/ballot.jpg')
        return {'name': name}
    except Exception as e:
        return {'error': str(e)}


@app.post('/test')
async def test():
    return 'test'


@app.post('/mask/{candidates}')
async def give_mask(candidates: int):
    if os.path.exists(MASK_PATH):
        os.remove(MASK_PATH)
    generate_mask(BACKGROUND, candidates, MASK_PATH)
    return {'mask': 'generated'}


@app.post('/login/{pesel}')
async def check_login(pesel: str):
    is_valid = check_pesel(pesel)
    return {"valid": is_valid}
