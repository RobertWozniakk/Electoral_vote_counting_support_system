import pytesseract
from detect import get_candidate
from consts import TESSERACT_CMD_PATH, TES_LANG, BALLOT_PATH, READ_ERROR
from Levenshtein import ratio as levenshtein_ratio

def remove_artifacts(txt: str) -> str:
    if "|" in txt or "'" in txt:
        txt = txt.replace("| ", "")
        txt = txt.replace("'", "")
    return txt

def get_closest_match(ocr_text: str, candidates: list, threshold: float = 0.5) -> str:
    """
    Dopasowuje tekst OCR do listy kandydatów za pomocą Levenshteina.
    Jeśli najlepsze dopasowanie nie przekroczy progu, zwraca oryginalny tekst.
    """
    best_match = None
    highest_score = 0.0

    for candidate in candidates:
        similarity = levenshtein_ratio(ocr_text.lower(), candidate.lower())
        if similarity > highest_score:
            highest_score = similarity
            best_match = candidate

    # Jeśli najlepszy wynik nie spełnia progu, zwracamy oryginalny tekst
    return best_match if highest_score >= threshold else ocr_text

def read_name(ballot_path: str, candidates: list) -> str:
    img = get_candidate(ballot_path)
    if type(img) == None:
        return READ_ERROR
    pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD_PATH
    ocr_text = pytesseract.image_to_string(img, lang=TES_LANG)
    cleaned_text = remove_artifacts(ocr_text)
    best_match = get_closest_match(cleaned_text, candidates)
    return best_match


if __name__ == "__main__":
    read_name(BALLOT_PATH, candidates)
