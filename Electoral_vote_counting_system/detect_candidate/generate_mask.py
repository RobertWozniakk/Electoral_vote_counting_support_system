from PIL import Image, ImageDraw
from consts import BOX_COLOR, BOX_SIZE, GAP, TOP_MARGIN, LEFT_MARGIN, MASK_PATH, BACKGROUND, MIN_BOXES, MAX_BOXES


def generate_image_with_boxes(input_image_path: str, num_boxes: int, output_image_path: str):

    image = Image.open(input_image_path)
    draw = ImageDraw.Draw(image)

    if num_boxes > MIN_BOXES and num_boxes < MAX_BOXES:
        for i in range(num_boxes):
            top_left = (LEFT_MARGIN, TOP_MARGIN + i * (BOX_SIZE + GAP))
            bottom_right = (top_left[0] + BOX_SIZE, top_left[1] + BOX_SIZE)
            draw.rectangle([top_left, bottom_right],
                           outline=BOX_COLOR, fill=BOX_COLOR)

        image.save(output_image_path)


if __name__ == "__main__":
    input_image_path = BACKGROUND
    output_image_path = MASK_PATH
    num_boxes = 11
    generate_image_with_boxes(input_image_path, num_boxes, output_image_path)
