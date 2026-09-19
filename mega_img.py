from PIL import Image
import os

# Nombres de tus imágenes
IMAGES = ["eeee.png", "kir.jpg", "original_image.jpg", "original_image_.jpg"]
OUTPUT = "multi_image.hex"

print(f"Creando paquete de imágenes: {OUTPUT}")

with open(OUTPUT, 'w') as f:
    for idx, filename in enumerate(IMAGES):
        if os.path.exists(filename):
            print(f"[{idx}] Procesando {filename}...")
            img = Image.open(filename).convert('RGB')
            img = img.resize((64, 64), Image.Resampling.LANCZOS)
            
            for y in range(64):
                for x in range(64):
                    r, g, b = img.getpixel((x, y))
                    f.write(f"{r:02X}{g:02X}{b:02X}\n")
        else:
            print(f"[{idx}] No encontré {filename}. Rellenando con negro.")
            for _ in range(4096):
                f.write("000000\n")

print("{multi_image} creado.")
