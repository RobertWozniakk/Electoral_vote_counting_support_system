import pytesseract
from detect import get_candidate


if __name__ == "__main__":
    img = get_candidate('assets/ballot.jpg')
    pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
    string:str = pytesseract.image_to_string(img, lang='pol')
    if "|"  in string or "'" in string:
        string = string.replace("| ", "")
        string = string.replace("'", "")
    print(string)
