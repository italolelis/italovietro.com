import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT
DEST = "content/episodes/shipping-more-not-faster"

W, H = 1600, 1000
s = Sheet(W, H, scale=2, s=5)

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

base_y = 740
teeth = 6
x0, x1 = 230, 1180
tw = (x1 - x0) / teeth
roof = [(x0, base_y - 290)]
for i in range(teeth):
    xa = x0 + i * tw
    roof += [(xa, base_y - 370), (xa + tw, base_y - 290)]
body = np.array(roof + [(x1, base_y), (x0, base_y)])

rows = [base_y - 230, base_y - 125]
cols = np.linspace(x0 + 45, x1 - 105, 8)
LIT = (1, 5)
wins = {(ri, ci): rect(wx, wy, 58, 68) for ri, wy in enumerate(rows) for ci, wx in enumerate(cols)}
lit_win = wins[LIT]
moon = ell(430, 200, 54, 54, 36)

# Sky at dusk: indigo at the top, warming to a rose-ochre band at the horizon.
sky = np.array([[70, 70], [1530, 60], [1540, base_y + 10], [60, base_y + 14]])
s.wash(sky, PIG["ochre"], density=0.34, spread=0.05, feather=16, grade=(-90, 1.0), edge=0.1, blotch=0.25, holes=[moon])
s.wash(sky, PIG["rose"], density=0.32, spread=0.05, feather=16, grade=(-90, 0.9), edge=0.1, blotch=0.25, holes=[moon])
s.wash(np.array([[70, 70], [1530, 60], [1540, 560], [60, 580]]), PIG["indigo"], density=0.95, spread=0.05, feather=30,
       layers=48, grade=(90, 0.95), edge=0.15, blotch=0.25, gran=0.35, holes=[moon], hole_soft=1.4, bloom=1)
s.ink(arc(430, 200, 54, 54, 120, 250, 30), width=0.9, density=0.9)

# The shed: a dark indigo-grey silhouette, with the one window reserved.
s.wash(body, PIG["payne"], density=1.05, spread=0.004, feather=1.2, layers=40, edge=1.0, grade=(0, 0.25), blotch=0.2,
       holes=[lit_win], hole_soft=0.6)
s.wash(body, PIG["indigo"], density=0.45, spread=0.004, feather=1.2, edge=0.4, blotch=0.2, holes=[lit_win], hole_soft=0.6)
for i in range(teeth):
    xa = x0 + i * tw
    glass = np.array([(xa + 8, base_y - 362), (xa + 16, base_y - 366), (xa + 16, base_y - 296), (xa + 8, base_y - 294)])
    s.wash(glass, PIG["sky"], density=0.25, spread=0.02, feather=0.8, edge=0.4)
sketch(s, np.array(roof + [(x1, base_y)]), closed=False, overshoot=3, width=1.3, density=1.5)

ch = rect(1240, 330, 46, 410)
s.wash(ch, PIG["payne"], density=1.15, spread=0.004, feather=1.2, edge=1.0, grade=(0, 0.3), blotch=0.2)
s.wash(rect(1234, 320, 58, 18), PIG["payne"], density=1.3, spread=0.004, feather=0.8, edge=1.0)
sketch(s, ch, overshoot=2, width=1.1, density=1.3)

# Dark windows, darker than the wall, ruled lightly.
for k, win in wins.items():
    if k == LIT:
        continue
    s.wash(win, PIG["indigo"], density=0.75, spread=0.01, feather=0.6, edge=1.0, blotch=0.1)
    wx, wy = win[0]
    s.ink([(wx + 29, wy + 2), (wx + 29, wy + 66)], width=0.8, density=0.9)
    s.ink([(wx + 2, wy + 34), (wx + 56, wy + 34)], width=0.8, density=0.9)

# The lit window: warm, with someone at a desk.
wx, wy = lit_win[0]
s.wash(lit_win, PIG["ochre"], density=0.8, spread=0.005, feather=0.5, edge=0.8, blotch=0.15)
s.wash(rect(wx + 2, wy + 36, 54, 32), PIG["amber"], density=0.55, spread=0.01, feather=0.8, edge=0.8)
s.wash(ell(wx + 24, wy + 28, 7, 8, 16), PIG["sepia"], density=1.5, spread=0.02, feather=0.4, edge=0.3)
s.wash(np.array([(wx + 13, wy + 68), (wx + 16, wy + 42), (wx + 32, wy + 40), (wx + 37, wy + 68)]), PIG["sepia"], density=1.5, spread=0.02, feather=0.4, edge=0.3)
s.wash(rect(wx + 36, wy + 50, 20, 4), PIG["sepia"], density=1.2, spread=0.02, feather=0.4, edge=0.3)
sketch(s, lit_win, overshoot=1.5, width=1.0, density=1.4)

# Ground: graded dark, with the window's light lying across it.
ground = np.array([[60, base_y], [1540, base_y - 4], [1530, 900], [80, 910]])
spill = np.array([(wx - 6, base_y + 2), (wx + 64, base_y + 2), (wx + 220, 900), (wx - 160, 900)])
s.wash(ground, PIG["payne"], density=0.6, spread=0.02, feather=16, grade=(90, 0.85), edge=0.15, blotch=0.3, gran=0.3)
s.wash(spill, PIG["amber"], density=0.32, spread=0.06, feather=18, grade=(90, 0.9), edge=0.0, gran=0.1)
s.ink([(70, base_y + 1), (1530, base_y - 3)], width=1.3, density=1.6)

s.save(os.path.join(OUT, "factory.png"))

