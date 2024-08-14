from letters_dictionary import letters
import json

class GCodeGenerator:
    """
    A class to generate G-code for CNC or 3D printing machines from text inputs, 
    with customizable parameters for scaling, spacing, and tool settings.

    Attributes:
    - letters_dict (dict): A dictionary containing letter coordinates for G-code generation.
    - scale (float): A scaling factor for the coordinates of each letter.
    - spacing (float): The horizontal spacing between letters.
    - y_line_spacing (float): The vertical spacing between lines of text.
    - speed_needle (int): The speed setting for the spindle or needle.
    - depth (float): The depth of the tool for engraving or cutting.
    """
    
    def __init__(self, letters_dict, scale=1, spacing=1.5, y_line_spacing=3.5, speed_needle=8000, depth=0.15):
        """
        Initializes the GCodeGenerator with customizable parameters.

        Parameters:
        - letters_dict (dict): Dictionary containing coordinates for each letter.
        - scale (float): Scale factor for resizing the letters (default: 1).
        - spacing (float): Horizontal space between letters (default: 1.5).
        - y_line_spacing (float): Vertical space between lines of text (default: 3.5).
        - speed_needle (int): Speed of the tool head (default: 8000).
        - depth (float): Depth of the tool movement into the material (default: 0.15).
        """
        self.letters_dict = letters_dict
        self.scale = scale
        self.spacing = spacing
        self.y_line_spacing = y_line_spacing
        self.speed_needle = speed_needle
        self.depth = depth

    def generate_gcode(self, text):
        """
        Generates G-code based on the provided text input. The text is converted into
        G-code commands that control a CNC or 3D printer to engrave or draw the text.

        Parameters:
        - text (str): The input text that needs to be converted into G-code.

        Returns:
        - str: The G-code as a single string with line breaks between commands.

        Notes:
        - The method handles line breaks ('\n') in the text to create multiline engravings.
        - Letters not found in the dictionary will be skipped.
        """
        gcode = []
        gcode.append("G21") # Set units to millimeters
        gcode.append("G90") # Absolute positioning
        gcode.append(f"M3 S{self.speed_needle}") # Start spindle or needle at specified speed
        
        x_offset = 0
        y_offset = 0

        if '\n' in text:
            lines = text.split('\n')
            y_offset += (len(lines) - 1) * self.y_line_spacing * self.scale

        for letter in text:
            if letter == '\n':
                y_offset -= self.y_line_spacing * self.scale
                x_offset = 0
                continue

            if letter in self.letters_dict:
                coordinates = self.letters_dict[letter]
            elif letter.upper() in self.letters_dict:
                coordinates = self.letters_dict[letter.upper()]
            else:
                continue

            first = True
            for coord in coordinates:
                if coord == 'lift':
                    gcode.append("G0 Z2")
                    x1, y1 = coordinates[coordinates.index(coord) + 1]
                    x1 = x1 * self.scale + x_offset
                    y1 = y1 * self.scale + y_offset
                    gcode.append(f"G0 X{x1} Y{y1} F228.6")
                    gcode.append(f"G0 Z-{self.depth}")
                    continue
                
                x, y = coord
                x = x * self.scale + x_offset
                y = y * self.scale + y_offset

                if first:
                    gcode.append(f"G0 X{x} Y{y} Z0 F228.6")
                    first = False
                else:
                    gcode.append(f"G1 X{x} Y{y} Z-{self.depth} F228.6")

            gcode.append("G0 Z2")
            x_offset += self.spacing * self.scale
        
        gcode.append("G0 Z4")
        gcode.append("G0 X0 Y0")
        gcode.append("M5")
        
        return "\n".join(gcode)

    def json_to_text(self, json_data):
        """
        Converts a JSON object into a text string. Each key-value pair in the JSON
        is converted into a formatted string, where each key-value pair is placed on a new line.

        Parameters:
        - json_data (dict): The JSON data to be converted into text.

        Returns:
        - str: The formatted text representation of the JSON data, with key-value pairs on separate lines.
        
        Notes:
        - Keys with `None` or empty string values are ignored in the output.
        """
        text = ""
        for key, value in json_data.items():
            if value is not None and value != "": 
                text += f"\n{key}: {value}"
        return text

    def json_file_to_text(self, json_file):
        """
        Reads a JSON file and converts it into a formatted text string.

        Parameters:
        - json_file (str): The path to the JSON file that needs to be converted.

        Returns:
        - str: The formatted text representation of the JSON file content.
        """
        with open(json_file, 'r') as file:
            json_data = json.load(file)
        return self.json_to_text(json_data)

    def generate_gcode_from_json(self, json_file, output_file):
        """
        Reads text data from a JSON file, converts it into G-code, and writes the G-code to an output file.

        Parameters:
        - json_file (str): The path to the JSON file containing the text data.
        - output_file (str): The path where the generated G-code should be saved.
        """
        text_from_file = self.json_file_to_text(json_file)
        gcode = self.generate_gcode(text_from_file)
        with open(output_file, 'w') as file:
            file.write(gcode)
