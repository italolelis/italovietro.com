# The hero for "Show people their impact" (The Ventellect Podcast, 2023): pots on
# a bench, each seedling a stage further along, and the watering can. Culture, in
# the episode's words, takes a few years to build; the best principal engineers
# spend theirs growing other principals.
import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT

W, H = 1600, 1000
s = Sheet(W, H, scale=2, s=113)
BENCH = 720

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

def leaf(cx, cy, length, width, ang, pig=PIG["sage"], d=0.8):
    t = np.linspace(0, np.pi, 14)
    upper = np.stack([np.linspace(0, length, 14), np.sin(t) * width], 1)
    lower = np.stack([np.linspace(length, 0, 14), -np.sin(t[::-1]) * width * 0.85], 1)
    pts = np.vstack([upper, lower]) + [cx, cy]
    pts = rotate(pts, ang, cx, cy)
    s.wash(pts, pig, density=d, spread=0.03, feather=0.8, layers=24, edge=1.1, gran=0.5)
    tip = rotate(np.array([[cx + length * 0.92, cy]]), ang, cx, cy)[0]
    s.ink([(cx, cy), tip], width=0.8, density=1.2, wobble=0.2)
    s.ink(pts, closed=True, width=0.9, density=1.4, wobble=0.25)

# ---- wall: warm light from the left, cooler toward the right --------------------
wall = deform(np.array([(90, 70), (800, 40), (1500, 80), (1520, BENCH), (80, BENCH)]), 3, 0.06, rng)
s.wash(wall, PIG["sage"], density=0.14, spread=0.06, feather=34, grade=(180, 0.6), edge=0.15, blotch=0.5)
light = np.array([(90, 60), (520, 60), (1100, BENCH), (380, BENCH)])
s.wash(light, PIG["ochre"], density=0.22, spread=0.05, feather=40, grade=(90, 0.3), edge=0.0, blotch=0.4)

# ---- the bench ----------------------------------------------------------------------
# Everything standing on the bench is reserved from it: transparent wood under a
# terracotta pot reads as glass.
POTS = [(210, 92), (440, 104), (680, 116), (940, 128), (1205, 140)]
CAN = (1460, BENCH + 30)
standing = []
for (px, pw) in POTS:
    ph = pw * 0.95
    standing.append(np.array([(px - pw / 2 + 6, BENCH + 34 - ph + 16), (px + pw / 2 - 6, BENCH + 34 - ph + 16),
                              (px + pw * 0.36, BENCH + 34), (px - pw * 0.36, BENCH + 34)]))
standing.append(np.array([(CAN[0] - 70, CAN[1] - 120), (CAN[0] + 60, CAN[1] - 120), (CAN[0] + 66, CAN[1]), (CAN[0] - 76, CAN[1])]))
top = np.array([(60, BENCH), (1540, BENCH), (1560, BENCH + 60), (40, BENCH + 60)])
s.wash(top, PIG["ochre"], density=0.55, spread=0.004, feather=2, edge=0.9, grade=(90, 0.35), blotch=0.5, holes=standing, hole_soft=0.5)
GRAIN_CUTS = sorted([(b[:, 0].min() - 2, b[:, 0].max() + 2) for b in standing])
for k in range(4):
    y = BENCH + 12 + k * 12 + rng.uniform(-2, 2)
    x0, x1 = rng.uniform(60, 160), rng.uniform(1440, 1540)
    a = x0
    for (c0, c1) in GRAIN_CUTS + [(x1, x1)]:
        # only the stretch of grain that is in front of nothing
        if y < BENCH + 36 and c0 > a and c0 - a > 20:
            xs = np.linspace(a, min(c0, x1), 20)
            s.stroke(np.stack([xs, y + np.sin(xs * 0.008 + k) * 2.0], 1), 1.4, PIG["sienna"], density=0.3, wobble=0.8, edge=0.1)
        a = max(a, c1)
    if y >= BENCH + 36:
        xs = np.linspace(x0, x1, 50)
        s.stroke(np.stack([xs, y + np.sin(xs * 0.008 + k) * 2.0], 1), 1.4, PIG["sienna"], density=0.3, wobble=0.8, edge=0.1)
