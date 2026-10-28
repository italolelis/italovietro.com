import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT

W, H = 1600, 1000
s = Sheet(W, H, scale=2, s=21)

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

def loose_ellipse(cx, cy, rx, ry, width=1.4, passes=2):
    for p in range(passes):
        a0 = rng.uniform(0, 360)
        span = rng.uniform(330, 380)
        pts = arc(cx + rng.normal(0, 1.2), cy + rng.normal(0, 0.8), rx * rng.uniform(0.985, 1.015), ry * rng.uniform(0.97, 1.03), a0, a0 + span, 64)
        s.ink(pts, width=width * (1 if p == 0 else 0.7), density=2.2 if p == 0 else 1.3, wobble=0.6)

# ---- the wall: an irregular warm wash, cooler to the upper left, no frame
wall = deform(np.array([(150, 70), (700, 40), (1430, 90), (1480, 640), (1050, 700), (120, 690)]), 3, 0.08, rng)
s.wash(wall, PIG["ochre"], density=0.16, spread=0.08, feather=34, grade=(200, 0.55), edge=0.25, blotch=0.55, bloom=1)
s.wash(deform(np.array([(120, 60), (760, 50), (640, 360), (110, 420)]), 3, 0.12, rng), PIG["sky"], density=0.15,
       spread=0.1, feather=30, edge=0.2, blotch=0.5)

# ---- ticket rail, a little perspective: higher on the left
def rail_y(x):
    return 112 + (x - 100) * 0.028

# lamp glow first, so everything else sits on it
lamps = [(560, 400), (1130, 420)]
for (x, y) in lamps:
    cone = np.array([[x - 44, y + 4], [x + 44, y + 4], [x + 230, 640], [x - 230, 640]])
    s.wash(cone, PIG["amber"], density=0.26, spread=0.03, feather=20, grade=(-90, 0.6), edge=0.1, blotch=0.35)
    s.wash(cone, PIG["ochre"], density=0.18, spread=0.03, feather=12, grade=(-90, 0.2), edge=0.0, blotch=0.3)

s.wash(np.array([[96, rail_y(96) + 2], [1504, rail_y(1504) + 2], [1504, rail_y(1504) + 20], [96, rail_y(96) + 20]]),
       PIG["payne"], density=0.5, spread=0.005, feather=1.2, edge=0.9)
s.ink([(90, rail_y(90)), (1510, rail_y(1510))], width=1.8)
s.ink([(92, rail_y(92) + 21), (1508, rail_y(1508) + 21)], width=1.2, density=1.6)

tags = ["amber", "teal", "indigo", "rose", "sage", "vermilion", "ochre"]
slots = [160, 300, 420, 690, 830, 960, 1250, 1380]
skip = {3}
ti = 0
for i, x in enumerate(slots):
    if i in skip:
        continue
    w = rng.uniform(100, 126)
    h = rng.uniform(150, 205)
    y = rail_y(x) + 14
    ang = rng.uniform(-6, 6)
    cx = x + w / 2
    card = rotate(rect(x, y, w, h), ang, cx, y)
    sh = rotate(rect(x + w - 14, y + 12, 16, h - 14), ang, cx, y)
    s.wash(sh, PIG["grey"], density=0.18, spread=0.02, feather=3, edge=0.3)
    band = rotate(rect(x + 7, y + 14, w - 14, 22), ang, cx, y)
    s.wash(band, PIG[tags[ti % len(tags)]], density=0.7, spread=0.04, feather=2.5, edge=1.0)
    ti += 1
    sketch(s, card, overshoot=4, width=1.35)
    lines = int(rng.integers(3, 6))
    for k in range(lines):
        ww = (w - 30) * (0.5 if k == lines - 1 else rng.uniform(0.65, 1.0))
        xs = np.linspace(0, ww, 14)
        ys = 19 * k + np.sin(xs * 0.33 + rng.uniform(0, 6)) * 2.0
        seg = rotate(np.stack([x + 14 + xs, y + 56 + ys], 1), ang, cx, y)
        s.ink(seg, width=0.95, density=1.6, wobble=0.35)
    clip = rect(cx - 11, rail_y(cx) - 4, 22, 30)
    s.wash(clip, PIG["payne"], density=0.85, spread=0.02, feather=1, edge=0.6)
    sketch(s, clip, overshoot=1.5, width=1.0)

