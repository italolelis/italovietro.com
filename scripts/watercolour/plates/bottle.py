import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT
DEST = "content/episodes/shipping-more-not-faster"

W, H = 1600, 1000
s = Sheet(W, H, scale=2, s=57)

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

TAGS = ["amber", "teal", "indigo", "rose", "sage", "vermilion", "ochre", "sky"]

def ticket(cx, cy, w, h, ang, tag, ink_d=1.6, band_d=0.7, paper=None, lines=3):
    card = rotate(rect(cx - w / 2, cy - h / 2, w, h), ang, cx, cy)
    if paper is not None:
        s.wash(card, paper[0], density=paper[1], spread=0.01, feather=0.6, edge=0.5)
    band = rotate(rect(cx - w / 2 + 4, cy - h / 2 + 4, w - 8, h * 0.18), ang, cx, cy)
    s.wash(band, PIG[tag], density=band_d, spread=0.03, feather=1.0, edge=1.0)
    sketch(s, card, overshoot=2, width=1.0, density=ink_d)
    for k in range(lines):
        ww = (w - 14) * (0.5 if k == lines - 1 else rng.uniform(0.7, 1.0))
        xs = np.linspace(cx - w / 2 + 7, cx - w / 2 + 7 + ww, 8)
        y = cy - h / 2 + h * 0.36 + k * h * 0.17
        seg = rotate(np.stack([xs, y + np.sin(xs * 0.5) * 1.2], 1), ang, cx, cy)
        s.ink(seg, width=0.8, density=ink_d * 0.8, wobble=0.2)
    return card

# ---- the bottle's outline ------------------------------------------------------
bx, body_w = 640, 300
xl, xr = bx - body_w / 2, bx + body_w / 2
neck_l, neck_r = bx - 34, bx + 34
y_bot, y_body, y_neck, y_lip = 812, 380, 268, 140
sh_l = [(xl + (neck_l - xl) * (1 - np.cos(t * np.pi / 2)), y_body - (y_body - y_neck) * np.sin(t * np.pi / 2)) for t in np.linspace(0, 1, 14)]
sh_r = [(xr - (xr - neck_r) * (1 - np.cos(t * np.pi / 2)), y_body - (y_body - y_neck) * np.sin(t * np.pi / 2)) for t in np.linspace(0, 1, 14)]
outline = np.array([(xl + 18, y_bot), (xl + 4, y_bot - 8), (xl, y_bot - 26)] + [(xl, y_body)] + sh_l[1:] +
                   [(neck_l, y_lip + 16), (neck_l - 6, y_lip + 14), (neck_l - 6, y_lip), (neck_r + 6, y_lip), (neck_r + 6, y_lip + 14), (neck_r, y_lip + 16)] +
                   sh_r[::-1][:-1] + [(xr, y_body), (xr, y_bot - 26), (xr - 4, y_bot - 8), (xr - 18, y_bot)])

# ---- setting: a pale wall wash and a table edge ------------------------------
s.wash(deform(np.array([(220, 150), (900, 90), (1420, 170), (1460, 790), (160, 810)]), 3, 0.09, rng), PIG["sky"], density=0.13,
       spread=0.08, feather=40, grade=(90, 0.4), edge=0.15, blotch=0.5, holes=[outline], hole_soft=1.0)
table = np.array([(90, 800), (1510, 790), (1530, 930), (70, 940)])
s.wash(table, PIG["ochre"], density=0.32, spread=0.02, feather=10, grade=(90, 0.7), edge=0.3, blotch=0.5, holes=[outline], hole_soft=0.8)
s.ink([(80, 801), (1520, 791)], width=1.3, density=1.6)
# the bottle's shadow, and the light it bends onto the table
s.wash(np.array([(xl + 30, y_bot - 2), (xr - 6, y_bot - 4), (xr + 300, y_bot + 10), (xr + 250, y_bot + 34), (xl + 60, y_bot + 12)]), PIG["payne"],
       density=0.26, spread=0.02, feather=8, grade=(0, 0.75), edge=0.0, holes=[outline], hole_soft=0.6)
