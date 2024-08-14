from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import subprocess
import os
import image2json
from letters_dictionary import letters
from json2gcode import GCodeGenerator
from gcode2preview import GCodePreviewGenerator
import serial
from cnc_control import move_spindle, control_spindle, safety_stop, start_execution

app = Flask(__name__)
CORS(app)

# Python scripts for processing
IMAGE2JSON_SCRIPT = 'image2json.py'
JSON2GCODE_SCRIPT = 'json2gcode.py'
GCODE2PREVIEW_SCRIPT = 'gcode2preview.py'

# Temporary files
TEMP_IMAGE_FILE = 'temp_image.png'
TEMP_JSON_FILE = 'temp.json'
TEMP_GCODE_FILE = 'temp.nc'
TEMP_PREVIEW_FILE = 'temp_preview.png'

# Global variable for selected serial port
port_selected = None

# Initialize CNC Machine connection
for i in range(0, 20):
    try:
        ser = serial.Serial(f'/dev/ttyUSB{i}', 115200)
        port_selected = f'/dev/ttyUSB{i}'
        ser.close()
    except:
        continue

if port_selected is None:
    raise Exception('No available serial port found')

ser = serial.Serial(
    port=port_selected,
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=1
)
print(f'Connected to {port_selected}')

@app.route('/', methods=['GET'])
def index():
    """
    Provides a welcome message and information about available API endpoints.

    Returns:
    - str: Welcome message with instructions for using API endpoints.
    """
    return (
        "Welcome to the API! Here are the endpoints you can use:\n"
        "1. POST /process - Process an image through the entire pipeline\n"
        "2. POST /move - Move the CNC machine spindle\n"
        "3. POST /control - Control the CNC machine spindle\n\n"
        "To use these endpoints, send a POST request with the appropriate data."
    )

@app.route('/process', methods=['POST'])
def process_image():
    """
    Processes an image by converting it to JSON, generating G-code from JSON, 
    and creating a preview image of the G-code. 

    - Accepts image file upload.
    
    Returns:
    - JSON response with status of processing and file completion messages.
    """
    # Process the image
    image_file = request.files.get('image')
    if not image_file:
        return jsonify({"error": "No image file provided"}), 400
    image_file.save(TEMP_IMAGE_FILE)
    
    # Convert the image to JSON (extracted information)
    try:
        reader = image2json.BusinessCardReader()
        image_path = "temp_image.png"
        categorized_data = reader.process_image(image_path)
        reader.save_as_json(categorized_data, "temp.json")
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during image2json execution: {str(e)}"}), 500
    
    # Convert JSON to G-code
    try:
        generator = GCodeGenerator(letters)
        generator.generate_gcode_from_json(TEMP_JSON_FILE, TEMP_GCODE_FILE)
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during json2gcode execution: {str(e)}"}), 500
    
    # Generate G-code preview
    try:
        generator = GCodePreviewGenerator()
        generator.generate_preview()
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during gcode2preview execution: {str(e)}"}), 500
    
    # Return the results review
    return jsonify({
        "message": "Processing complete",
        "json_file": "Done!",
        "gcode_file": "Done!",
        "preview_file": "Done!"
    }), 200

@app.route('/json', methods=['GET'])
def getJson():
    """
    Provides the temporary JSON file generated from image processing.

    Returns:
    - JSON file: The JSON file if it exists.
    - JSON response: Error message if file not found.
    """
    try:
        file_path = '/home/industrie/Documents/CNCMachine/backend'
        file_name = 'temp.json'
        full_path = os.path.join(file_path, file_name)
        if not os.path.exists(full_path):
            return jsonify({"error": "No JSON file found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return send_from_directory(file_path, file_name), 200

@app.route('/nc', methods=['GET'])
def get_nc():
    """
    Provides the temporary G-code file generated from JSON.

    Returns:
    - G-code file: The G-code file if it exists.
    - JSON response: Error message if file not found.
    """
    try:
        file_path = '/home/industrie/Documents/CNCMachine/backend'
        file_name = 'temp.nc'
        full_path = os.path.join(file_path, file_name)
        if not os.path.exists(full_path):
            return jsonify({"error": "No NC file found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return send_from_directory(file_path, file_name), 200

@app.route('/preview', methods=['GET'])
def get_image():
    """
    Provides the temporary preview image of the G-code.

    Returns:
    - Image file: The preview image if it exists.
    - JSON response: Error message if file not found.
    """
    try:
        file_path = '/home/industrie/Documents/CNCMachine/backend'
        file_name = 'temp_preview.png'
        full_path = os.path.join(file_path, file_name)
        if not os.path.exists(full_path):
            return jsonify({"error": "No image file found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return send_from_directory(file_path, file_name), 200

@app.route('/processJson', methods=['POST'])
def process_json():
    """
    Processes a JSON file by generating G-code from it and creating a preview image.

    - Accepts JSON file upload.
    
    Returns:
    - JSON response with status of processing and file completion messages.
    """
    json_file = request.files.get('json')
    if not json_file:
        return jsonify({"error": "No json file provided"}), 400

    json_file.save(TEMP_JSON_FILE)
    
    try:
        generator = GCodeGenerator(letters)
        generator.generate_gcode_from_json(TEMP_JSON_FILE, TEMP_GCODE_FILE)
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during json2gcode execution: {str(e)}"}), 500
    
    try:
        generator = GCodePreviewGenerator()
        generator.generate_preview()
    except subprocess.CalledProcessError as e:
        return jsonify({"error": f"Error during gcode2preview execution: {str(e)}"}), 500
    
    return jsonify({
        "message": "Processing complete",
        "gcode_file": "Done!",
        "preview_file": "Done!"
    }), 200

@app.route('/updateJson', methods=['POST'])
def update_json():
    """
    Updates the temporary JSON file with a new upload.

    - Accepts JSON file upload.
    
    Returns:
    - JSON response with status of the update.
    """
    json_file = request.files.get('json')
    if not json_file:
        return jsonify({"error": "No json file provided"}), 400
    json_file.save(TEMP_JSON_FILE)
    return jsonify({"message": "JSON file updated"}), 200

@app.route('/move', methods=['POST'])
def move():
    """
    Moves the CNC machine spindle along a specified axis by a given increment in a specified direction.

    - Accepts JSON body with axis, increment, and direction.
    
    Returns:
    - JSON response with status of the move operation.
    """
    data = request.json
    axis = data.get('axis')
    increment = data.get('increment')
    direction = data.get('direction')
    
    try:
        move_spindle(axis, increment, direction, ser)
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    return jsonify({"message": f"Moved {axis} {direction} by {increment} mm"}), 200

@app.route('/control', methods=['POST'])
def control():
    """
    Controls the CNC machine spindle based on the provided command.

    - Accepts JSON body with command (start, stop, or set).
    
    Returns:
    - JSON response with status of the control command.
    """
    data = request.json
    command = data.get('command')
    
    try:
        control_spindle(command, ser)
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    return jsonify({"message": f"Command '{command}' executed"}), 200

@app.route('/safety', methods=['POST'])
def safety():
    """
    Raises the spindle to the maximum height for safety and stops CNC operations.

    Returns:
    - JSON response with status of the safety stop.
    """
    try:
        safety_stop(ser)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return jsonify({"message": "Spindle raised to maximum height for safety"}), 200

@app.route('/runGcode', methods=['POST'])
def runGCode():
    """
    Starts the execution of the G-code file.

    Returns:
    - JSON response with status of the G-code execution.
    """
    try:
        start_execution(TEMP_GCODE_FILE, ser)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
