"""Generate the app icon.

The whole icon is one flip card seen up close: two big digits filling the
frame with the fold running edge to edge, which is how this category is read
at a glance. The colour is the Sugar Pink skin rather than the default beige,
because every competing icon is black or grey and a pale one disappears on a
light wallpaper.

Outputs:
  assets/icon/app_icon.png     1024, full bleed (iOS, web, Play listing)
  assets/icon/app_icon_fg.png  1024, adaptive foreground, mark inside the
                               safe zone so a round or squircle mask cannot
                               clip the digits
  design/icons/store_512.png   512, for the store listing upload
"""
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
DIGITS = "12"
BG_TOP = (244, 114, 182)      # #F472B6 Sugar Pink
BG_BOTTOM = (236, 72, 153)    # #EC4899
INK = (255, 255, 255)
SEAM = (219, 39, 119)         # #DB2777
FONT = "assets/google_fonts/Inter-ExtraBold.ttf"


def fitted_font(draw, text, target_width):
    size = 10
    for candidate in range(40, 900, 2):
        font = ImageFont.truetype(FONT, candidate)
        if draw.textlength(text, font=font) > target_width:
            break
        size = candidate
    return ImageFont.truetype(FONT, size)


def draw_mark(img, width_ratio, seam_ratio):
    d = ImageDraw.Draw(img)
    font = fitted_font(d, DIGITS, SIZE * width_ratio)
    box = d.textbbox((0, 0), DIGITS, font=font)
    w, h = box[2] - box[0], box[3] - box[1]
    d.text((SIZE / 2 - w / 2 - box[0], SIZE / 2 - h / 2 - box[1]),
           DIGITS, font=font, fill=INK)
    bar = int(SIZE * 0.01)
    half = SIZE * seam_ratio / 2
    d.rectangle([SIZE / 2 - half, SIZE / 2 - bar,
                 SIZE / 2 + half, SIZE / 2 + bar], fill=SEAM)


def full_bleed():
    img = Image.new("RGB", (SIZE, SIZE), BG_TOP)
    d = ImageDraw.Draw(img)
    for y in range(SIZE):
        t = y / SIZE
        d.line([(0, y), (SIZE, y)], fill=tuple(
            int(BG_TOP[i] + (BG_BOTTOM[i] - BG_TOP[i]) * t) for i in range(3)))
    draw_mark(img, 0.88, 1.0)
    return img


def adaptive_foreground():
    # Only the centre 66% survives every launcher mask, so the mark is smaller
    # here and the fold stops short of the edge.
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_mark(img, 0.56, 0.66)
    return img


if __name__ == "__main__":
    icon = full_bleed()
    icon.save("assets/icon/app_icon.png")
    icon.resize((512, 512), Image.LANCZOS).save("design/icons/store_512.png")
    adaptive_foreground().save("assets/icon/app_icon_fg.png")
    print("wrote assets/icon/app_icon.png, assets/icon/app_icon_fg.png, "
          "design/icons/store_512.png")