s.wash(ell(bx + 60, y_bot + 10, 150, 9), PIG["sage"], density=0.38, spread=0.04, feather=4, edge=0.4, holes=[outline], hole_soft=0.6)

# ---- the tickets inside, painted before the glass so the glass tints them --------
inside = []
rows = np.arange(y_bot - 46, y_body - 10, -52)
for r, y in enumerate(rows):
    n = 5 if r % 2 else 6
    for x in np.linspace(xl + 46, xr - 46, n) + rng.uniform(-6, 6, n):
        inside.append((x, y + rng.uniform(-8, 8), rng.uniform(-26, 26)))
# the shoulder narrows the crowd, and the neck takes them single file
for (x, y, a) in [(bx - 84, 356, 16), (bx - 28, 344, -10), (bx + 30, 346, 18), (bx + 86, 358, -14),
                  (bx - 40, 304, -18), (bx + 4, 300, 6), (bx + 44, 306, 22), (bx - 2, 252, -5), (bx + 2, 206, 4)]:
    inside.append((x, y, a))
for i, (x, y, a) in enumerate(inside):
    narrow = y < 270
    ticket(x, y, 30 if narrow else 44, 46 if narrow else 58, a, TAGS[i % len(TAGS)], ink_d=1.1, band_d=0.55, lines=2 if narrow else 3)

# ---- the glass ----------------------------------------------------------------------
hl = np.array([(xl + 28, y_body + 30), (xl + 46, y_body + 18), (xl + 52, y_bot - 70), (xl + 34, y_bot - 60)])
hl2 = np.array([(neck_l + 8, y_lip + 30), (neck_l + 16, y_lip + 28), (neck_l + 16, y_neck - 6), (neck_l + 8, y_neck - 4)])
s.wash(outline, PIG["sage"], density=0.52, spread=0.002, feather=1.5, layers=36, edge=1.25, grade=(180, 0.45), blotch=0.25,
       holes=[hl, hl2], hole_soft=1.5, bloom=1)
s.wash(np.array([(xr - 46, y_body - 6), (xr, y_body), (xr, y_bot - 26), (xr - 40, y_bot - 20)]), PIG["teal"], density=0.4,
       spread=0.01, feather=6, edge=0.2, grade=(180, 0.8))
s.wash(np.array([(neck_l - 6, y_lip), (neck_r + 6, y_lip), (neck_r + 6, y_lip + 14), (neck_l - 6, y_lip + 14)]), PIG["teal"],
       density=0.7, spread=0.01, feather=0.8, edge=1.0)
s.ink(outline, closed=True, width=1.5, density=2.0, wobble=0.4)
s.ink(arc(bx, y_bot - 26, body_w / 2 - 4, 12, 10, 170, 30), width=0.9, density=1.2)

# ---- one ticket squeezing out of the neck, two that made it -----------------------------
ticket(bx + 4, y_lip - 20, 30, 46, 10, "vermilion", paper=(PIG["ochre"], 0.04))
for (x, y, a, tag) in [(1010, 846, -8, "teal"), (1140, 858, 12, "amber")]:
    card = rotate(np.array([(x - 30, y - 18), (x + 30, y - 22), (x + 34, y + 18), (x - 28, y + 22)]), a, x, y)
    s.wash(card + [5, 6], PIG["payne"], density=0.18, spread=0.02, feather=3, edge=0.0, holes=[card])
    band = rotate(np.array([(x - 26, y - 14), (x - 14, y - 16), (x - 12, y + 16), (x - 24, y + 18)]), a, x, y)
    s.wash(band, PIG[tag], density=0.75, spread=0.03, feather=1, edge=1.0)
    sketch(s, card, overshoot=2, width=1.1)
    for k in range(3):
        xs = np.linspace(x - 6, x + 24 - 8 * (k == 2), 7)
        s.ink(rotate(np.stack([xs, y - 8 + k * 8 + np.sin(xs) * 0.8], 1), a, x, y), width=0.8, density=1.3)

s.save(os.path.join(OUT, "bottle.png"))