# ---- lamps on cords that fall through the gaps between tickets
for (x, y) in lamps:
    s.ink([(x + rng.uniform(-1, 1), 0), (x, y - 70)], width=1.2, density=2.0)
    shade = np.array([[x - 20, y - 70], [x + 20, y - 70], [x + 66, y], [x - 66, y]])
    s.wash(shade, PIG["indigo"], density=1.0, spread=0.02, feather=2, edge=1.0, grade=(0, 0.5))
    sketch(s, shade, overshoot=3, width=1.5)
    s.wash(ell(x, y + 2, 46, 8, 20), PIG["ochre"], density=0.9, spread=0.04, feather=1.5, edge=0.4)

# ---- the pass: a steel shelf in mild perspective
back_l, back_r, front_l, front_r = (78, 606), (1522, 598), (40, 716), (1560, 706)
top = np.array([back_l, back_r, front_r, front_l])
glints = [ell(x, 690, 130, 7, 20) for (x, y) in lamps]
# White china is left as paper: the steel is painted around it, not under it.
china = [ell(330, 668, 132, 36), ell(830, 664, 122, 33), ell(1310, 660, 128, 35),
         np.vstack([arc(584, 622, 68, 16, 180, 360, 24), arc(584, 622, 68, 50, 0, 180, 24)]),
         ell(1066, 666, 50, 11)]
s.wash(top, PIG["payne"], density=0.3, spread=0.008, feather=2.5, edge=0.9, grade=(0, 0.4), blotch=0.5,
       holes=glints + china, hole_soft=1.2)
for (x, y) in lamps:   # lamp light pooling on the steel
    s.wash(ell(x, 660, 220, 30), PIG["ochre"], density=0.42, spread=0.08, feather=10, edge=0.2)
face = np.array([front_l, front_r, (1560, 758), (40, 768)])
s.wash(face, PIG["payne"], density=0.62, spread=0.006, feather=2, edge=1.0, grade=(0, 0.3), bloom=1)
sketch(s, top, overshoot=7, width=1.6)
s.ink([(36, 768), (1564, 758)], width=1.7)
s.wash(np.array([[60, 770], [1540, 760], [1500, 820], [100, 830]]), PIG["indigo"], density=0.18, spread=0.04, feather=12, grade=(90, 0.9), edge=0.0)

# ---- plates
def plate(cx, cy, rx, food, garnish=()):
    ry = rx * 0.27
    s.wash(ell(cx + 6, cy + 8, rx * 1.02, ry * 1.05), PIG["payne"], density=0.18, spread=0.03, feather=4, edge=0.2)
    s.wash(ell(cx, cy - 2, rx * 0.66, ry * 0.62), PIG["sky"], density=0.10, spread=0.04, feather=2, edge=0.6)
    for (pig, dx, dy, r, d) in food:
        s.wash(deform(ell(cx + dx, cy + dy, r, r * 0.5, 12), 1, 0.15, rng), PIG[pig], density=d * 1.25, spread=0.1, feather=1.5, edge=1.3)
    for (dx, dy, ang) in garnish:
        a = math.radians(ang)
        p0 = np.array([cx + dx, cy + dy])
        p1 = p0 + [math.cos(a) * 22, math.sin(a) * 10]
        s.stroke([p0, (p0 + p1) / 2 + [0, -4], p1], 7, PIG["sage"], density=0.9, wobble=0.6, edge=0.9)
    loose_ellipse(cx, cy, rx, ry, width=1.4, passes=1)
    s.ink(arc(cx, cy - 1, rx * 0.68, ry * 0.64, 160, 380, 40), width=0.9, density=1.3)

