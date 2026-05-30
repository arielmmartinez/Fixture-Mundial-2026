import os
from PIL import Image

image_path = "/Users/arielmartinez/antigravity/Fixture-Mundial-2026/fixture_flutter/assets/images/paises_mockup.png"
if not os.path.exists(image_path):
    print("Image not found")
    sys.exit(1)

img = Image.open(image_path).convert("L")
width, height = img.size

# Analyze 64 strips
strip_height = 26
num_strips = height // strip_height

print(f"Analyzing {num_strips} strips of height {strip_height} (Image dimensions: {width}x{height})...")

for i in range(num_strips):
    y_start = i * strip_height
    y_end = y_start + strip_height
    
    pixels = []
    for y in range(y_start, y_end):
        for x in range(0, width):
            pixels.append(img.getpixel((x, y)))
            
    avg_brightness = sum(pixels) / len(pixels)
    
    diff_sum = 0
    for y in range(y_start, y_end):
        row_pixels = [img.getpixel((x, y)) for x in range(0, width)]
        for x in range(width - 1):
            diff_sum += abs(row_pixels[x] - row_pixels[x+1])
            
    edge_density = diff_sum / (width * strip_height)
    
    y_1024 = int(y_start * 1024 / height)
    print(f"y_1024: {y_1024:3d} (y_raw: {y_start:4d}) | Brightness: {avg_brightness:6.2f} | Edges: {edge_density:6.2f}")
