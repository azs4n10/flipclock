"""Generate the app icon (full + adaptive foreground).

The whole icon IS one flip-clock card: it fills the square, with the number
split across a center seam. Beige Rose palette. The OS rounds the corners.
"""
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
CARD = (232, 213, 196, 255)   # #E8D5C4 Beige Rose card (fills the icon)
DIGIT = (139, 90, 107, 255)   # #8B5A6B dusty rose
SHADOW = (0, 0, 0, 30)        # soft fold shadow

FONT_PATH = "C:/Windows/Fonts/arialbd.ttf"


def render(with_bg, out):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cy = SIZE / 2

    if with_bg:
        # Full-bleed card; the platform masks/rounds the corners.
        d.rectangle([0, 0, SIZE, SIZE], fill=CARD)
        digit_px = int(SIZE * 0.50)
    else:
        # Adaptive foreground: keep the number inside the center safe zone.
        digit_px = int(SIZE * 0.34)

    font = ImageFont.truetype(FONT_PATH, digit_px)
    text = "12"
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((SIZE / 2 - tw / 2 - bbox[0], cy - th / 2 - bbox[1]), text,
           font=font, fill=DIGIT)

    # Center seam splits the digits (seam = card colour so it reads as the
    # gap between the two flaps) + a soft shadow under the top flap.
    gap = SIZE * 0.011
    d.rectangle([0, cy - gap, SIZE, cy + gap], fill=CARD)
    d.rectangle([0, cy + gap, SIZE, cy + gap + SIZE * 0.012], fill=SHADOW)

    img.save(out)
    print("wrote", out)


render(with_bg=True, out="assets/icon/app_icon.png")
render(with_bg=False, out="assets/icon/app_icon_fg.png")
