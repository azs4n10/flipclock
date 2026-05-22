"""Generate the app icon (full + adaptive foreground).

The whole icon is one flip-clock card. The fold is shown by two slightly
different tones (top flap a touch lighter, bottom a touch darker) plus a soft
shadow at the seam — not a hard full-width bar. Beige Rose palette.
"""
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
CARD = (230, 212, 194, 255)   # #E6D4C2 Beige Rose card tone (fills the icon)
DIGIT = (139, 90, 107, 255)   # #8B5A6B dusty rose
FONT_PATH = "C:/Windows/Fonts/arialbd.ttf"


def render(with_bg, out):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cy = int(SIZE / 2)

    if with_bg:
        d.rectangle([0, 0, SIZE, SIZE], fill=CARD)
        digit_px = int(SIZE * 0.52)
    else:
        digit_px = int(SIZE * 0.34)  # adaptive fg: keep within safe zone

    font = ImageFont.truetype(FONT_PATH, digit_px)
    text = "12"
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((SIZE / 2 - tw / 2 - bbox[0], cy - th / 2 - bbox[1]), text,
           font=font, fill=DIGIT)

    # Thin, soft, dark seam (the flip-card fold) only on the full card icon.
    # The transparent foreground (splash + Android adaptive) stays clean so no
    # stray line sticks out past the digits like a strikethrough.
    if with_bg:
        seam = max(3, int(SIZE * 0.006))
        d.rectangle([0, cy - seam / 2, SIZE, cy + seam / 2],
                    fill=(110, 82, 74, 105))

    img.save(out)
    print("wrote", out)


render(with_bg=True, out="assets/icon/app_icon.png")
render(with_bg=False, out="assets/icon/app_icon_fg.png")
