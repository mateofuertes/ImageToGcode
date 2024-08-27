# OCR in Business cards (Image) to CNC Engraving Machine (G-code) Web App

## Overview

This application converts images to G-code, a language used to control CNC machines. Upload an image, process it to generate G-code using extracted information, and preview the result. The G-code can then be used with compatible CNC machines to imprint extracted text from the uploaded image.

When use this app, click the "Upload Image" button to upload an image. Tesseract OCR will process the image to extract text information, which will be classified into different categories for generating G-code. You can edit the extracted information and save it to generate new G-code. You can download the image, JSON file with the extracted information, and G-code from the Drawer menu. Alternatively, you can upload a JSON file with the information to directly generate the G-code. Final steps would be control the cnc machine, set the spindle in the right position and run the generated g-code.


## Features

- **Image Processing**: Converts images of ID cards into information in JSON format.
- **G-code Generation**: Transforms JSON data into G-code.
- **G-code Preview**: Generates a visual preview of the G-code.
- **CNC Control**: Provides a web API to control CNC machines, including movement and spindle control.


## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mateofuertes/ImageToGcode.git
   cd ImageToGcode
  
2. **Run the backend server:**
   Connect the cnc machine using any usb port of the computer. Navigate to Backend directory, install necessary dependencies and run the api_server.py file:
   ```bash
   cd Backend
   pip3 install spacy
   pip3 install tesseract
   pip3 install flask_cors
   python3 api_server.py

3. **Run the frontend server:**
   Navigate to the Frontend Web Build directory and run a http server for the frontend in an avaiable port. For example:
   ```bash
   cd ..
   cd "Frontend Web Build"
   python -m http.server 8080

4. **Open the web app:**
   Open your browser and navigate to your frontend http running server For example: http://localhost:8080