face = np.array([(40, BENCH + 60), (1560, BENCH + 60), (1560, BENCH + 104), (40, BENCH + 104)])
s.wash(face, PIG["sienna"], density=0.85, spread=0.004, feather=1.5, edge=1.0, grade=(90, 0.2), bloom=1)
CUTS = [(px - pw * 0.4 - 4, px + pw * 0.4 + 4) for (px, pw) in [(210, 92), (440, 104), (680, 116), (940, 128), (1205, 140)]] + [(1385, 1532)]
x0 = 56
for (a, b) in CUTS + [(1544, 1544)]:
    if a - x0 > 6:
        s.ink(np.linspace((x0, BENCH), (a, BENCH), 10), width=1.3, density=1.8)
    x0 = b
s.ink([(1540, BENCH), (1560, BENCH + 60)], width=1.3, density=1.8)
s.ink([(60, BENCH), (40, BENCH + 60)], width=1.3, density=1.8)
s.ink([(40, BENCH + 60), (1560, BENCH + 60)], width=1.3, density=1.8)
s.ink([(40, BENCH + 104), (1560, BENCH + 104)], width=1.3, density=1.6)
s.wash(np.array([(60, BENCH + 106), (1540, BENCH + 106), (1500, BENCH + 160), (100, BENCH + 160)]), PIG["payne"],
       density=0.16, spread=0.03, feather=10, grade=(90, 0.95), edge=0.0)

