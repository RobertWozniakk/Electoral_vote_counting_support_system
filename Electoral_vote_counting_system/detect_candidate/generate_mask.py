from typing import List
from PIL import Image, ImageDraw
from consts import BOX_COLOR, BOX_SIZE, GAP, TOP_MARGIN, LEFT_MARGIN, MASK_PATH, BACKGROUND, MIN_BOXES, MAX_BOXES


def generate_mask(input_image_path: str, num_candidates: int, output_image_path: str):
    image = Image.open(input_image_path)
    draw = ImageDraw.Draw(image)

    # Tworzenie pól wyborczych dla kandydatów
    if MIN_BOXES <= num_candidates <= MAX_BOXES:
        for i in range(num_candidates):
            top_left = (LEFT_MARGIN, TOP_MARGIN + i * (BOX_SIZE + GAP))
            bottom_right = (top_left[0] + BOX_SIZE, top_left[1] + BOX_SIZE)
            draw.rectangle([top_left, bottom_right], outline=BOX_COLOR, fill=BOX_COLOR)

    # Zapis obrazu z maską
    image.save(output_image_path)

