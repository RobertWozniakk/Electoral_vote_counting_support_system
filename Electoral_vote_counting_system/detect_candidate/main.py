import base64
from fastapi import FastAPI
from pydantic import BaseModel
from read_name import read_name
from generate_mask import generate_image_with_boxes
app = FastAPI()

class ImgModel(BaseModel):
    img:str

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


@app.post('/{candidates}')
async def give_mask(candidates: int):
    generate_image_with_boxes(candidates)
    return {'mask': 'generated'}
