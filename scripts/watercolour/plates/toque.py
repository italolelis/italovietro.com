import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT

W = H = 1000
s = Sheet(W, H, scale=2, s=43)

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

# ---- geometry -----------------------------------------------------------
shelf_top, shelf_face, shelf_bot = 330, 344, 380
tx = 330
band_top, band_bot = 278, shelf_top + 4
band = np.array([(tx - 74, band_top), (tx + 74, band_top), (tx + 72, band_bot), (tx - 72, band_bot)])
# the crown: one continuous scalloped outline, wider than the band
L, Rr, top = tx - 112, tx + 112, 120
us = np.linspace(0, 1, 140)
scal = np.stack([L + (Rr - L) * us, top + 22 - 30 * np.abs(np.sin(np.pi * 5 * us)) * (0.75 + 0.25 * np.sin(np.pi * us))], 1)
crown = np.vstack([[(tx - 74, band_top + 4), (tx - 102, 220), (L, 160)], scal, [(Rr, 160), (tx + 102, 220), (tx + 74, band_top + 4)]])

ax, peg_y = 596, 362
bib_top = 420
apron = np.array([(ax - 62, bib_top), (ax + 62, bib_top), (ax + 68, 520), (ax + 122, 536),
                  (ax + 140, 880), (ax + 92, 892), (ax + 30, 884), (ax - 30, 893), (ax - 92, 884), (ax - 140, 878),
                  (ax - 120, 536), (ax - 68, 520)])

# ---- wall ---------------------------------------------------------------
wall = deform(np.array([(150, 90), (860, 70), (900, 900), (120, 930)]), 3, 0.06, rng)
s.wash(wall, PIG["ochre"], density=0.13, spread=0.06, feather=30, edge=0.2, blotch=0.55, grade=(60, 0.5),
       holes=[crown], hole_soft=1.2)
s.wash(deform(ell(430, 300, 240, 200, 16), 2, 0.2, rng), PIG["sky"], density=0.08, spread=0.1, feather=30, edge=0.1, holes=[crown])

# ---- shelf: top surface lighter, front face darker, shadow beneath ----------
s.wash(np.array([(120, shelf_top), (880, shelf_top), (892, shelf_face), (108, shelf_face)]), PIG["ochre"], density=0.75,
       spread=0.004, feather=1, edge=0.8, holes=[band], hole_soft=0.5)
face = rect(108, shelf_face, 784, shelf_bot - shelf_face)
s.wash(face, PIG["sienna"], density=0.95, spread=0.004, feather=1, edge=1.0, grade=(90, 0.3), bloom=1)
for k in range(4):
    y = shelf_face + 7 + k * 8
    xs = np.linspace(116, 884, 50)
    s.stroke(np.stack([xs, y + np.sin(xs * 0.012 + k * 1.7) * 2], 1), 1.5, PIG["sepia"], density=0.5, wobble=0.4, taper=False, edge=0.2)
sketch(s, np.array([(120, shelf_top), (880, shelf_top), (892, shelf_face), (892, shelf_bot), (108, shelf_bot), (108, shelf_face)]), overshoot=5, width=1.4)
s.ink([(108, shelf_face), (892, shelf_face)], width=1.2, density=1.6)
s.wash(np.array([(116, shelf_bot), (884, shelf_bot), (870, shelf_bot + 26), (130, shelf_bot + 26)]), PIG["payne"],
       density=0.22, spread=0.01, feather=5, grade=(90, 0.95), edge=0.0, holes=[apron])
peg = ell(ax, peg_y, 13, 13, 20)
s.wash(peg, PIG["sepia"], density=1.2, spread=0.02, feather=0.6, edge=0.9)
s.ink(arc(ax, peg_y, 13, 13, 0, 360, 30), width=1.0)

