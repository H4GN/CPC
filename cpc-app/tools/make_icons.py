from PIL import Image, ImageDraw

S = 1024

logo = Image.open("assets/icon/logo.png").convert("RGBA")
logo = logo.resize((S, S), Image.LANCZOS)

mask = Image.new("L", (S, S), 0)
draw = ImageDraw.Draw(mask)

# Rounded icon corners
draw.rounded_rectangle(
    (0, 0, S, S),
    radius=int(S * 0.16),
    fill=255
)

logo.putalpha(mask)

def make_icon(scale, bg_color):
    canvas = Image.new("RGBA", (S, S), bg_color)

    size = int(S * scale)
    resized = logo.resize((size, size), Image.LANCZOS)

    x = (S - size) // 2
    y = (S - size) // 2

    canvas.paste(resized, (x, y), resized)
    return canvas

# Android adaptive icon foreground
make_icon(0.62, (255, 255, 255, 0)).save(
    "assets/icon/icon_fg.png"
)

# Full icon with white background
make_icon(0.80, (255, 255, 255, 255)).save(
    "assets/icon/icon_full.png"
)

print("CPC icon generated successfully.")