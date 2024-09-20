import pickle

from skimage.transform import resize
import numpy as np
import cv2

EMPTY = False
FILLED = True

MODEL = pickle.load(open("model.p", "rb"))


def check_if_empty(grid):
    flatten_data = []
    img_resized = resize(grid, (15, 15, 3))
    flatten_data.append(img_resized.flatten())
    flatten_data = np.array(flatten_data)

    y_out = MODEL.predict(flatten_data)

    if y_out == 0:
        return EMPTY
    else:
        return FILLED


def get_grid_boxes(components):
    (totalLabels, label_ids, values, centroid) = components
    boxes = []
    coef = 1
    minarea = 15*15
    for i in range(1, totalLabels):
        x1 = int(values[i, cv2.CC_STAT_LEFT] * coef)
        y1 = int(values[i, cv2.CC_STAT_TOP] * coef)
        w = int(values[i, cv2.CC_STAT_WIDTH] * coef)
        h = int(values[i, cv2.CC_STAT_HEIGHT] * coef)
        if w*h >= minarea:
            boxes.append([x1, y1, w, h])
    return boxes
