import base64
import os
from typing import List
from fastapi import FastAPI
from pydantic import BaseModel
from read_name import read_name
from util import check_pesel
from consts import BACKGROUND, MASK_PATH
from generate_mask import generate_mask
app = FastAPI()


class ImgModel(BaseModel):
    img: str

class CandidateList(BaseModel):
    candidates: List[str]

@app.get('/')
async def root():
    return {}

@app.post('/add_candidates')
async def add_candidates(candidate_list: CandidateList):
    global candidates
    if not candidate_list.candidates:
        raise HTTPException(status_code=400, detail="Lista kandydatów jest pusta.")

    candidates = candidate_list.candidates
    return {"message": "Lista kandydatów dodana pomyślnie", "candidates": candidates}

@app.get("/get_candidates")
async def get_candidates():
    return {"candidates": candidates}

@app.post('/read', response_model=dict)
async def get_candidate(image: ImgModel):
    try:
        img_data = base64.b64decode(image.img)
        with open('assets/ballot.jpg', 'wb') as f:
            f.write(img_data)
        name = read_name('assets/ballot.jpg',candidates)

        return {'name': name}
    except Exception as e:
        return {'error': str(e)}


@app.post('/test')
async def test():
    return 'test'


@app.post('/mask/{num_candidates}')
async def give_mask(num_candidates: int):
    if os.path.exists(MASK_PATH):
        os.remove(MASK_PATH)
    generate_mask(BACKGROUND, num_candidates, MASK_PATH)

    with open(MASK_PATH, "rb") as mask_file:
        mask_base64 = base64.b64encode(mask_file.read()).decode("utf-8")

    return {'mask': mask_base64}


@app.post('/login/{pesel}')
async def check_login(pesel: str):
    is_valid = check_pesel(pesel)
    return {"valid": is_valid}