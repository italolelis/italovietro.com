# The home page plate: a desk in Berlin at dusk. Everything on it comes from the
# home page's own "Beyond the Code" paragraph and the About page -- the homelab,
# the pour-over, the D&D die, a child's drawing, a postcard from the Brazilian
# coast -- with the Fernsehturm through the window. No face: the home page keeps
# portraits off it on purpose (see the avatarURL comment in config.toml).
import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT
DEST = "assets/images/plates"

W, H = 1600, 1000
s = Sheet(W, H, scale=2, s=91)

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

# ---- geometry used for reserving --------------------------------------------
WIN = (840, 110, 1390, 560)               # window opening x0, y0, x1, y1
wx0, wy0, wx1, wy1 = WIN
window = rect(wx0, wy0, wx1 - wx0, wy1 - wy0)
frame_w = 16
mull_v = rect((wx0 + wx1) / 2 - 6, wy0, 12, wy1 - wy0)
mull_h = rect(wx0, (wy0 + wy1) / 2 - 6 + 30, wx1 - wx0, 12)
drawing = rotate(rect(200, 150, 250, 230), -3)
postcard = rotate(rect(520, 236, 190, 128), 4)
DESK = 646

# ---- the wall: warm, lit from the window, cooler at the far left -------------
wall = deform(np.array([(70, 60), (800, 40), (1500, 70), (1520, DESK), (60, DESK)]), 3, 0.05, rng)
s.wash(wall, PIG["ochre"], density=0.2, spread=0.06, feather=30, grade=(180, 0.5), edge=0.2, blotch=0.5,
       holes=[window, drawing, postcard], hole_soft=1.0)
s.wash(deform(np.array([(70, 60), (520, 50), (480, DESK), (60, DESK)]), 3, 0.08, rng), PIG["sky"], density=0.12,
       spread=0.08, feather=30, grade=(0, 0.9), edge=0.1, holes=[drawing], hole_soft=1.0)

# ---- through the window: dusk over Berlin, the tower against it --------------
panes = [window]
s.wash(window, PIG["ochre"], density=0.5, spread=0.0, feather=1.0, grade=(-90, 1.0), edge=0.2, blotch=0.2,
       holes=[mull_v, mull_h], hole_soft=0.5)
s.wash(window, PIG["rose"], density=0.45, spread=0.0, feather=1.0, grade=(-90, 0.85), edge=0.1, blotch=0.2,
       holes=[mull_v, mull_h], hole_soft=0.5)
s.wash(rect(wx0, wy0, wx1 - wx0, 260), PIG["indigo"], density=0.9, spread=0.0, feather=1.0, grade=(90, 0.95),
       edge=0.1, blotch=0.25, gran=0.3, holes=[mull_v, mull_h], hole_soft=0.5)
# skyline, low and dark, with the Fernsehturm rising out of it
skyline = [(wx0, wy1)]
x = wx0
while x < wx1:
    bw = rng.uniform(30, 70); bh = rng.uniform(40, 110)
    skyline += [(x, wy1 - bh), (min(x + bw, wx1), wy1 - bh)]
    x += bw
skyline += [(wx1, wy1)]
s.wash(np.array(skyline), PIG["payne"], density=1.0, spread=0.0, feather=0.8, edge=0.8, blotch=0.2,
       holes=[mull_v, mull_h], hole_soft=0.5)
tx = 1205
shaft = np.array([(tx - 9, wy1 - 60), (tx + 9, wy1 - 60), (tx + 5, 300), (tx - 5, 300)])
sphere = ell(tx, 288, 26, 24, 30)
needle = np.array([(tx - 2.5, 264), (tx + 2.5, 264), (tx + 1.2, 168), (tx - 1.2, 168)])
for part in (shaft, sphere, needle):
    s.wash(part, PIG["payne"], density=1.2, spread=0.0, feather=0.5, edge=0.6, blotch=0.1,
           holes=[mull_v, mull_h], hole_soft=0.4)
s.wash(ell(tx, 312, 12, 4, 16), PIG["payne"], density=1.2, spread=0.0, feather=0.4, edge=0.5)
s.dots([(tx, 170)], 2.2, PIG["vermilion"], density=1.2)
for (lx, ly) in [(wx0 + 60, wy1 - 50), (wx0 + 150, wy1 - 70), (wx1 - 90, wy1 - 40), (wx1 - 200, wy1 - 60)]:
    s.dots([(lx + rng.uniform(-8, 8), ly + rng.uniform(-6, 6))], 2.4, PIG["ochre"], density=0.9)