plate(330, 668, 132, [("sienna", -10, -8, 50, 0.75), ("ochre", 38, -12, 20, 0.7), ("vermilion", 14, -2, 12, 0.7)], [(-46, -16, -20), (-26, -24, 15), (52, -20, 30)])
plate(830, 664, 122, [("sage", -26, -6, 38, 0.7), ("vermilion", 24, -8, 24, 0.75), ("vermilion", 48, -2, 12, 0.75)], [(8, -20, -30), (-40, -14, 10)])
plate(1310, 660, 128, [("rose", -12, -8, 40, 0.65), ("teal", 34, -10, 20, 0.6), ("ochre", -46, -6, 14, 0.8)], [(22, -22, 10), (-20, -20, -25)])

# ---- a bowl with something hot in it
bx, by = 584, 668
s.wash(ell(bx + 8, by + 6, 74, 12), PIG["payne"], density=0.2, spread=0.03, feather=4, edge=0.2)
bowl = np.vstack([arc(bx, by - 46, 68, 16, 180, 360, 24), arc(bx, by - 46, 68, 50, 0, 180, 24)])
s.wash(bowl, PIG["teal"], density=0.62, spread=0.02, feather=2, edge=1.0, grade=(0, 0.65), bloom=1)
s.wash(ell(bx, by - 46, 60, 12), PIG["sienna"], density=0.55, spread=0.03, feather=1.5, edge=0.9)
loose_ellipse(bx, by - 46, 68, 16, width=1.3)
s.ink(arc(bx, by - 46, 68, 50, 2, 178, 30), width=1.6)
for dx in (-24, 2, 26):
    pts = [(bx + dx, by - 64), (bx + dx - 12, by - 104), (bx + dx + 8, by - 146), (bx + dx - 6, by - 186), (bx + dx + 4, by - 216)]
    s.stroke(pts, 10, PIG["grey"], density=0.16, wobble=5, edge=0.8, gran=0.1)

# ---- the service bell
gx, gy = 1066, 672
s.wash(ell(gx + 6, gy + 6, 50, 9), PIG["payne"], density=0.25, spread=0.03, feather=3, edge=0.2)
base = np.vstack([arc(gx, gy - 8, 48, 9, 180, 360, 20), arc(gx, gy - 2, 48, 9, 0, 180, 20)])
s.wash(base, PIG["sepia"], density=0.75, spread=0.01, feather=1, edge=0.8)
dome = np.vstack([arc(gx, gy - 10, 40, 44, 180, 360, 32), arc(gx, gy - 10, 40, 6, 0, 180, 12)])
s.wash(dome, PIG["ochre"], density=0.95, spread=0.01, feather=1.5, edge=1.2, grade=(0, 0.75))
s.wash(np.array([[gx - 22, gy - 44], [gx - 12, gy - 48], [gx - 18, gy - 16], [gx - 28, gy - 14]]), PIG["amber"], density=0.0001, spread=0, feather=0.5, edge=0)
s.ink(arc(gx, gy - 10, 40, 44, 182, 358, 36), width=1.5)
s.ink(arc(gx, gy - 10, 40, 6, 0, 180, 16), width=1.2, density=1.6)
s.wash(rect(gx - 4, gy - 64, 8, 12), PIG["payne"], density=0.9, spread=0.01, feather=0.8, edge=0.5)
s.wash(ell(gx, gy - 66, 10, 4, 12), PIG["payne"], density=1.0, spread=0.01, feather=0.8, edge=0.5)
s.ink(arc(gx, gy - 66, 10, 4, 0, 360, 20), width=1.0)

s.save(os.path.join(OUT, "kitchen.png"), crop=(20, 0, 1580, 880))

