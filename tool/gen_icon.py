"""Generate the yumekawa app icon (full + adaptive foreground)."""
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
BG = (252, 231, 243, 255)        # #FCE7F3 light pink
CARD = (255, 255, 255, 255)      # white
DIGIT = (190, 90, 143, 255)      # #BE5A8F dusty pink
DIVIDER = (245, 210, 225, 255)   # #F5D2E1
HEART = (248, 165, 194, 255)     # #F8A5C2 coral pink

FONT_PATH = "C:/Windows/Fonts/arialbd.ttf"


def rounded(draw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def draw_heart(draw, cx, cy, s, color):
    # two lobes + lower triangle
    r = s * 0.5
    draw.ellipse([cx - s, cy - r, cx, cy + r], fill=color)
    draw.ellipse([cx, cy - r, cx + s, cy + r], fill=color)
    draw.polygon(
        [(cx - s, cy + r * 0.2), (cx + s, cy + r * 0.2), (cx, cy + s * 1.25)],
        fill=color,
    )


def render(card_margin, with_bg, out):
    img = Image.new("RGBA", (SIZE, SIZE), BG if with_bg else (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    m = card_margin
    card = [m, m + SIZE * 0.06, SIZE - m, SIZE - m - SIZE * 0.06]
    rounded(d, card, radius=int(SIZE * 0.14), fill=CARD)

    # divider through the middle of the card
    cy = (card[1] + card[3]) / 2
    d.rectangle([card[0], cy - 4, card[2], cy + 4], fill=DIVIDER)

    # "12" centered
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

    # little heart at top-right of the card
    draw_heart(d, card[2] - SIZE * 0.16, card[1] + SIZE * 0.16, SIZE * 0.06, HEART)

    img.save(out)
    print("wrote", out)


# Full icon (used for iOS / web / fallback)
render(card_margin=SIZE * 0.16, with_bg=True, out="assets/icon/app_icon.png")
# Adaptive foreground for Android (transparent bg, extra padding for safe zone)
render(card_margin=SIZE * 0.26, with_bg=False, out="assets/icon/app_icon_fg.png")