# frame and sill
s.wash(np.array([(wx0 - frame_w, wy0 - frame_w), (wx1 + frame_w, wy0 - frame_w), (wx1 + frame_w, wy1 + frame_w),
                 (wx0 - frame_w, wy1 + frame_w)]), PIG["grey"], density=0.18, spread=0.0, feather=0.8, edge=0.6,
       holes=[window], hole_soft=0.5)
s.wash(rect(wx0 - 30, wy1 + frame_w, wx1 - wx0 + 60, 18), PIG["grey"], density=0.3, spread=0.0, feather=0.8, edge=0.7)
sketch(s, window, overshoot=3, width=1.3)
sketch(s, np.array([(wx0 - frame_w, wy0 - frame_w), (wx1 + frame_w, wy0 - frame_w), (wx1 + frame_w, wy1 + frame_w),
                    (wx0 - frame_w, wy1 + frame_w)]), overshoot=4, width=1.2, density=1.6)
s.ink([(wx0 - 30, wy1 + frame_w + 18), (wx1 + 30, wy1 + frame_w + 18)], width=1.2, density=1.6)

# ---- a child's drawing, taped up ------------------------------------------------
s.wash(drawing + [8, 9], PIG["payne"], density=0.14, spread=0.01, feather=5, edge=0.0, holes=[drawing], hole_soft=1)
sketch(s, drawing, overshoot=2, width=1.0, density=1.4)
def crayon(pts, pig, w=6, d=1.0):
    s.stroke(rotate(np.array(pts, float), -3, 325, 265), w, PIG[pig], density=d, wobble=1.0, dry=0.55, edge=0.2, gran=0.9, taper=False)
def wax(cx, cy, r, pig, d=0.95):
    # a crayon-filled disc: dense, grainy, edges that skip
    pts = rotate(circle(cx, cy, r, 14), -3, 325, 265)
    s.wash(pts, PIG[pig], density=d, spread=0.06, feather=1.2, layers=20, edge=0.5, gran=1.6, blotch=0.4)
wax(395, 192, 22, "ochre")                                           # sun
for a in range(0, 360, 45):
    r = np.radians(a)
    crayon([(395 + 30 * np.cos(r), 192 + 30 * np.sin(r)), (395 + 46 * np.cos(r), 192 + 46 * np.sin(r))], "ochre", w=5)
crayon([(212, 352), (300, 348), (440, 354)], "sage", w=9, d=0.9)       # grass
figs = [(250, 250, 1.0, "indigo"), (305, 255, 0.95, "vermilion"), (352, 290, 0.6, "rose")]
for (fx, fy, k, pig) in figs:
    wax(fx, fy - 28 * k, 13 * k, pig)                                    # head
    crayon([(fx, fy - 14 * k), (fx, fy + 40 * k)], pig, w=5)            # body
    crayon([(fx, fy + 40 * k), (fx - 14 * k, fy + 80 * k)], pig, w=5)
    crayon([(fx, fy + 40 * k), (fx + 14 * k, fy + 80 * k)], pig, w=5)
crayon([(250, 262), (278, 270), (305, 266)], "indigo", w=4)            # holding hands
crayon([(305, 266), (330, 278), (352, 286)], "vermilion", w=4)
for (cx, cy) in [(215, 160), (430, 152)]:
    s.wash(rotate(rect(cx - 22, cy - 8, 44, 16), rng.uniform(-20, 20)), PIG["ochre"], density=0.25, spread=0.02, feather=0.6, edge=0.4)

# ---- a postcard from the Brazilian coast ------------------------------------------
pcx, pcy = 615, 300
def pc(pts): return rotate(np.array(pts, float), 4, pcx, pcy)
s.wash(postcard + [6, 7], PIG["payne"], density=0.14, spread=0.01, feather=4, edge=0.0, holes=[postcard], hole_soft=1)
s.wash(pc(rect(530, 246, 170, 60)), PIG["sky"], density=0.55, spread=0.0, feather=0.5, edge=0.5, grade=(90, 0.6))
s.wash(pc(rect(530, 306, 170, 22)), PIG["teal"], density=0.75, spread=0.0, feather=0.5, edge=0.7)
s.wash(pc(rect(530, 328, 170, 26)), PIG["ochre"], density=0.6, spread=0.0, feather=0.5, edge=0.6)
s.wash(pc(ell(670, 268, 14, 14, 16)), PIG["ochre"], density=0.8, spread=0.02, feather=0.4, edge=0.6)
s.stroke(pc([(575, 340), (580, 300), (590, 270)]), 5, PIG["sienna"], density=1.0, wobble=0.5, taper=False, edge=0.6)
for a in (-150, -110, -60, -20, 20):
    r = np.radians(a)
    s.stroke(pc([(590, 270), (590 + 30 * np.cos(r), 270 + 18 * np.sin(r) + 8)]), 5, PIG["sage"], density=1.0, wobble=0.6, edge=0.6)
