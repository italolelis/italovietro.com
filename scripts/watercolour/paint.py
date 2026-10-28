# /// script
# requires-python = ">=3.11,<3.14"
# dependencies = ["numpy", "opencv-python-headless", "pillow", "scipy"]
# ///
"""
Paint the watercolour plates -- the episode pages' and the home page's -- and
export each one to where the site reads it.

    uv run scripts/watercolour/paint.py              # every plate
    uv run scripts/watercolour/paint.py bottle       # one plate

Nothing here runs in CI. The build uses the committed WebP files; this exists so
a plate can be repainted, and so "painted by code" in the page's colophon is a
claim anyone can check.

Each script in plates/ paints one sheet with wc.py and saves a 2x-rendered PNG
master to out/ (gitignored). This file then exports it to the bundle as WebP
with its deckled alpha edge intact -- JPEG would flatten the edge onto a
background colour that is wrong for one of the two themes -- and cuts the
1200x630 share card from the hero.

The masters come out around 2MB each; the WebP exports around 50-90KB. The build
gate fails any plate over 160KB, which is what a PNG committed by mistake would
trip.
"""
import os
import runpy
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
EPISODES = os.path.join(ROOT, "content", "episodes")
# Where each plate lives once exported: an episode's plates in its page bundle,
# the home page's with the site's other images in assets/.
DEST = {name: os.path.join(EPISODES, "shipping-more-not-faster") for name in ["kitchen", "notebook", "toque", "bottle", "knives", "factory"]}
DEST["seedlings"] = os.path.join(EPISODES, "show-people-their-impact")
DEST["desk"] = os.path.join(ROOT, "assets", "images", "plates")
PLATES = list(DEST)
PAPER = (251, 247, 238)  # wc.PAPER, as 8-bit
# Each episode's hero, which its 1200x630 share card is cut from.
HEROES = {"kitchen", "seedlings"}

sys.path.insert(0, HERE)
from wc import OUT  # noqa: E402


def export(name):
    im = Image.open(os.path.join(OUT, f"{name}.png")).convert("RGBA")
    if im.width > 1600:
        im = im.resize((1600, round(im.height * 1600 / im.width)), Image.LANCZOS)
    os.makedirs(DEST[name], exist_ok=True)
    dst = os.path.join(DEST[name], f"{name}.webp")
    im.save(dst, "WEBP", quality=84, method=6, alpha_quality=90)
    print(f"{name}: {im.width}x{im.height}, {os.path.getsize(dst) // 1024}KB")


def share_card(name):
    # Flattened onto paper (a card is never transparent), scaled to cover
    # 1200x630, cut from the middle of the sheet.
    im = Image.open(os.path.join(OUT, f"{name}.png")).convert("RGBA")
    bg = Image.new("RGBA", im.size, PAPER + (255,))
    bg.alpha_composite(im)
    tw, th = 1200, 630
    scale = max(tw / bg.width, th / bg.height) * 1.04
    bg = bg.resize((round(bg.width * scale), round(bg.height * scale)), Image.LANCZOS)
    x, y = (bg.width - tw) // 2, (bg.height - th) // 2
    dst = os.path.join(DEST[name], "cover.jpg")
    bg.crop((x, y, x + tw, y + th)).convert("RGB").save(dst, "JPEG", quality=84, optimize=True, progressive=True)
    print(f"cover ({name}): {tw}x{th}, {os.path.getsize(dst) // 1024}KB")


def main(names):
    for name in names:
        if name not in PLATES:
            sys.exit(f"no plate {name!r}; plates are {', '.join(PLATES)}")
        runpy.run_path(os.path.join(HERE, "plates", f"{name}.py"), run_name="__main__")
        export(name)
        if name in HEROES:
            share_card(name)


if __name__ == "__main__":
    main(sys.argv[1:] or PLATES)
