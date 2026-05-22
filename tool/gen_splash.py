"""Generate a nicer splash screen: a soft pastel gradient background with a few
petals, a white flip-card 'logo' showing 12, and an app-name branding strip."""
import math
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

FONT = "C:/Windows/Fonts/arialbd.ttf"
ROSE = (139, 90, 107, 255)


def lerp(a, b, t):
    return int(a + (b - a) * t)


def make_background(out):
    w, h = 1242, 2688
    top = (252, 233, 240)   # soft pink
    bot = (245, 235, 224)   # beige
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        t = y / h
        c = (lerp(top[0], bot[0], t), lerp(top[1], bot[1], t),
             lerp(top[2], bot[2], t))
        for x in range(w):
            px[x, y] = c
    # faint sakura petals scattered softly
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    random.seed(7)
    for _ in range(26):
        cx, cy = random.randint(0, w), random.randint(0, h)
        s = random.randint(26, 60)
        col = random.choice([(248, 165, 194, 60), (255, 192, 226, 55),
                              (255, 214, 232, 60)])
        od.ellipse([cx - s, cy - s * 0.6, cx + s, cy + s * 0.6], fill=col)
    overlay = overlay.filter(ImageFilter.GaussianBlur(2))
    img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
    img.save(out)
    print("wrote", out)


def make_logo(out):
    s = 760
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    m = 70
    card = [m, m + 70, s - m, s - m - 70]
    radius = 70

    # soft drop shadow
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([card[0], card[1] + 22, card[2], card[3] + 22],
                         radius=radius, fill=(120, 85, 80, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(22))
    img = Image.alpha_composite(img, shadow)

    d = ImageDraw.Draw(img)
    d.rounded_rectangle(card, radius=radius, fill=(255, 255, 255, 255))

    cy = (card[1] + card[3]) // 2
    font = ImageFont.truetype(FONT, 240)
    bbox = d.textbbox((0, 0), "12", font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.text((s / 2 - tw / 2 - bbox[0], cy - th / 2 - bbox[1]), "12",
           font=font, fill=ROSE)
    # subtle fold seam across the card
    d.rectangle([card[0], cy - 3, card[2], cy + 3], fill=(225, 214, 205, 230))
    d.rectangle([card[0], cy + 3, card[2], cy + 9], fill=(0, 0, 0, 22))

    img.save(out)
    print("wrote", out)


def make_brand(out):
    w, h = 760, 150
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT, 64)
    bbox = d.textbbox((0, 0), "flipclock", font=font)
    tw = bbox[2] - bbox[0]
    d.text((w / 2 - tw / 2 - bbox[0], 20), "flipclock", font=font,
           fill=(170, 120, 135, 255))
    img.save(out)
    print("wrote", out)


make_background("assets/icon/splash_bg.png")
make_logo("assets/icon/splash_logo.png")
make_brand("assets/icon/splash_brand.png")