sketch(s, postcard, overshoot=2, width=1.0, density=1.4)
s.dots([tuple(pc([(615, 244)])[0])], 5, PIG["vermilion"], density=1.2)

# ---- the desk ----------------------------------------------------------------------
top = np.array([(40, DESK), (1560, DESK), (1580, DESK + 70), (20, DESK + 70)])
s.wash(top, PIG["sienna"], density=0.55, spread=0.004, feather=2, edge=0.9, grade=(90, 0.35), blotch=0.4)
s.wash(deform(ell(1000, DESK + 30, 520, 40, 24), 2, 0.1, rng), PIG["ochre"], density=0.35, spread=0.1, feather=20, edge=0.0)
for k in range(5):
    y = DESK + 12 + k * 12 + rng.uniform(-3, 3)
    x0 = rng.uniform(40, 300); x1 = rng.uniform(1200, 1560)
    xs = np.linspace(x0, x1, 60)
    s.stroke(np.stack([xs, y + np.sin(xs * rng.uniform(0.004, 0.012) + k) * 3], 1), 1.4, PIG["sepia"], density=0.28, wobble=1.2, taper=True, edge=0.1)
face = np.array([(20, DESK + 70), (1580, DESK + 70), (1580, DESK + 118), (20, DESK + 118)])
s.wash(face, PIG["sienna"], density=1.0, spread=0.004, feather=1.5, edge=1.0, grade=(90, 0.2), bloom=1)
sketch(s, np.array([(40, DESK), (1560, DESK), (1580, DESK + 70), (20, DESK + 70)]), overshoot=5, width=1.3)
s.ink([(20, DESK + 118), (1580, DESK + 118)], width=1.3, density=1.6)

# ---- the homelab: three small nodes, LEDs, cables ------------------------------------
nodes = [rect(120, DESK - 46 * (i + 1) + 4, 230, 42) for i in range(3)]
for i, n in enumerate(nodes):
    s.wash(n + [10, 8], PIG["payne"], density=0.18, spread=0.01, feather=4, edge=0.0) if i == 0 else None
    s.wash(n, PIG["payne"], density=1.05 - 0.12 * i, spread=0.002, feather=0.6, edge=1.0, grade=(0, 0.35), blotch=0.15)
    sketch(s, n, overshoot=2, width=1.1, density=1.6)
    y = n[0][1] + 21
    s.dots([(140, y), (156, y)], 3.2, PIG["sage"] * 1.05, density=1.3)
    s.dots([(172, y)], 3.2, PIG["amber"], density=1.3)
    for vx in np.arange(250, 340, 9):
        s.ink([(vx, y - 9), (vx, y + 9)], width=0.8, density=0.9)
for k, y0 in enumerate([DESK - 22, DESK - 68, DESK - 114]):
    t = np.linspace(0, 1, 30)
    x = 120 - 70 * t - 18 * k * t
    y = y0 + (DESK + 40 + 10 * k - y0) * t ** 1.6
    s.ink(np.stack([x, y], 1), width=1.6, density=1.9, wobble=0.4)
    s.ink([(x[-1], y[-1]), (x[-1] - 6, DESK + 118)], width=1.6, density=1.9)

