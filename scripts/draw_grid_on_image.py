from PIL import Image, ImageDraw
import sys
import traceback

def draw_grid(input_filename, output_filename, grid_x_start, grid_y_start, major_grid_size=32, minor_grid_size=8, major_grey_level=200, minor_grey_level=150, transparency=128):
    try:
        # Load the image
        image = Image.open(input_filename)
        
        # Ensure the image is in a mode that supports transparency and has a useful bit depth
        if image.mode not in ['RGBA', 'RGB']:
            image = image.convert('RGBA')
        
        # Create a new drawing layer to maintain transparency
        overlay = Image.new('RGBA', image.size, (255, 255, 255, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Get image dimensions
        width, height = image.size
        
        # Set major and minor grid line colors with given transparency
        major_line_color = (major_grey_level, major_grey_level, major_grey_level, transparency)
        minor_line_color = (minor_grey_level, minor_grey_level, minor_grey_level, transparency)
        
        # Draw minor vertical grid lines to the right of the starting point
        x = grid_x_start
        while x < width:
            draw.line((x, 0, x, height), fill=minor_line_color, width=1)
            x += minor_grid_size
        
        # Draw minor vertical grid lines to the left of the starting point
        x = grid_x_start
        while x >= 0:
            draw.line((x, 0, x, height), fill=minor_line_color, width=1)
            x -= minor_grid_size
        
        # Draw minor horizontal grid lines below the starting point
        y = grid_y_start
        while y < height:
            draw.line((0, y, width, y), fill=minor_line_color, width=1)
            y += minor_grid_size
        
        # Draw minor horizontal grid lines above the starting point
        y = grid_y_start
        while y >= 0:
            draw.line((0, y, width, y), fill=minor_line_color, width=1)
            y -= minor_grid_size
        
        # Draw major vertical grid lines to the right of the starting point
        x = grid_x_start
        while x < width:
            draw.line((x, 0, x, height), fill=major_line_color, width=1)
            x += major_grid_size
        
        # Draw major vertical grid lines to the left of the starting point
        x = grid_x_start
        while x >= 0:
            draw.line((x, 0, x, height), fill=major_line_color, width=1)
            x -= major_grid_size
        
        # Draw major horizontal grid lines below the starting point
        y = grid_y_start
        while y < height:
            draw.line((0, y, width, y), fill=major_line_color, width=1)
            y += major_grid_size
        
        # Draw major horizontal grid lines above the starting point
        y = grid_y_start
        while y >= 0:
            draw.line((0, y, width, y), fill=major_line_color, width=1)
            y -= major_grid_size
        
        # Composite the overlay with the original image
        image = Image.alpha_composite(image.convert('RGBA'), overlay)
        
        # Save the output image
        image.save(output_filename)
        print(f"Grid drawn and saved to {output_filename}")
    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    # Example usage
    if len(sys.argv) < 5 or len(sys.argv) > 10:
        print("Usage: python draw_grid.py <input_filename> <output_filename> <grid_x_start> <grid_y_start> [<major_grid_size> <minor_grid_size> <major_grey_level> <minor_grey_level> <transparency>]")
        sys.exit(1)
    
    input_filename = sys.argv[1]
    output_filename = sys.argv[2]
    grid_x_start = int(sys.argv[3])
    grid_y_start = int(sys.argv[4])
    
    major_grid_size = int(sys.argv[5]) if len(sys.argv) > 5 else 32
    minor_grid_size = int(sys.argv[6]) if len(sys.argv) > 6 else 8
    major_grey_level = int(sys.argv[7]) if len(sys.argv) > 7 else 200
    minor_grey_level = int(sys.argv[8]) if len(sys.argv) > 8 else 64
    transparency = int(sys.argv[9]) if len(sys.argv) > 9 else 128
    
    draw_grid(input_filename, output_filename, grid_x_start, grid_y_start, major_grid_size=major_grid_size, minor_grid_size=minor_grid_size, major_grey_level=major_grey_level, minor_grey_level=minor_grey_level, transparency=transparency)
