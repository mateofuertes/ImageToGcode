import re
from PIL import Image, ImageDraw

class GCodePreviewGenerator:
    def __init__(self, card_width=85, card_height=54, scale_factor=10, background_color='#deb887'):
        self.card_width = card_width
        self.card_height = card_height
        self.scale_factor = scale_factor
        self.background_color = background_color
        
        self.img_width = int(self.card_width * self.scale_factor)
        self.img_height = int(self.card_height * self.scale_factor)
        
    def parse_gcode(self, draw, gcode, x_offset=0, y_offset=0):
        lines = gcode.strip().split('\n')
        current_position = [0, 0]

        for line in lines:
            # Skip comments and empty lines
            if line.startswith(';') or not line.strip():
                continue

            # Parse G0 and G1 commands
            if line.startswith('G0') or line.startswith('G1'):
                try:
                    # Extract X and Y coordinates
                    x_match = re.search(r'X([-+]?[0-9]*\.?[0-9]+)', line)
                    y_match = re.search(r'Y([-+]?[0-9]*\.?[0-9]+)', line)
                    
                    x = float(x_match.group(1)) * self.scale_factor if x_match else current_position[0]
                    y = float(y_match.group(1)) * self.scale_factor if y_match else current_position[1]
                    
                    new_position = [x + x_offset, y + y_offset]

                    # Draw line for G1 (cutting)
                    if line.startswith('G1'):
                        try:
                            draw.line([tuple(current_position), tuple(new_position)], fill='black', width=2)
                        except ValueError as e:
                            print(f"Error drawing line: {e}")

                    # Update current position
                    current_position = new_position
                except ValueError as e:
                    print(f"Error parsing coordinates: {e}")

    def mirror_image(self, image):
        mirrored_image = Image.new('RGB', (self.img_width, self.img_height), self.background_color)
        mirrored_draw = ImageDraw.Draw(mirrored_image)
        
        # Draw the original content
        mirrored_image.paste(image, (0, 0))
        
        # Mirror horizontally
        for x in range(self.img_width):
            for y in range(self.img_height):
                color = image.getpixel((x, y))
                mirrored_draw.point((self.img_width - x - 1, y), fill=color)
        
        # Mirror vertically
        for x in range(self.img_width):
            for y in range(self.img_height):
                color = image.getpixel((x, y))
                mirrored_draw.point((x, self.img_height - y - 1), fill=color)
        
        return mirrored_image

    def generate_preview(self, gcode_file='temp.nc', output_image='temp_preview.png'):
        # Initialize the canvas with the bamboo color
        image = Image.new('RGB', (self.img_width, self.img_height), self.background_color)
        draw = ImageDraw.Draw(image)
        
        # Read the G-code and draw the content
        with open(gcode_file, 'r') as file:
            gcode_data = file.read()
        
        # Parse G-code to draw the original content
        self.parse_gcode(draw, gcode_data)
        
        # Mirror the content and save
        mirrored_image = self.mirror_image(image)
        mirrored_image.save(output_image)
        #mirrored_image.show()