# ---- toque: paper white; cool shadows and a few pleats carry the form ------
shade = np.vstack([[(tx + 20, 150)], scal[95:], [(Rr, 160), (tx + 102, 220), (tx + 74, band_top + 2), (tx + 30, band_top)]])
s.wash(shade, PIG["sky"], density=0.34, spread=0.03, feather=6, edge=0.5, grade=(180, 0.8))
s.wash(np.array([(L + 8, 150), (Rr - 8, 150), (Rr - 20, 176), (L + 20, 176)]), PIG["sky"], density=0.16, spread=0.05, feather=8, edge=0.1)
for k, x in enumerate(np.linspace(tx - 64, tx + 64, 7)):
    s.stroke([(x, band_top - 4), (x + (x - tx) * 0.18, 214), (x + (x - tx) * 0.42, 150)], 4, PIG["sky"],
             density=0.30 + 0.12 * (x > tx), wobble=1.2, edge=0.6, gran=0.3)
s.wash(band, PIG["grey"], density=0.16, spread=0.01, feather=1, edge=0.6, grade=(0, 0.85))
s.ink(scal, width=1.3, density=2.0)
s.ink([(tx - 74, band_top + 1), (tx - 102, 220), (L, 162)], width=1.3)
s.ink([(tx + 74, band_top + 1), (tx + 102, 220), (Rr, 162)], width=1.3)
sketch(s, band, overshoot=3, width=1.3)
s.wash(np.array([(tx + 76, band_top + 6), (tx + 132, band_top + 18), (tx + 128, shelf_top), (tx + 72, shelf_top)]), PIG["payne"],
       density=0.2, spread=0.04, feather=6, edge=0.0)

# ---- apron: hangs from the peg on its neck strap -----------------------------
s.wash(apron + [18, 12], PIG["payne"], density=0.14, spread=0.02, feather=12, edge=0.0, holes=[apron], hole_soft=2)
for (a, b) in [((ax - 58, bib_top + 2), (ax - 8, peg_y - 10)), ((ax + 8, peg_y - 10), (ax + 58, bib_top + 2))]:
    s.stroke([a, b], 7, PIG["sienna"], density=0.95, wobble=0.5, taper=False, edge=0.8)
    s.ink([a, b], width=1.0, density=1.5)
s.stroke([(ax - 9, peg_y - 11), (ax, peg_y - 16), (ax + 9, peg_y - 11)], 7, PIG["sienna"], density=0.95, wobble=0.2, taper=False, edge=0.8)
s.wash(apron, PIG["amber"], density=0.72, spread=0.006, feather=1.5, edge=1.15, grade=(0, 0.35), bloom=2)
for (x0, xm, x1, w, d) in [(ax - 70, ax - 86, ax - 104, 16, 0.32), (ax - 6, ax - 2, ax + 6, 10, 0.26), (ax + 60, ax + 78, ax + 96, 18, 0.34)]:
    s.stroke([(x0, 560), (xm, 720), (x1, 878)], w, PIG["sienna"], density=d, wobble=3.0, edge=0.8, gran=0.4)
pocket = np.array([(ax - 58, 600), (ax + 58, 598), (ax + 56, 684), (ax - 56, 686)])
s.wash(pocket, PIG["sienna"], density=0.28, spread=0.01, feather=1, edge=1.0)
sketch(s, pocket, overshoot=2, width=1.1)
s.ink([(ax + 1, 601), (ax, 684)], width=0.8, density=1.2)
sketch(s, apron, overshoot=3, width=1.35)
for side in (-1, 1):
    x = ax + side * 120
    path = [(x, 536), (x + side * 18, 590), (x + side * 6, 650), (x + side * 22, 712), (x + side * 12, 760)]
    s.stroke(path, 6, PIG["amber"], density=1.0, wobble=1.0, taper=False, edge=1.0)
    s.ink(path, width=0.9, density=1.4)

s.save(os.path.join(OUT, "toque.png"), crop=(150, 50, 820, 950))

