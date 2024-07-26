# Import necessary libraries
from PIL import Image
import pytesseract
import spacy
import json
import re

# Load spaCy model
nlp = spacy.load('en_core_web_sm')

class BusinessCardReader:
    def __init__(self):
        self.categories = {
            'name': None,
            'phone': None,
            'email': None,
            'fax': None,
            'faculty': None,
            'position': None,
            'company': None,
            'website': None
        }

    def preprocess_image(self, image_path):
        # Load the image
        image = Image.open(image_path)
        # Convert the image to grayscale
        gray_image = image.convert("L")
        return gray_image

    def perform_ocr(self, image):
        # Perform OCR using Pytesseract
        extracted_text = pytesseract.image_to_string(image, lang='eng')
        return extracted_text

    def categorize_text(self, text):
        categories = self.categories.copy()

        # Process text with spaCy
        doc = nlp(text)

        for ent in doc.ents:
            if ent.label_ == 'PERSON' and not categories['name']:
                categories['name'] = ent.text.strip()
            elif ent.label_ == 'ORG' and not categories['company']:
                categories['company'] = ent.text.strip()

        # Check each line for additional details
        lines = [line.strip() for line in text.split('\n') if line.strip()]
        for line in lines:
            if "@" in line and not categories['email']:
                categories['email'] = line.strip()
            elif any(word in line.lower() for word in ["fax", "fax:"]) and not categories['fax']:
                categories['fax'] = line.strip()
            elif any(word in line.lower() for word in ["phone", "tel", "telephone", "mobile", "cell"]) and not categories['phone']:
                categories['phone'] = line.strip()
            elif any(word in line.lower() for word in ["faculty", "department"]) and not categories['faculty']:
                categories['faculty'] = line.strip()
            elif any(word in line.lower() for word in ["position", "title"]) and not categories['position']:
                categories['position'] = line.strip()
            elif re.match(r'^www\.', line) and not categories['website']:
                categories['website'] = line.strip()
            elif any(word in line.lower() for word in ["website", "web"]) and not categories['website']:
                categories['website'] = line.strip()

        # Remove categories with None values
        categories = {k: v for k, v in categories.items() if v}

        return categories


    def process_image(self, image_path):
        # Preprocess the image
        pytesseract.pytesseract.tesseract_cmd = 'C:/Users/mateo/AppData/Local/Programs/Tesseract-OCR/tesseract.exe'
        processed_image = self.preprocess_image(image_path)
        # Perform OCR on the pre-processed image
        extracted_text = self.perform_ocr(processed_image)
        # Categorize the extracted text
        categorized_data = self.categorize_text(extracted_text)
        return categorized_data

    def save_as_json(self, data, file_path):
        # Save the dictionary as a JSON file
        with open(file_path, 'w') as json_file:
            json.dump(data, json_file, indent=4)