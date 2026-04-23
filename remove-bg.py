#!/usr/bin/env python3
"""Remove background from an image using BiRefNet via rembg.
Usage: remove-bg.py <input-image> <output-png>
First run downloads ~400MB model weights.
"""
import sys
from rembg import remove, new_session
from PIL import Image

if len(sys.argv) < 3:
    print("Usage: remove-bg.py <input-image> <output-png>", file=sys.stderr)
    sys.exit(1)

input_path = sys.argv[1]
output_path = sys.argv[2]

print(f"Processing: {input_path}", file=sys.stderr)
session = new_session("birefnet-general")
result = remove(Image.open(input_path), session=session)
result.save(output_path)
print(f"Saved: {output_path}", file=sys.stderr)
