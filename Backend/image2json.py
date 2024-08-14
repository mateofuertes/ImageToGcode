from PIL import Image
import pytesseract
import spacy
import json
import re

# Load spaCy model for Named Entity Recognition (NER)
nlp = spacy.load('en_core_web_sm')

class BusinessCardReader:
    """
    A class to process business card images, extract text using OCR, and categorize 
    the extracted information such as name, phone number, email, and company.

    Attributes:
    - categories (dict): A dictionary of predefined categories (e.g., name, phone, email, etc.)
                         used to classify the extracted text.
    """
    
    def __init__(self):
        """
        Initializes the BusinessCardReader with a predefined set of categories.
        These categories are used to store extracted information from the business card.
        """
        
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
        """
        Preprocesses the image for better OCR accuracy by converting it to grayscale.

        Parameters:
        - image_path (str): The file path to the business card image.

        Returns:
        - Image: The preprocessed grayscale image.
        """
        image = Image.open(image_path)
        gray_image = image.convert("L")
        return gray_image

    def perform_ocr(self, image):
        """
        Performs Optical Character Recognition (OCR) on the preprocessed image to extract text.

        Parameters:
        - image (Image): The preprocessed image.

        Returns:
        - str: The text extracted from the image using Pytesseract.
        """
        extracted_text = pytesseract.image_to_string(image, lang='eng')
        return extracted_text

    def categorize_text(self, text):
        """
        Categorizes the extracted text into predefined categories such as name, phone, email, and company 
        using both regex patterns and Named Entity Recognition (NER) with spaCy.

        Parameters:
        - text (str): The extracted text from the business card.

        Returns:
        - dict: A dictionary containing categorized information (e.g., name, phone, email).
                Categories without any extracted information will be excluded from the dictionary.
        """   
        # Create a copy of the categories dictionary to store categorized text
        categories = self.categories.copy()

        # Process text with spaCy's Named Entity Recognition (NER)
        doc = nlp(text)

        # Extract specific entities such as PERSON (name) and ORG (company)
        for ent in doc.ents:
            if ent.label_ == 'PERSON' and not categories['name']:
                categories['name'] = ent.text.strip()
            elif ent.label_ == 'ORG' and not categories['company']:
                categories['company'] = ent.text.strip()

        # Further categorize lines of text using regex and keyword matching
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
        """
        Processes the entire workflow for extracting and categorizing text from a business card image.
        This includes preprocessing the image, performing OCR, and categorizing the extracted information.

        Parameters:
        - image_path (str): The file path to the business card image.

        Returns:
        - dict: A dictionary containing categorized information extracted from the business card.
        """
        
        # Preprocess the image
        pytesseract.pytesseract.tesseract_cmd = r'/usr/bin/tesseract'
        processed_image = self.preprocess_image(image_path)
        
        # Perform OCR on the pre-processed image
        extracted_text = self.perform_ocr(processed_image)
        
        # Categorize the extracted text
        categorized_data = self.categorize_text(extracted_text)
        
        return categorized_data

    def save_as_json(self, data, file_path):
        """
        Saves the categorized data as a JSON file.

        Parameters:
        - data (dict): The categorized information to be saved.
        - file_path (str): The file path where the JSON file should be saved.
        """
        with open(file_path, 'w') as json_file:
            json.dump(data, json_file, indent=4)
