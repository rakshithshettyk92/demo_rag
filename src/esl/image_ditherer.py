"""
src/esl/image_ditherer.py
--------------------------
Floyd-Steinberg error-diffusion dithering for ESL label color palettes.

Each ESL label type supports a specific set of ink colors (e.g. 4_COLOR supports
black, white, red, yellow).  This module converts any uploaded image to use only
those colors, producing a dithered result that looks good on e-ink displays.
"""

import numpy as np
from PIL import Image

# Named palette colors → sRGB tuples (calibrated for e-ink appearance)
PALETTE_RGB: dict[str, tuple[int, int, int]] = {
    "black":  (0,   0,   0),
    "white":  (255, 255, 255),
    "red":    (220, 30,  30),
    "yellow": (255, 215, 0),
    "orange": (255, 140, 0),
    "green":  (0,   160, 0),
    "blue":   (0,   0,   220),
    "pink":   (255, 150, 180),
    "gray":   (128, 128, 128),
}


def get_palette_for_color_type(color_type: str) -> list[tuple[int, int, int]]:
    """
    Return the list of (R, G, B) tuples for a given ESL color support type key
    (e.g. "4_COLOR", "BINARY", "7_COLOR").
    """
    from src.esl.label_registry import COLOR_SUPPORT_TYPES
    color_names = COLOR_SUPPORT_TYPES.get(color_type, ["black", "white"])
    # "transparent" has no ink equivalent — skip it
    return [PALETTE_RGB[c] for c in color_names if c in PALETTE_RGB]


def dither_to_palette(
    img: Image.Image,
    palette: list[tuple[int, int, int]],
    max_size: tuple[int, int] = (400, 400),
) -> Image.Image:
    """
    Apply Floyd-Steinberg error-diffusion dithering to restrict an image to
    the supplied color palette.

    Args:
        img:      Input PIL Image (any mode — will be converted to RGB).
        palette:  Target palette as a list of (R, G, B) tuples.
        max_size: Images larger than this are resized before dithering
                  to keep processing time reasonable.

    Returns:
        Dithered PIL Image in RGB mode.
    """
    img = img.convert("RGB")

    # Resize proportionally if the image is too large
    if img.width > max_size[0] or img.height > max_size[1]:
        img.thumbnail(max_size, Image.LANCZOS)

    pixels = np.array(img, dtype=np.float32)
    h, w, _ = pixels.shape
    pal = np.array(palette, dtype=np.float32)

    for y in range(h):
        for x in range(w):
            old_px = np.clip(pixels[y, x], 0, 255)

            # Find nearest palette entry by Euclidean distance in RGB space
            diffs   = np.sum((pal - old_px) ** 2, axis=1)
            nearest = pal[np.argmin(diffs)]

            pixels[y, x] = nearest
            error = old_px - nearest

            # Distribute quantization error using Floyd-Steinberg coefficients
            if x + 1 < w:
                pixels[y, x + 1] = np.clip(pixels[y, x + 1] + error * 7 / 16, 0, 255)
            if y + 1 < h:
                if x > 0:
                    pixels[y + 1, x - 1] = np.clip(
                        pixels[y + 1, x - 1] + error * 3 / 16, 0, 255
                    )
                pixels[y + 1, x] = np.clip(pixels[y + 1, x] + error * 5 / 16, 0, 255)
                if x + 1 < w:
                    pixels[y + 1, x + 1] = np.clip(
                        pixels[y + 1, x + 1] + error * 1 / 16, 0, 255
                    )

    return Image.fromarray(pixels.astype(np.uint8), "RGB")