# ---- pots, small to large, and what grows in them -------------------------------------
pots = POTS
for i, (px, pw) in enumerate(pots):
    ph = pw * 0.95
    rim_y = BENCH + 34 - ph
    body = np.array([(px - pw / 2 + 6, rim_y + 16), (px + pw / 2 - 6, rim_y + 16), (px + pw * 0.36, BENCH + 34), (px - pw * 0.36, BENCH + 34)])
    rim = rect(px - pw / 2, rim_y, pw, 18)
    s.wash(ell(px + 12, BENCH + 36, pw * 0.42, 9), PIG["payne"], density=0.2, spread=0.03, feather=4, edge=0.0)
    s.wash(body, PIG["sienna"], density=0.8, spread=0.003, feather=1.0, edge=1.0, grade=(0, 0.45), blotch=0.3,
           holes=[rect(px - pw * 0.3, rim_y + 28, 4, ph * 0.45)], hole_soft=3.0)
    s.wash(rim, PIG["sienna"], density=0.65, spread=0.003, feather=0.8, edge=1.0, grade=(0, 0.4))
    s.wash(ell(px, rim_y + 2, pw / 2 - 5, 7, 24), PIG["sepia"], density=1.1, spread=0.01, feather=0.5, edge=0.6)
    sketch(s, body, overshoot=2, width=1.2)
    sketch(s, rim, overshoot=2, width=1.2)
    base = (px, rim_y)
    # growth: one stage per pot
    if i == 0:
        s.stroke([(px, rim_y), (px + 2, rim_y - 16)], 3, PIG["sage"], density=1.0, wobble=0.2, taper=False, edge=0.6)
        leaf(px + 2, rim_y - 16, 12, 5, -35, d=0.9)
    elif i == 1:
        s.stroke([(px, rim_y), (px - 2, rim_y - 46)], 3.5, PIG["sage"], density=1.0, wobble=0.4, taper=False, edge=0.6)
        leaf(px - 2, rim_y - 46, 26, 10, -150)
        leaf(px - 2, rim_y - 46, 26, 10, -30)
    elif i == 2:
        s.stroke([(px, rim_y), (px + 4, rim_y - 60), (px, rim_y - 100)], 4, PIG["sage"], density=1.0, wobble=0.6, taper=False, edge=0.6)
        leaf(px + 2, rim_y - 58, 34, 12, -160)
        leaf(px + 4, rim_y - 70, 36, 13, -20)
        leaf(px, rim_y - 100, 30, 11, -110)
        leaf(px, rim_y - 100, 28, 10, -60)
    elif i == 3:
        s.stroke([(px, rim_y), (px - 6, rim_y - 90), (px + 4, rim_y - 170)], 5, PIG["sage"], density=1.05, wobble=0.8, taper=False, edge=0.6)
        for (yy, ang, L) in [(-50, -165, 44), (-62, -15, 46), (-104, -170, 42), (-118, -10, 44), (-150, -130, 36), (-160, -50, 38)]:
            leaf(px + (yy / 30), rim_y + yy, L, L * 0.36, ang, d=0.85)
        leaf(px + 4, rim_y - 170, 30, 11, -90, d=0.9)
    else:
        s.stroke([(px, rim_y), (px - 8, rim_y - 120), (px + 6, rim_y - 250)], 6, PIG["sage"], density=1.1, wobble=1.0, taper=False, edge=0.6)
        s.stroke([(px - 4, rim_y - 110), (px - 60, rim_y - 170)], 4, PIG["sage"], density=1.0, wobble=0.6, taper=False, edge=0.6)
        s.stroke([(px, rim_y - 170), (px + 66, rim_y - 214)], 4, PIG["sage"], density=1.0, wobble=0.6, taper=False, edge=0.6)
        for (x0, y0, ang, L) in [(px, rim_y - 60, -168, 54), (px, rim_y - 76, -12, 56), (px - 60, rim_y - 170, -150, 46),
                                 (px - 60, rim_y - 170, -100, 40), (px + 66, rim_y - 214, -30, 46), (px + 66, rim_y - 214, -80, 40),
                                 (px - 4, rim_y - 140, -20, 48), (px + 6, rim_y - 250, -110, 40), (px + 6, rim_y - 250, -60, 42)]:
            leaf(x0, y0, L, L * 0.36, ang, d=0.85, pig=PIG["sage"] if rng.random() > 0.3 else PIG["teal"])
        s.dots([(px + 6, rim_y - 262)], 7, PIG["rose"], density=0.9)   # the first bud

# ---- the watering can ----------------------------------------------------------------------
cx, cy = CAN
can = np.array([(cx - 70, cy - 120), (cx + 60, cy - 120), (cx + 66, cy), (cx - 76, cy)])
s.wash(ell(cx + 10, cy + 4, 80, 10), PIG["payne"], density=0.22, spread=0.03, feather=4, edge=0.0)
s.wash(can, PIG["teal"], density=0.75, spread=0.002, feather=0.8, edge=1.1, grade=(0, 0.45), blotch=0.25,
       holes=[rect(cx - 54, cy - 104, 5, 84)], hole_soft=3.0)
sketch(s, can, overshoot=2, width=1.3)
s.ink(arc(cx - 4, cy - 120, 50, 44, 190, 350, 24), width=4, density=2.0)                     # handle
spout = [(cx - 72, cy - 40), (cx - 104, cy - 112), (cx - 122, cy - 176)]
s.stroke(spout, 12, PIG["teal"], density=0.85, wobble=0.3, taper=False, edge=0.9)
s.ink(spout, width=1.0, density=1.5)
rose_ = rotate(np.array([(cx - 140, cy - 204), (cx - 112, cy - 204), (cx - 110, cy - 174), (cx - 144, cy - 174)]), -22)
s.wash(rose_, PIG["teal"], density=0.9, spread=0.003, feather=0.5, edge=0.9)
sketch(s, rose_, overshoot=1.5, width=1.0)

s.save(os.path.join(OUT, "seedlings.png"), crop=(30, 230, 1570, 900))
