#!/usr/bin/env python3
"""Convert a 64x64 PNG image to row-major RGB888 Verilog $readmemh data."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


def convert_png(input_path: Path, output_path: Path) -> None:
    try:
        from PIL import Image
    except ImportError as exc:
        raise RuntimeError(
            "Pillow is required. Install it with: python -m pip install Pillow"
        ) from exc

    with Image.open(input_path) as source:
        if source.size != (64, 64):
            canvas = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
            canvas.paste(source, (32, 32))
            source = canvas
        # Read the decoded RGB pixels directly. No resize or resampling is done.
        # If the PNG contains alpha, discard that channel without blending RGB.
        rgb = source.convert("RGB")
        pixels = [f"{red:02x}{green:02x}{blue:02x}" for red, green, blue in rgb.getdata()]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(pixels) + "\n", encoding="ascii")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Convert a 64x64 PNG to 4096 RGB888 hex words."
    )
    parser.add_argument("input_png", type=Path, help="PNG file to convert")
    parser.add_argument("output_hex", type=Path, help="Output .hex file")
    args = parser.parse_args()

    try:
        convert_png(args.input_png, args.output_hex)
    except (OSError, RuntimeError, ValueError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    print(f"Wrote 4096 RGB888 pixels to {args.output_hex}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
