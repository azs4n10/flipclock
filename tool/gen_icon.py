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
    card = [m, m + SIZE * 0.06, SIZE - m, SIZE - m - SIZE * 0.06]
    rounded(d, card, radius=int(SIZE * 0.14), fill=CARD)
    cy = (card[1] + card[3]) / 2

    # "12" centered (drawn first; the split seam is layered on top so the
    # digits are visibly cut in half like a real flip clock).
    font = ImageFont.truetype(FONT_PATH, int(SIZE * 0.42))
    text = "12"
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text(
        ((SIZE - tw) / 2 - bbox[0], cy - th / 2 - bbox[1]),
        text,
        font=font,
        fill=DIGIT,
    )

    # Split seam over the digits + a soft shadow under the top flap for depth.
    gap = SIZE * 0.012
    d.rectangle([card[0], cy - gap, card[2], cy + gap], fill=BG)
    d.rectangle([card[0], cy + gap, card[2], cy + gap + SIZE * 0.008],
                fill=(0, 0, 0, 38))

    # Side hinges (the flip mechanism) at the seam, left and right.
    hw, hh = SIZE * 0.045, SIZE * 0.085
    d.rounded_rectangle(
        [card[0] - hw * 0.35, cy - hh / 2, card[0] + hw * 0.65, cy + hh / 2],
        radius=hw * 0.35, fill=DIGIT)
    d.rounded_rectangle(
        [card[2] - hw * 0.65, cy - hh / 2, card[2] + hw * 0.35, cy + hh / 2],
        radius=hw * 0.35, fill=DIGIT)

    img.save(out)
    print("wrote", out)


# Full icon (used for iOS / web / fallback)
render(card_margin=SIZE * 0.16, with_bg=True, out="assets/icon/app_icon.png")
# Adaptive foreground for Android (transparent bg, extra padding for safe zone)
render(card_margin=SIZE * 0.26, with_bg=False, out="assets/icon/app_icon_fg.png")
