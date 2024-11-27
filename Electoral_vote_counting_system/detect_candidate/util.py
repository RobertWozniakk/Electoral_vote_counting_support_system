import pickle

from skimage.transform import resize
import numpy as np
import cv2
from consts import MODEL_PATH, MINAREA, EMPTY, FILLED, GRID_SHAPE
model = pickle.load(open(MODEL_PATH, "rb"))


def check_if_empty(grid):
    flatten_data = []
    img_resized = resize(grid, GRID_SHAPE)
    flatten_data.append(img_resized.flatten())
    flatten_data = np.array(flatten_data)

    y_out = model.predict(flatten_data)

    if y_out == 0:
        return EMPTY
    else:
        return FILLED


def get_grid_boxes(components):
    (totalLabels, label_ids, values, centroid) = components
    boxes = []
    coef = 1

    for i in range(1, totalLabels):
        x1 = int(values[i, cv2.CC_STAT_LEFT] * coef)
        y1 = int(values[i, cv2.CC_STAT_TOP] * coef)
        w = int(values[i, cv2.CC_STAT_WIDTH] * coef)
        h = int(values[i, cv2.CC_STAT_HEIGHT] * coef)
        if w*h >= MINAREA:
            boxes.append([x1, y1, w, h])
    return boxes


def check_pesel(pesel: str):
    try:
        weights = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3]
        control_numer = int(pesel[-1])
        numbers = pesel[:-1]
        sum = 0
        for i, num in enumerate(numbers):
            sum += int(num) * weights[i]
        sum = 10 - sum % 10
        if sum == 10:
            sum = 0
        return sum == control_numer
    except:
        return False
