# ImageToGcode

This application converts images to G-code, a language used to control CNC machines. Upload an image, process it to generate G-code, and preview the result. The G-code can then be used with compatible CNC machines to imprint extracted text from the uploaded image.

To use this app, click the "Upload Image" button to upload an image. Tesseract OCR will process the image to extract text information, which will be classified into different categories for generating G-code. You can edit the extracted information and save it to generate new G-code.

You can download the image, JSON file with the extracted information, and G-code from the Drawer menu. Alternatively, you can upload a JSON file with the information to generate the G-code.

Once the G-code is generated, preview it in the "G-code Preview" tab. To execute the G-code on a compatible CNC machine, click the "Run G-code" button to send the G-code for execution.
