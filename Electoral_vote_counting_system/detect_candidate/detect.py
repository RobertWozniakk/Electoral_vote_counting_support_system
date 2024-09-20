import cv2
from util import get_grid_boxes, check_if_empty
import numpy as np
MASK = 'assets/mask.jpg'
MASK = cv2.imread(MASK, 0)


def get_candidate(img_path: str):
    ballot = cv2.imread(img_path)
    connected_comps = cv2.connectedComponentsWithStats(MASK, 4, cv2.CV_32S)
    boxes = get_grid_boxes(connected_comps)
    for box_idx, box in enumerate(boxes):
        x1, y1, w, h = boxes[box_idx]
        box_crop = ballot[y1:y1+h, x1:x1+w, :]
        box_status = check_if_empty(box_crop)
        if box_status:
            crop_ballot = ballot[y1-h:y1+2*h, x1 + w:-1]
            return crop_ballot
