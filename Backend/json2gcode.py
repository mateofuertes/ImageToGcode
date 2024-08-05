from letters_dictionary import letters
import json

class GCodeGenerator:
    def __init__(self, letters_dict, scale=1, spacing=1.5, y_line_spacing=3.5, speed_needle=8000, depth=0.15):
        self.letters_dict = letters_dict
        self.scale = scale
        self.spacing = spacing
        self.y_line_spacing = y_line_spacing
        self.speed_needle = speed_needle
        self.depth = depth

    def generate_gcode(self, text):
        gcode = []
        gcode.append("G21")
        gcode.append("G90")
        gcode.append(f"M3 S{self.speed_needle}")
        
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
        text = ""
        for key, value in json_data.items():
            if value is not None and value != "": 
                text += f"\n{key}: {value}"
        return text

    def json_file_to_text(self, json_file):
        with open(json_file, 'r') as file:
            json_data = json.load(file)
        return self.json_to_text(json_data)

    def generate_gcode_from_json(self, json_file, output_file):
        text_from_file = self.json_file_to_text(json_file)
        gcode = self.generate_gcode(text_from_file)
        with open(output_file, 'w') as file:
            file.write(gcode)
