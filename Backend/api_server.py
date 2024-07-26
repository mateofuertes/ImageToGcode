import json
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import subprocess
import os
import image2json
import json2gcode
import gcode2preview


app = Flask(__name__)
CORS(app)

# Define the path to your Python scripts
IMAGE2JSON_SCRIPT = 'image2json.py'
JSON2GCODE_SCRIPT = 'json2gcode.py'
GCODE2PREVIEW_SCRIPT = 'gcode2preview.py'

# Temporary files
TEMP_IMAGE_FILE = 'temp_image.png'
TEMP_JSON_FILE = 'temp.json'
TEMP_GCODE_FILE = 'temp.nc'
TEMP_PREVIEW_FILE = 'temp_preview.png'

@app.route('/', methods=['GET'])
def index():
    return (
        "Welcome to the API! Here are the endpoints you can use:\n"
        "1. POST /process - Process an image through the entire pipeline\n\n"
        "To use this endpoint, send a POST request with an image file."
    )

@app.route('/process', methods=['POST'])
def process_image():
    # Step 1: Receive the image file
    image_file = request.files.get('image')
    if not image_file:
        return jsonify({"error": "No image file provided"}), 400
    
    # Save the image file temporarily
    image_file.save(TEMP_IMAGE_FILE)
    
    # Step 2: Convert the image to JSON
    try:
        reader = image2json.BusinessCardReader()
    # Process the temp_image.png file
        image_path = "temp_image.png"
        categorized_data = reader.process_image(image_path)
    # Print the categorized data
        # print(json.dumps(categorized_data, indent=4))
    # Save JSON to temp.json file
        reader.save_as_json(categorized_data, "temp.json")
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during image2json execution: {str(e)}"}), 500
    
    # Step 3: Convert JSON to G-code
    try:
        from json2gcode import GCodeGenerator
        import tempfile
        from letters_dictionary import letters  # Load your letters dictionary here
        generator = GCodeGenerator(letters)
        temp_json_file = 'temp.json'
        temp_nc_file = 'temp.nc'
        generator.generate_gcode_from_json(temp_json_file, temp_nc_file)
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during json2gcode execution: {str(e)}"}), 500
    
    # Step 4: Generate G-code preview
    try:
        from gcode2preview import GCodePreviewGenerator

        generator = GCodePreviewGenerator()
        generator.generate_preview()  # This will read from 'temp.nc' and save to 'temp_preview.png'
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during gcode2preview execution: {str(e)}"}), 500
    
    # Return the result
    return jsonify({
        "message": "Processing complete",
        "json_file": "Done!",
        "gcode_file": "Done!",
        "preview_file": "Done!"
    }), 200

@app.route('/json', methods=['GET'])
def getJson():
    try:
        file_path = 'C:/Users/mateo/Downloads/json_to_gcode (2)/json_to_gcode'
        file_name = 'temp.json'
        full_path = os.path.join(file_path, file_name)
        if not os.path.exists(full_path):
            return jsonify({"error": "No JSON file found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return send_from_directory(file_path, file_name), 200

@app.route('/nc', methods=['GET'])
def get_nc():
    try:
        file_path = 'C:/Users/mateo/Downloads/json_to_gcode (2)/json_to_gcode'
        file_name = 'temp.nc'
        full_path = os.path.join(file_path, file_name)
        if not os.path.exists(full_path):
            return jsonify({"error": "No NC file found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return send_from_directory(file_path, file_name), 200

@app.route('/preview', methods=['GET'])
def get_image():
    try:
        file_path = 'C:/Users/mateo/Downloads/json_to_gcode (2)/json_to_gcode'
        file_name = 'temp_preview.png'
        full_path = os.path.join(file_path, file_name)
        if not os.path.exists(full_path):
            return jsonify({"error": "No image file found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return send_from_directory(file_path, file_name), 200

@app.route('/processJson', methods=['POST'])
def process_json():
    # Step 1: Receive the image file
    json_file = request.files.get('json')
    if not json_file:
        return jsonify({"error": "No json file provided"}), 400
    
    # Save the image file temporarily
    json_file.save(TEMP_JSON_FILE)
    
    # Step 3: Convert JSON to G-code
    try:
        from json2gcode import GCodeGenerator
        import tempfile
        from letters_dictionary import letters  # Load your letters dictionary here
        generator = GCodeGenerator(letters)
        temp_json_file = 'temp.json'
        temp_nc_file = 'temp.nc'
        generator.generate_gcode_from_json(temp_json_file, temp_nc_file)
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during json2gcode execution: {str(e)}"}), 500
    
    # Step 4: Generate G-code preview
    try:
        from gcode2preview import GCodePreviewGenerator

        generator = GCodePreviewGenerator()
        generator.generate_preview()  # This will read from 'temp.nc' and save to 'temp_preview.png'
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during gcode2preview execution: {str(e)}"}), 500
    
    # Return the result
    return jsonify({
        "message": "Processing complete",
        "gcode_file": "Done!",
        "preview_file": "Done!"
    }), 200

@app.route('/updateJson', methods=['POST'])
def update_json():
    json_file = request.files.get('json')
    if not json_file:
        return jsonify({"error": "No json file provided"}), 400
    json_file.save(TEMP_JSON_FILE)
    return jsonify({"message": "JSON file updated"}), 200
    

if __name__ == '__main__':
    app.run(debug=True)
