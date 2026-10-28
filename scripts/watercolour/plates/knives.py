import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT
DEST = "content/episodes/shipping-more-not-faster"

W, H = 1600, 900
s = Sheet(W, H, scale=2, s=71)
STRIP = (190, 236)  # magnet strip, top and bottom

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

def smooth(pts, n=60):
    pts = np.asarray(pts, float)
    t = np.linspace(0, 1, len(pts))
    u = np.linspace(0, 1, n)
    return np.stack([np.interp(u, t, pts[:, 0]), np.interp(u, t, pts[:, 1])], 1)

knives = []
# Each: blade outline, handle outline, handle pigment, extra drawing callback.
def chef(x):
    tip, heel = 80, 470
    blade = np.vstack([[(x - 4, heel)], smooth([(x - 4, heel), (x - 6, 200), (x - 4, tip)], 20),
                       smooth([(x, tip - 6), (x + 22, 160), (x + 52, 300), (x + 58, heel)], 30)])
    handle = np.array([(x - 2, heel), (x + 50, heel), (x + 46, heel + 180), (x + 40, heel + 192), (x + 4, heel + 192), (x - 4, heel + 180)])
    return blade, handle, "payne", [(x + 24, heel + 50), (x + 24, heel + 130)]
def cleaver(x):
    top, heel = 120, 450
    blade = np.array([(x - 4, top + 4), (x + 4, top), (x + 128, top + 8), (x + 132, heel), (x + 60, heel + 4), (x - 2, heel)])
    handle = np.array([(x + 6, heel), (x + 46, heel), (x + 44, heel + 170), (x + 38, heel + 180), (x + 12, heel + 180), (x + 6, heel + 170)])
    return blade, handle, "sienna", [(x + 26, heel + 45), (x + 26, heel + 120)]
def bread(x):
    tip, heel = 60, 480
    edge = [(x + 36 + 3 * np.sin(k * 1.9), y) for k, y in enumerate(np.linspace(heel, tip + 30, 34))]
    blade = np.vstack([[(x - 2, heel), (x - 3, tip + 10), (x + 10, tip)], [(x + 34, tip + 24)], edge[::-1]])
    handle = np.array([(x - 1, heel), (x + 40, heel), (x + 38, heel + 175), (x + 32, heel + 186), (x + 6, heel + 186), (x, heel + 175)])
    return blade, handle, "ochre", [(x + 20, heel + 50), (x + 20, heel + 125)]
def paring(x):
    tip, heel = 250, 450
    blade = np.vstack([[(x - 2, heel), (x - 3, tip + 20), (x, tip)], smooth([(x + 4, tip + 4), (x + 20, tip + 60), (x + 30, heel)], 16)])
    handle = np.array([(x - 1, heel), (x + 32, heel), (x + 30, heel + 140), (x + 24, heel + 150), (x + 4, heel + 150), (x, heel + 140)])
    return blade, handle, "teal", [(x + 16, heel + 40), (x + 16, heel + 100)]
def santoku(x):
    tip, heel = 110, 460
    blade = np.vstack([[(x - 3, heel), (x - 4, tip + 30)], smooth([(x - 4, tip + 30), (x + 6, tip + 4), (x + 30, tip)], 10),
                       smooth([(x + 34, tip + 6), (x + 62, 220), (x + 66, heel)], 20)])
    handle = np.array([(x - 1, heel), (x + 58, heel), (x + 54, heel + 175), (x + 48, heel + 186), (x + 8, heel + 186), (x + 2, heel + 175)])
    return blade, handle, "rose", []

makers = [(chef, 330), (cleaver, 560), (bread, 810), (paring, 1010), (santoku, 1190)]
for fn, x in makers:
    knives.append(fn(x) + (fn.__name__, x))
blades = [k[0] for k in knives]
handles = [k[1] for k in knives]

# ---- wall: a pale tiled wall, the tiles barely there
wall = deform(np.array([(260, 90), (800, 40), (1380, 110), (1420, 700), (900, 760), (200, 690)]), 3, 0.1, rng)
s.wash(wall, PIG["sky"], density=0.12, spread=0.1, feather=40, grade=(90, 0.3), edge=0.15, blotch=0.5, holes=blades + handles)
# only a few tile joints, fading out -- suggested, not ruled
for gx in (440, 980):
    s.stroke([(gx, 330), (gx + rng.uniform(-2, 2), 600)], 2, PIG["sky"], density=0.2, wobble=0.6, taper=True, edge=0.1)
