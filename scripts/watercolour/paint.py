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
master to out/ (gitignored). This file then exports it as WebP with its deckled
alpha edge intact -- JPEG would flatten the edge onto a background colour that is
wrong for one of the two themes.

A script also says where its Plate lives, so adding a Plate is one script and no
edit here. Two names at the top of it, after the imports:

    DEST = "content/episodes/some-episode"   # the page bundle, or assets/ folder, it is exported to,
                                             # relative to the repo root
    SHARE_CARD = True                        # optional: also cut that page's 1200x630 share card
                                             # (cover.jpg) from this plate. Only a hero wants one.

The Plate is then placed on its page with a line of front matter or the `plate`
shortcode (docs/agents/architecture.md, "Plates"). A script that does not name its
DEST stops the run rather than guessing a place for the file.

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
SCRIPTS = os.path.join(HERE, "plates")
PAPER = (251, 247, 238)  # wc.PAPER, as 8-bit

sys.path.insert(0, HERE)
from wc import OUT  # noqa: E402


def plates():
    """Every plate there is: one script each in plates/, named for the file it paints."""
    return sorted(f[:-3] for f in os.listdir(SCRIPTS) if f.endswith(".py"))


def export(name, dest):
    im = Image.open(os.path.join(OUT, f"{name}.png")).convert("RGBA")
    if im.width > 1600:
        im = im.resize((1600, round(im.height * 1600 / im.width)), Image.LANCZOS)
    os.makedirs(dest, exist_ok=True)
    dst = os.path.join(dest, f"{name}.webp")
    im.save(dst, "WEBP", quality=84, method=6, alpha_quality=90)
    print(f"{name}: {im.width}x{im.height}, {os.path.getsize(dst) // 1024}KB")


def share_card(name, dest):
    # Flattened onto paper (a card is never transparent), scaled to cover
    # 1200x630, cut from the middle of the sheet.
    im = Image.open(os.path.join(OUT, f"{name}.png")).convert("RGBA")
    bg = Image.new("RGBA", im.size, PAPER + (255,))
    bg.alpha_composite(im)
    tw, th = 1200, 630
    scale = max(tw / bg.width, th / bg.height) * 1.04
    bg = bg.resize((round(bg.width * scale), round(bg.height * scale)), Image.LANCZOS)
    x, y = (bg.width - tw) // 2, (bg.height - th) // 2
    dst = os.path.join(dest, "cover.jpg")
    bg.crop((x, y, x + tw, y + th)).convert("RGB").save(dst, "JPEG", quality=84, optimize=True, progressive=True)
    print(f"cover ({name}): {tw}x{th}, {os.path.getsize(dst) // 1024}KB")


def main(names):
    known = plates()
    for name in names:
        if name not in known:
            sys.exit(f"no plate {name!r}; plates are {', '.join(known)}")
    for name in names:
        # A plate paints the same whatever ran before it. wc.py keeps its random
        # state at module level, and a script takes a copy of it when it imports wc,
        # so a second script in this process would otherwise start from the end of
        # the first one's. Dropping the module is what makes a plate come out
        # byte for byte the same alone, in a full run, or on another day.
        sys.modules.pop("wc", None)
        script = runpy.run_path(os.path.join(SCRIPTS, f"{name}.py"), run_name="__main__")
        if "DEST" not in script:
            sys.exit(f"plates/{name}.py does not say where it lives: add DEST = \"content/...\" after its imports")
        dest = os.path.join(ROOT, script["DEST"])
        export(name, dest)
        if script.get("SHARE_CARD"):
            share_card(name, dest)


if __name__ == "__main__":
    main(sys.argv[1:] or plates())
