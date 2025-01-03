from PIL import Image
import argparse

def load_sprite_data_from_file(filename="sprite_map.txt"):
    # Read sprite data from the text file
    with open(filename, 'r') as file:
        sprite_data_lines = file.readlines()

    # Remove the memory address part and concatenate the remaining data
    sprite_data_hex = "".join(line.split(': ')[1].replace(" ", "") for line in sprite_data_lines)

    # Convert the hex data to a byte array
    sprite_data = bytes.fromhex(sprite_data_hex)
    
    return sprite_data

def create_image_from_sprite_data(sprite_data):
    # Define constants for the sprite image
    BYTES_PER_ROW = 32
    BITS_PER_PIXEL = 2
    PIXELS_PER_BYTE = 8 // BITS_PER_PIXEL  # 4 pixels per byte
    IMAGE_WIDTH = BYTES_PER_ROW * PIXELS_PER_BYTE

    # Calculate the number of rows (height) based on the total data length and bytes per row
    IMAGE_HEIGHT = len(sprite_data) // BYTES_PER_ROW

    # Create a new grayscale image for the sprite
    image = Image.new('P', (IMAGE_WIDTH, IMAGE_HEIGHT))

    # Define a new 4-color palette: Black, Red, Green, White
    palette = [0, 0, 0,      # Black (R, G, B)
               255, 0, 0,    # Red (R, G, B)
               0, 255, 0,    # Green (R, G, B)
               255, 255, 255]# White (R, G, B)

    # Set palette for the image (P mode requires 256 colors, hence repeat to fill)
    image.putpalette(palette * 64)

    # Load pixel data into the image
    pixels = image.load()

    # Iterate over the sprite data and set pixel values
    for y in range(IMAGE_HEIGHT):
        for x_byte in range(BYTES_PER_ROW):
            byte_index = y * BYTES_PER_ROW + x_byte
            if byte_index < len(sprite_data):
                byte = sprite_data[byte_index]
                
                # Extract each pair of bits (2-bit pixels) from the byte
                pixel_values = [
                # Extract pixel values based on the bit masks provided
                    (byte & 0b10000000) >> 6 | (byte & 0b00001000) >> 3,  # Mask 0x88, extract two bits and shift accordingly
                    (byte & 0b01000000) >> 5 | (byte & 0b00000100) >> 2,  # Mask 0x44, extract two bits and shift accordingly
                    (byte & 0b00100000) >> 4 | (byte & 0b00000010) >> 1,  # Mask 0x22, extract two bits and shift accordingly
                    (byte & 0b00010000) >> 3 | (byte & 0b00000001)       # Mask 0x11, extract two bits and shift accordingly
                ]

                # Set the pixel values directly without using a stack
                for bit_index, pixel_value in enumerate(pixel_values):
                    # Calculate the actual x position in the image
                    x = x_byte * PIXELS_PER_BYTE + bit_index
                    # Set the pixel value
                    pixels[x, y] = pixel_value

    return image

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Generate a bitmap from sprite data.")
    parser.add_argument('--file', type=str, default='sprite_map.txt', help='Path to the sprite data file')
    args = parser.parse_args()

    # Load sprite data from file
    sprite_data = load_sprite_data_from_file(args.file)

    # Create image from sprite data
    image = create_image_from_sprite_data(sprite_data)

    # Save the image to a file
    image.save('sprite_bitmap.png')

    # Show the image for verification
    image.show()

if __name__ == "__main__":
    main()
