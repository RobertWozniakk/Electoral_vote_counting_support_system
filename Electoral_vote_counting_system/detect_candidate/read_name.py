import pytesseract
from detect import get_candidate
from consts import TESSERACT_CMD_PATH, TES_LANG, BALLOT_PATH, READ_ERROR


def remove_artifacts(txt: str) -> str:
    if "|" in txt or "'" in txt:
        txt = txt.replace("| ", "")
        txt = txt.replace("'", "")
    return txt


def read_name(ballot_path: str) -> str:
    img = get_candidate(ballot_path)
    if type(img) == None:
        return READ_ERROR
    pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD_PATH
    candidate = pytesseract.image_to_string(img, lang=TES_LANG)
    return remove_artifacts(candidate)


if __name__ == "__main__":
    print(read_name(BALLOT_PATH))