for gy in (420,):
    s.stroke([(300, gy), (760, gy + 2)], 2, PIG["sky"], density=0.2, wobble=0.6, taper=True, edge=0.1)
    s.stroke([(880, gy + 1), (1120, gy)], 2, PIG["sky"], density=0.2, wobble=0.6, taper=True, edge=0.1)

# ---- shadows on the wall
for b, h in zip(blades, handles):
    s.wash(np.vstack([b, h]) + [14, 10], PIG["payne"], density=0.13, spread=0.01, feather=6, edge=0.0, holes=[b, h], hole_soft=1)

# ---- the strip, reserved where the blades cross it
strip = rect(200, STRIP[0], 1210, STRIP[1] - STRIP[0])
s.wash(strip, PIG["sepia"], density=1.05, spread=0.003, feather=1, edge=1.0, grade=(90, 0.35), holes=blades, hole_soft=0.4)
s.wash(rect(200, STRIP[0] + 18, 1210, 10), PIG["grey"], density=0.6, spread=0.003, feather=0.6, edge=0.6, holes=blades, hole_soft=0.4)
# the strip's edges, broken where a blade lies over them
cuts = sorted([(b[:, 0].min() - 2, b[:, 0].max() + 2) for b in blades if b[:, 1].min() < STRIP[0]])
for y in STRIP:
    x0 = 196
    for (a, b) in cuts + [(1414, 1414)]:
        if a - x0 > 6:
            s.ink(np.linspace((x0, y), (a, y), 8), width=1.25, density=1.8)
        x0 = b
for x in (200, 1410):
    s.ink([(x, STRIP[0] - 2), (x, STRIP[1] + 2)], width=1.25, density=1.8)

# ---- blades: steel, cool grey, a highlight down the spine left as paper
for (blade, handle, hpig, rivets, name, x) in knives:
    xs = blade[:, 0]
    spine_hl = np.array([(x + 4, blade[:, 1].min() + 40), (x + 9, blade[:, 1].min() + 40), (x + 9, blade[:, 1].max() - 20), (x + 4, blade[:, 1].max() - 20)])
    s.wash(blade, PIG["sky"], density=0.42, spread=0.002, feather=0.8, edge=1.1, grade=(0, 0.6), holes=[spine_hl], hole_soft=0.6)
    s.wash(blade, PIG["payne"], density=0.18, spread=0.002, feather=0.8, edge=0.6, grade=(180, 0.9), holes=[spine_hl])
    s.ink(blade, closed=True, width=1.25, density=1.9, wobble=0.3)
    if name == "cleaver":
        hole = ell(x + 104, 150, 11, 11, 20)
        s.ink(np.vstack([hole, hole[:1]]), width=1.1, density=1.8)
    if name == "santoku":
        for yy in np.linspace(220, 420, 6):
            s.wash(ell(x + 48, yy, 5, 11, 14), PIG["payne"], density=0.22, spread=0.02, feather=0.4, edge=0.8)
    # a bevel line a little in from the edge
    right = blade[blade[:, 0] > x + 10]
    if len(right) > 4:
        bev = right[np.argsort(right[:, 1])]
        s.ink(bev - [9, 0], width=0.7, density=0.9, wobble=0.3)
    # bolster and handle
    s.wash(handle, PIG[hpig], density=1.0, spread=0.004, feather=0.8, edge=1.1, grade=(0, 0.5), bloom=0)
    hy = handle[:, 1].min()
    s.wash(rect(handle[:, 0].min() - 1, hy - 2, handle[:, 0].max() - handle[:, 0].min() + 2, 16), PIG["grey"], density=0.7, spread=0.003, feather=0.5, edge=0.8)
    s.ink(handle, closed=True, width=1.3, density=2.0, wobble=0.3)
    for (rx, ry) in rivets:
        s.wash(ell(rx, ry, 6, 6, 14), PIG["ochre"], density=0.9, spread=0.02, feather=0.3, edge=0.8)
        s.ink(arc(rx, ry, 6, 6, 0, 360, 20), width=0.8, density=1.4)

s.save(os.path.join(OUT, "knives.png"), crop=(80, 10, 1520, 760))

