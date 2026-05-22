"""Generate the app icon (full + adaptive foreground) in the default
Beige Rose palette. Clean flip-card with "12" and a center divider — no
overlapping heart, so it reads clearly at small sizes."""
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
BG = (245, 235, 224, 255)        # #F5EBE0 beige (Beige Rose background)
CARD = (255, 255, 255, 255)      # white card (pops on beige)
DIGIT = (139, 90, 107, 255)      # #8B5A6B dusty rose (Beige Rose numbers)
DIVIDER = (224, 208, 192, 255)   # soft beige divider

FONT_PATH = "C:/Windows/Fonts/arialbd.ttf"


def rounded(draw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def render(card_margin, with_bg, out):
    img = Image.new("RGBA", (SIZE, SIZE), BG if with_bg else (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    m = card_margin
    x0, x1 = m, SIZE - m
    y0, y1 = m + SIZE * 0.06, SIZE - m - SIZE * 0.06
    cy = (y0 + y1) / 2
    radius = int(SIZE * 0.14)
    gap = SIZE * 0.012  # small seam between the two flaps

    # Two stacked flaps (top + bottom) with a thin seam between them — the
    # shape of a real split-flap card. Outer corners rounded, inner edges flat.
    d.rounded_rectangle([x0, y0, x1, cy - gap], radius=radius, fill=CARD,
                        corners=(True, True, False, False))
    d.rounded_rectangle([x0, cy + gap, x1, y1], radius=radius, fill=CARD,
                        corners=(False, False, True, True))
    # soft shadow cast by the top flap onto the bottom flap
    d.rectangle([x0, cy + gap, x1, cy + gap + SIZE * 0.012], fill=(0, 0, 0, 28))

    # "12" centered, then re-cut the seam over it so the digits split.
    font = ImageFont.truetype(FONT_PATH, int(SIZE * 0.40))
    text = "12"
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text(((SIZE - tw) / 2 - bbox[0], cy - th / 2 - bbox[1]), text,
           font=font, fill=DIGIT)
    d.rectangle([x0, cy - gap, x1, cy + gap], fill=BG)
    d.rectangle([x0, cy + gap, x1, cy + gap + SIZE * 0.012], fill=(0, 0, 0, 28))

    img.save(out)
    print("wrote", out)


# Full icon (used for iOS / web / fallback)
render(card_margin=SIZE * 0.16, with_bg=True, out="assets/icon/app_icon.png")
# Adaptive foreground for Android (transparent bg, extra padding for safe zone)
render(card_margin=SIZE * 0.26, with_bg=False, out="assets/icon/app_icon_fg.png")