# ---- the pour-over: kettle, dripper, carafe, scale ------------------------------------
scale = np.array([(640, DESK - 22), (840, DESK - 22), (846, DESK), (634, DESK)])
s.wash(scale, PIG["payne"], density=0.95, spread=0.002, feather=0.6, edge=1.0)
sketch(s, scale, overshoot=2, width=1.1)
disp = rect(800, DESK - 15, 30, 9)
s.wash(disp, PIG["ochre"], density=0.9, spread=0.0, feather=0.3, edge=0.4)
cx = 740
carafe = np.vstack([arc(cx, DESK - 64, 58, 40, 0, 180, 24)[::-1][::-1], [(cx - 58, DESK - 64), (cx - 30, DESK - 118), (cx + 30, DESK - 118), (cx + 58, DESK - 64)]])
carafe = np.vstack([[(cx + 30, DESK - 118), (cx + 58, DESK - 64)], arc(cx, DESK - 64, 58, 40, 0, 180, 24), [(cx - 58, DESK - 64), (cx - 30, DESK - 118)]])
s.wash(carafe, PIG["sky"], density=0.25, spread=0.002, feather=0.8, edge=1.0, holes=[rect(cx - 40, DESK - 100, 8, 50)], hole_soft=0.6)
coffee = np.vstack([[(cx + 54, DESK - 56)], arc(cx, DESK - 64, 56, 38, 10, 170, 20), [(cx - 54, DESK - 56)]])
s.wash(coffee, PIG["sepia"], density=1.1, spread=0.003, feather=0.6, edge=1.1)
s.ink(carafe, closed=True, width=1.3, density=1.8)
dripper = np.array([(cx - 70, DESK - 186), (cx + 70, DESK - 186), (cx + 24, DESK - 122), (cx - 24, DESK - 122)])
s.wash(dripper, PIG["grey"], density=0.16, spread=0.002, feather=0.6, edge=0.9, grade=(0, 0.8))
s.wash(rect(cx - 38, DESK - 124, 76, 8), PIG["grey"], density=0.3, spread=0.0, feather=0.4, edge=0.6)
sketch(s, dripper, overshoot=2, width=1.3)
# the kettle, resting on the desk beside the scale
kx, ky = 515, DESK - 104
body = np.vstack([arc(kx, ky + 40, 62, 56, 180, 360, 24), [(kx + 62, ky + 40), (kx + 66, ky + 102), (kx - 66, ky + 102), (kx - 62, ky + 40)]])
s.wash(body + [10, 6], PIG["payne"], density=0.2, spread=0.01, feather=4, edge=0.0, holes=[body])
s.wash(body, PIG["payne"], density=1.15, spread=0.002, feather=0.6, edge=1.0, grade=(0, 0.4), holes=[ell(kx - 30, ky + 30, 6, 24, 16)], hole_soft=0.8)
s.ink(body, closed=True, width=1.3, density=1.8)
s.ink(arc(kx - 4, ky + 2, 44, 34, 200, 340, 20), width=4.0, density=2.2)          # handle loop on top
s.wash(ell(kx - 4, ky - 18, 9, 5, 12), PIG["payne"], density=1.2, spread=0.0, feather=0.4, edge=0.5)
spout = [(kx + 56, ky + 86), (kx + 90, ky + 80), (kx + 104, ky + 46), (kx + 118, ky + 22), (kx + 134, ky + 14)]
s.stroke(spout, 9, PIG["payne"], density=1.3, wobble=0.3, taper=False, edge=0.8)
s.ink(spout, width=1.1, density=1.6)
for dx in (-16, 6, 26):
    s.stroke([(cx + dx, DESK - 196), (cx + dx - 10, DESK - 236), (cx + dx + 6, DESK - 276), (cx + dx - 4, DESK - 310)], 9, PIG["grey"],
             density=0.14, wobble=4, edge=0.6, gran=0.1)

# ---- a d20, mid-roll -------------------------------------------------------------------
dx_, dy_ = 1010, DESK + 22
hexa = circle(dx_, dy_, 40, 6, a0=np.pi / 6)
s.wash(hexa + [6, 8], PIG["payne"], density=0.2, spread=0.02, feather=4, edge=0.0, holes=[hexa])
s.wash(hexa, PIG["vermilion"], density=0.75, spread=0.002, feather=0.5, edge=1.1, grade=(30, 0.5))
inner = circle(dx_, dy_ + 3, 23, 3, a0=-np.pi / 2)
s.wash(inner, PIG["vermilion"], density=0.3, spread=0.0, feather=0.4, edge=0.6)
s.ink(np.vstack([hexa, hexa[:1]]), width=1.3, density=1.9)
s.ink(np.vstack([inner, inner[:1]]), width=1.0, density=1.6)
for v in range(6):
    s.ink([hexa[v], inner[[0, 1, 1, 2, 2, 0][v]]], width=0.8, density=1.3)

# ---- a closed notebook and a pen ---------------------------------------------------------
nb = np.array([(1140, DESK - 6), (1400, DESK - 10), (1430, DESK + 44), (1150, DESK + 50)])
s.wash(nb + [6, 6], PIG["payne"], density=0.2, spread=0.01, feather=4, edge=0.0, holes=[nb])
s.wash(nb, PIG["indigo"], density=0.85, spread=0.002, feather=0.6, edge=1.0, grade=(0, 0.3), bloom=1)
s.stroke([(1360, DESK - 9), (1386, DESK + 47)], 5, PIG["sepia"], density=1.0, wobble=0.2, taper=False, edge=0.5)
sketch(s, nb, overshoot=2, width=1.2)
s.stroke([(1180, DESK + 60), (1420, DESK + 54)], 8, PIG["ochre"], density=0.9, wobble=0.3, taper=False, edge=0.8)
s.ink([(1180, DESK + 57), (1420, DESK + 51)], width=0.9, density=1.4)
s.ink([(1180, DESK + 63), (1420, DESK + 57)], width=0.9, density=1.4)

s.save(os.path.join(OUT, "desk.png"), crop=(0, 20, 1600, 800))
