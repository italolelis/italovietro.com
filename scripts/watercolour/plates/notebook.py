import os, sys; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from wc import *
from wc import OUT
DEST = "content/episodes/shipping-more-not-faster"

W = H = 1000
s = Sheet(W, H, scale=2, s=31)
C = (500, 520)
ANG = -7

def R(pts):
    return rotate(np.asarray(pts, np.float64), ANG, *C)

def ell(cx, cy, rx, ry, n=40):
    return circle(cx, cy, 0, n, rx=rx, ry=ry)

# a page with a softly bowed top and bottom edge
def page(x0, x1, y0, y1, bow, left):
    top = [(x, y0 + bow * (np.sin(np.pi * (x - x0) / (x1 - x0)) if False else ((x - x0) / (x1 - x0) if left else (x1 - x) / (x1 - x0))) ** 2) for x in np.linspace(x0, x1, 16)]
    bot = [(x, y1 + bow * 0.6 * (((x - x0) / (x1 - x0)) if left else ((x1 - x) / (x1 - x0))) ** 2) for x in np.linspace(x1, x0, 16)]
    return np.array(top + bot)

L = page(122, 500, 268, 768, 10, True)
Rp = page(500, 878, 268, 768, 10, False)
pages = [R(L), R(Rp)]

# soft cast shadow, then the leather cover peeking out around the pages
cover = R(rect(104, 252, 792, 532))
s.wash(R(rect(118, 262, 790, 534)) + [16, 20], PIG["payne"], density=0.22, spread=0.02, feather=14, edge=0.0, gran=0.2, holes=[cover], hole_soft=2)
s.wash(cover, PIG["sienna"], density=0.95, spread=0.01, feather=1.5, edge=1.1, grade=(30, 0.35), holes=pages, hole_soft=0.5, bloom=1)
sketch(s, cover, overshoot=3, width=1.4)

# gutter shading on both pages, darkest at the fold
s.wash(R(rect(458, 272, 42, 494)), PIG["payne"], density=0.2, spread=0.01, feather=5, grade=(180, 1.0), edge=0.0, gran=0.15)
s.wash(R(rect(500, 272, 42, 494)), PIG["payne"], density=0.2, spread=0.01, feather=5, grade=(0, 1.0), edge=0.0, gran=0.15)

# ruled lines
for (x0, x1) in [(140, 482), (518, 860)]:
    for k in range(15):
        y = 318 + k * 29
        s.stroke(R([(x0, y), (x1, y)]), 1.6, PIG["sky"], density=0.55, wobble=0.3, taper=False, edge=0.1, gran=0.2)

# left page: handwriting, a heading underlined
cursive(s, 150, 296, 170, size=9, transform=R, ink_width=1.2)
s.ink(R([(148, 305), (330, 303)]), width=1.2, density=1.7)
for k in range(13):
    y = 340 + k * 29
    w = rng.uniform(230, 325) if k not in (4, 9) else rng.uniform(100, 170)
    cursive(s, 150, y - 7, w, size=7.5, transform=R)
    if k == 6:
        # a phrase circled, the way you do when you have just realised something
        s.ink(R(arc(232, y - 8, 56, 15, 200, 560, 60)), width=1.2, density=2.0, color=PIG["vermilion"] * 0.7)

# right page: a small design, boxes and arrows, one box washed in ochre
boxes = [(560, 330, 110, 60), (720, 330, 110, 60), (640, 470, 110, 60), (560, 610, 110, 60)]
s.wash(R(rect(*boxes[2])), PIG["ochre"], density=0.6, spread=0.03, feather=2.5, edge=1.0)
for b in boxes:
    sketch(s, R(rect(*b)), overshoot=4, width=1.3)
    cursive(s, b[0] + 14, b[1] + b[3] / 2 + 2, b[2] - 30, size=6, transform=R, ink_width=0.9, density=1.5)
def arrow(a, b):
    a, b = np.array(a, float), np.array(b, float)
    s.ink(R(np.linspace(a, b, 6)), width=1.2, density=1.9)
    d = (b - a) / np.linalg.norm(b - a)
    n = np.array([-d[1], d[0]])
    s.ink(R([b - d * 12 + n * 6, b, b - d * 12 - n * 6]), width=1.2, density=1.9)
arrow((670, 360), (716, 360))
arrow((615, 392), (668, 466))
arrow((775, 392), (722, 466))
arrow((690, 532), (640, 606))

# ribbon bookmark falling out of the gutter
s.stroke(R([(500, 760), (506, 820), (498, 868), (512, 900)]), 9, PIG["vermilion"], density=0.85, wobble=1.0, taper=False, edge=0.9)

# the pen, lying across the right page
p0, p1 = np.array([600.0, 840.0]), np.array([905.0, 470.0])
d = (p1 - p0) / np.linalg.norm(p1 - p0)
n = np.array([-d[1], d[0]])
def quad(a, b, w0, w1):
    return np.array([a + n * w0, b + n * w1, b - n * w1, a - n * w0])
s.wash(quad(p0 + n * -9 + [10, 12], p1 + [10, 12], 10, 12), PIG["payne"], density=0.25, spread=0.02, feather=6, edge=0.0)
nib_end = p0 + d * 40
s.wash(quad(p0, nib_end, 2, 9), PIG["ochre"], density=0.8, spread=0.01, feather=0.8, edge=0.9)
body = quad(nib_end, p1, 10, 11)
hl = quad(nib_end + d * 20 + n * 4, p1 - d * 20 + n * 4, 1.6, 1.6)
s.wash(body, PIG["indigo"], density=1.15, spread=0.005, feather=0.8, edge=1.0, holes=[hl], hole_soft=0.8)
clip = quad(p1 - d * 120 + n * 9, p1 - d * 20 + n * 9, 2.5, 2.5)
s.wash(clip, PIG["ochre"], density=0.9, spread=0.01, feather=0.6, edge=0.8)
sketch(s, quad(p0, nib_end, 2, 9), overshoot=1.5, width=1.0)
sketch(s, body, overshoot=2, width=1.2)

for pg in pages:
    sketch(s, pg, overshoot=0, width=1.1, density=1.6)

s.save(os.path.join(OUT, "notebook.png"), crop=(40, 150, 960, 950))

