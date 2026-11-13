#!/usr/bin/env python3
"""Convert a 64x64 PNG image to row-major Verilog $readmemh data with dynamic bit-depth support."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


def parse_format_bits(format_str: str) -> tuple[int, int, int]:
    """Dynamically extracts bit depths from format strings like 'rgb888', 'rgb565', 'rgb444', etc."""
    format_str = format_str.lower().strip()
    
    if format_str.startswith("rgb") and len(format_str) == 6 and format_str[3:].isdigit():
        return int(format_str[3]), int(format_str[4]), int(format_str[5])
    
    presets = {
        "rgb888": (8, 8, 8),
        "rgb565": (5, 6, 5),
        "rgb444": (4, 4, 4),
        "rgb332": (3, 3, 2),
    }
    return presets.get(format_str, (8, 8, 8))


def pixel_to_hex(r: int, g: int, b: int, r_bits: int, g_bits: int, b_bits: int) -> str:
    max_r = (1 << r_bits) - 1
    max_g = (1 << g_bits) - 1
    max_b = (1 << b_bits) - 1
    
    scaled_r = round((r / 255.0) * max_r)
    scaled_g = round((g / 255.0) * max_g)
    scaled_b = round((b / 255.0) * max_b)
    
    val = (scaled_r << (g_bits + b_bits)) | (scaled_g << b_bits) | scaled_b
    
    total_bits = r_bits + g_bits + b_bits
    hex_width = (total_bits + 3) // 4
    
    return f"{val:0{hex_width}x}"


def convert_png(input_path: Path, output_path: Path, format_type: str) -> int:
    try:
        from PIL import Image
    except ImportError as exc:
        raise RuntimeError(
            "Pillow is required. Install it with: python -m pip install Pillow"
        ) from exc

    r_bits, g_bits, b_bits = parse_format_bits(format_type)
    pixel_count = 0

    with Image.open(input_path) as source:
        if source.size != (64, 64):
            canvas = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
            canvas.paste(source, (32, 32))
            source = canvas
            
        rgb = source.convert("RGB")
        pixel_count = rgb.width * rgb.height
        
        pixels = [
            pixel_to_hex(red, green, blue, r_bits, g_bits, b_bits) 
            for red, green, blue in rgb.getdata()
        ]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(pixels) + "\n", encoding="ascii")
    return pixel_count


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert a 64x64 PNG to Verilog $readmemh hex words with dynamic format support."
    )
    parser.add_argument("input_png", type=Path, help="PNG file to convert")
    parser.add_argument("output_hex", type=Path, help="Output .hex file")
    parser.add_argument(
        "-f", "--format", 
        default="rgb888", 
        help="Color format (e.g., rgb888, rgb565, rgb444, rgb332, or custom like rgb666)"
    )
    args = parser.parse_args()

    try:
        count = convert_png(args.input_png, args.output_hex, args.format)
    except (OSError, RuntimeError, ValueError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    print(f"Wrote {count} {args.format.upper()} pixels to {args.output_hex}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
