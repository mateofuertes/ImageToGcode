import re
import json
from PIL import Image
import pytesseract
import torch
from transformers import DistilBertForSequenceClassification, DistilBertTokenizerFast
import pycountry

class BusinessCardReader:
     """
    A class to process business card images, extract text using OCR, and categorize 
    the extracted information such as name, phone number, email, and company.

    Attributes:
    - categories (dict): A dictionary of predefined categories (e.g., name, phone, email, etc.)
                         used to classify the extracted text.
     """

    def __init__(self, model_path, tokenizer_path):
        '''
        Initialize the DistilBERT model and tokenizer with the provided paths.
        The model is used for text classification, while the tokenizer preprocesses text inputs. 
        '''
        
        self.model = DistilBertForSequenceClassification.from_pretrained(model_path)
        self.tokenizer = DistilBertTokenizerFast.from_pretrained(tokenizer_path)

    def preprocess_image(self, image_path):
        '''
        Open and convert the image to grayscale, then binarize it to enhance text readability.
        The binarization threshold is set at 140 to create a high-contrast image for OCR.
        '''

        image = Image.open(image_path)
        gray_image = image.convert("L")
        binarized_image = gray_image.point(lambda x: 0 if x < 140 else 255, '1')
        return binarized_image

    def perform_ocr(self, image):
        '''
        Perform Optical Character Recognition (OCR) on the binarized image using Tesseract.
        The extracted text is split into lines for easier processing.
        '''
        
        custom_config = r'--oem 3 --psm 6'
        extracted_text = pytesseract.image_to_string(image, config=custom_config)
        lines = extracted_text.splitlines()
        return lines

    def categorize_text(self, texts):
        '''
        Categorize the extracted text into predefined categories like phone, email, fax, and website
        Using regular expressions. The function fills these categories when the corresponding text pattern is found.
        '''
        
        categories = {
        categories = {
            'phone': '',
            'email': '',
            'website': '',
            'fax': ''
        }

        phone_pattern = re.compile(r'(\+?\d[\d -]{8,}\d)')
        email_pattern = re.compile(r'\S+@\S+\.\S+')
        website_pattern = re.compile(r'(www\.[a-zA-Z0-9-]+\.[a-zA-Z]{2,})')

        for line in texts:
            line = line.strip()
            if email_pattern.search(line) and not categories['email']:
                categories['email'] = line
            elif phone_pattern.search(line) and not categories['phone']:
                categories['phone'] = line
            elif "fax" in line.lower() and not categories['fax']:
                categories['fax'] = line
            elif website_pattern.search(line) and not categories['website']:
                categories['website'] = line

        return {k: v for k, v in categories.items() if v}

    def classify_text(self, texts):
        '''
        Classify the remaining text that has not been categorized into different categories such as 
        company, faculty, name, or position using the DistilBERT model.
        '''
        
        inputs = self.tokenizer(texts, padding=True, truncation=True, return_tensors="pt")
        input_ids = inputs['input_ids'].to("cpu")
        attention_mask = inputs['attention_mask'].to("cpu")

        with torch.no_grad():
            outputs = self.model(input_ids, attention_mask=attention_mask)
        logits = outputs.logits
        predictions = torch.argmax(logits, dim=-1)
        return predictions.cpu().numpy()

    def apply_heuristics(self, results):
        '''
        Apply heuristics to refine the categorized text. For example, if multiple names or addresses
        are found, choose the most appropriate one based on length and known patterns such as street names or countries.
        '''
        
        if 'name' in results and results['name']:
            names = results['name'].split('\n')
            if len(names) > 1:
                results['name'] = min(names, key=lambda x: len(x.split()))

        if 'address' in results and results['address']:
            addresses = results['address'].split('\n')
            if len(addresses) > 1:
                address_keywords = ['Street', 'Avenue', 'Road', 'St.', 'Ave.', 'Blvd.', 'Lane']
                country_names = [country.name for country in pycountry.countries]
                address_keywords.extend(country_names)
                results['address'] = max(addresses, key=lambda x: (len(x.split()), any(keyword in x for keyword in address_keywords)))

        return results

    def process_image(self, image_path):
        '''
        Process the business card image by performing OCR, categorizing extracted text using regular expressions,
        classifying uncategorized text using the AI model, and finally applying heuristics to refine the results.
        '''
        
        processed_image = self.preprocess_image(image_path)
        extracted_text = self.perform_ocr(processed_image)

        # Step 1: Categorize text using regular expressions
        regex_categories = self.categorize_text(extracted_text)
        
        # Filter out categorized texts for AI model
        remaining_texts = [text for text in extracted_text if text not in regex_categories.values()]
        
        # Step 2: Classify remaining texts using AI model
        class_names = ['company', 'faculty', 'name', 'position']
        predictions = self.classify_text(remaining_texts)

        # Results
        results = {**regex_categories}

        for class_name in class_names:
            results[class_name] = ''  # Initialize with empty values

        for pred, text in zip(predictions, remaining_texts):
            category = class_names[pred]
            if results[category] == '':
                results[category] = text
        
        # Step 3: Apply heuristics to refine results
        results = self.apply_heuristics(results)
        
        return results

    def save_as_json(self, data, file_path):
        '''
        Save the extracted and categorized data as a JSON file at the specified file path.
        '''
        with open(file_path, 'w') as json_file:
            json.dump({"extracted_text": data}, json_file, indent=4)
