"""
A small procedural watercolour engine, for the Plates (layouts/partials/plate.html):
the Episode pages' and the home page's. Run it through paint.py; see there for usage,
and for how a plate script says where its Plate lives.

Model: each wash accumulates pigment *density* D on a float field. Densities are
turned into colour with Beer-Lambert -- paper * pigment ** D -- so overlapping
glazes darken and saturate the way transparent watercolour does, rather than
averaging like opaque paint. It also means nothing light can be painted over
anything dark, exactly as on paper: a lit window or a white plate has to be
*reserved* from the washes around it (the `holes` argument), the way a painter
uses masking fluid.

Washes are built Tyler-Hobbs style: one base polygon, recursively deformed, then
dozens of copies jittered at the edge and stacked at low opacity. The soft,
irregular edge and the denser middle fall out of the stacking. On top of that:
  - edge darkening (pigment migrating to a drying wash's rim),
  - granulation (pigment settling in the paper's valleys),
  - backruns ("blooms"), the cauliflower edges of a wash disturbed while wet,
  - cold-press paper texture lit from the upper left,
  - ink lines with wobble and pressure, and a looped hand for writing,
  - a deckled sheet edge, as alpha, so a plate reads as paper on either theme.

Everything is seeded. The same script paints the same plate every time.
"""
import math
import os
import cv2
import numpy as np

rng = np.random.default_rng(7)

# Masters are written here, and gitignored: only the WebP exports are committed.
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
os.makedirs(OUT, exist_ok=True)


def seed(s):
    global rng
    rng = np.random.default_rng(s)


def hexrgb(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)], dtype=np.float32)


# A limited palette, chosen to sit with the site's amber accent (#b45309).
PIG = {
    "indigo": hexrgb("#3d4f7a"),
    "payne": hexrgb("#4a5560"),
    "amber": hexrgb("#d9822b"),
    "sienna": hexrgb("#b5603a"),
    "ochre": hexrgb("#dcae5a"),
    "sage": hexrgb("#8fa77c"),
    "teal": hexrgb("#5f9a96"),
    "rose": hexrgb("#d77a6e"),
    "vermilion": hexrgb("#d4553a"),
    "sepia": hexrgb("#5b4636"),
    "grey": hexrgb("#9c9a94"),
    "sky": hexrgb("#8fb3cf"),
}
PAPER = hexrgb("#fbf7ee")
INK = hexrgb("#2a2622")


# ---------------------------------------------------------------- noise


def fractal_noise(h, w, scales=(256, 128, 64, 32), weights=None, r=None):
    r = r or rng
    weights = weights or [1.0 / (i + 1) for i in range(len(scales))]
    out = np.zeros((h, w), np.float32)
    for s, wt in zip(scales, weights):
        gh, gw = max(2, h // s + 2), max(2, w // s + 2)
        g = r.random((gh, gw)).astype(np.float32)
        up = cv2.resize(g, (gw * s, gh * s), interpolation=cv2.INTER_CUBIC)[:h, :w]
        out += wt * up
    out -= out.min()
    out /= out.max() + 1e-6
    return out


class Sheet:
    def __init__(self, w, h, scale=2, paper=PAPER, s=1):
        seed(s)
        self.W, self.H, self.S = w, h, scale
        self.w, self.h = w * scale, h * scale
        self.paper = paper
        self.layers = []  # (density crop, pigment, x0, y0)
        # Paper height field: fine tooth plus a softer cockle.
        tooth = fractal_noise(self.h, self.w, scales=(3 * scale, 6 * scale, 12 * scale), weights=[0.5, 0.35, 0.15])
        cockle = fractal_noise(self.h, self.w, scales=(400 * scale, 200 * scale), weights=[0.7, 0.3])
        self.height = (0.8 * tooth + 0.2 * cockle).astype(np.float32)
        self.grain = fractal_noise(self.h, self.w, scales=(5 * scale, 10 * scale, 24 * scale), weights=[0.3, 0.45, 0.25])
        self.blotch = [fractal_noise(self.h, self.w, scales=(220 * scale, 110 * scale, 40 * scale), weights=[0.55, 0.3, 0.15]) for _ in range(4)]

    # -------------------------------------------------------- geometry
    def P(self, pts):
        return np.asarray(pts, np.float64) * self.S

    def _box(self, pts, pad):
        x0 = int(max(0, np.floor(pts[:, 0].min() - pad)))
        y0 = int(max(0, np.floor(pts[:, 1].min() - pad)))
        x1 = int(min(self.w, np.ceil(pts[:, 0].max() + pad)))
        y1 = int(min(self.h, np.ceil(pts[:, 1].max() + pad)))
        return x0, y0, max(x0 + 1, x1), max(y0 + 1, y1)

    @staticmethod
    def _fill(shape, poly, x0, y0):
        m = np.zeros(shape, np.uint8)
        p = np.round((poly - [x0, y0]) * 16).astype(np.int32)
        cv2.fillPoly(m, [p], 255, lineType=cv2.LINE_AA, shift=4)
        return m.astype(np.float32) / 255

    # -------------------------------------------------------- washes
    def wash(self, poly, pig, density=0.8, layers=32, spread=0.05, feather=4.0, base_depth=3,
             edge=1.0, gran=0.6, blotch=0.35, grade=None, bloom=0, holes=(), hole_soft=1.0):
        """One wash over `poly` (output px). density ~ total pigment at the centre.

        holes   -- polygons reserved from this wash, like masking fluid: the paper
                   (or whatever is beneath) shows through with a crisp edge

        spread  -- how far the overall shape wanders from the polygon (relative)
        feather -- how far individual glazes wander at the edge (output px)
        grade   -- (angle_deg, strength): a graded wash, lighter toward angle
        bloom   -- number of backruns (cauliflower blooms) to drop in
        """
        poly = self.P(poly)
        base = deform(poly, base_depth, spread, rng)
        base = resample_closed(base, 2.5 * self.S)
        x0, y0, x1, y1 = self._box(base, feather * self.S * 4 + 12 * self.S)
        shape = (y1 - y0, x1 - x0)
        D = np.zeros(shape, np.float32)
        op = density / layers * 1.6
        for i in range(layers):
            jit = rng.normal(0, 1, (len(base), 2))
            k = max(3, len(base) // 40)
            jit = smooth_closed(jit, k) * feather * self.S * 2.2
            p = deform(base + jit, 2, 0.35, rng)
            D += op * self._fill(shape, p, x0, y0)
        D = np.minimum(D, density * 1.15)
        if blotch:
            D *= (1 - blotch) + blotch * 2 * self.blotch[int(rng.integers(4))][y0:y1, x0:x1]
        if grade:
            ang, strength = grade
            yy, xx = np.mgrid[0:shape[0], 0:shape[1]].astype(np.float32)
            a = math.radians(ang)
            u = xx * math.cos(a) + yy * math.sin(a)
            ys, xs = np.nonzero(D > 0.02)
            if len(xs):
                uu = xs * math.cos(a) + ys * math.sin(a)
                u = np.clip((u - uu.min()) / (uu.max() - uu.min() + 1e-6), 0, 1)
                D *= 1 - strength * u
        for _ in range(bloom):
            self._bloom(D)
        if len(holes):
            keep = np.ones(shape, np.float32)
            for hp in holes:
                hm = self._fill(shape, deform(self.P(hp), 1, 0.02, rng), x0, y0)
                keep = np.minimum(keep, 1 - hm)
            if hole_soft:
                keep = cv2.GaussianBlur(keep, (0, 0), hole_soft * self.S)
            D *= keep
        self._finish(D, pig, edge, gran, x0, y0)
        return D

    def _bloom(self, D):
        ys, xs = np.nonzero(D > D.max() * 0.4)
        if not len(xs):
            return
        j = int(rng.integers(len(xs)))
        cx, cy = xs[j], ys[j]
        r = min(rng.uniform(40, 90) * self.S, min(D.shape) * 0.3)
        poly = deform(circle(cx, cy, r, 11), 4, 0.45, rng)
        m = self._fill(D.shape, poly, 0, 0)
        m = cv2.GaussianBlur(m, (0, 0), 2.5 * self.S)
        rim = np.clip(m - cv2.GaussianBlur(m, (0, 0), 5 * self.S), 0, None)
        local = D.copy()
        D *= 1 - 0.28 * m
        D += rim * 1.2 * local

    def mask_wash(self, mask, pig, density=1.0, edge=0.9, gran=0.5, soften=2.0, blotch=0.5, x0=0, y0=0):
        """Wash an arbitrary float mask at render scale, placed at (x0, y0)."""
        D = mask.astype(np.float32) * density
        if soften:
            D = cv2.GaussianBlur(D, (0, 0), soften * self.S)
        h, w = D.shape
        if blotch:
            D *= (1 - blotch) + blotch * self.blotch[int(rng.integers(4))][y0:y0 + h, x0:x0 + w] * 1.6
        self._finish(D, pig, edge, gran, x0, y0)
        return D

    def _finish(self, D, pig, edge, gran, x0, y0):
        h, w = D.shape
        if edge:
            # Pigment migrates to the rim of a drying wash: a thin dark line just
            # inside the edge, proportional to how much pigment was there.
            soft = cv2.GaussianBlur(D, (0, 0), 3.5 * self.S)
            rim = np.clip(D - soft, 0, None)
            D += edge * rim * 3.2
        if gran:
            g = self.grain[y0:y0 + h, x0:x0 + w]
            D *= 1 + gran * (0.62 * (0.5 - g) + 0.9 * np.clip(0.42 - g, 0, None) ** 1.5)
        self.layers.append((D, np.asarray(pig, np.float32), x0, y0))

    # -------------------------------------------------------- strokes
    def stroke(self, pts, width, pig, density=1.0, wobble=1.2, taper=True, dry=0.0, edge=0.4, gran=0.6):
        """A brush stroke along a polyline, width in output px."""
        path = resample(self.P(pts), 3.0 * self.S)
        path = wobble_path(path, wobble * self.S, rng)
        n = len(path)
        t = np.linspace(0, 1, n)
        prof = np.ones(n)
        if taper:
            prof = np.clip(np.sin(np.pi * np.clip(t * 1.05, 0, 1)) ** 0.5, 0.15, 1)
        prof *= 1 + 0.15 * smooth_noise(n, rng)
        poly = ribbon(path, width * self.S * prof / 2)
        x0, y0, x1, y1 = self._box(poly, 8 * self.S)
        D = self._fill((y1 - y0, x1 - x0), poly, x0, y0) * density
        D = cv2.GaussianBlur(D, (0, 0), 0.8 * self.S)
        if dry:
            # Dry brush skips the valleys of the paper.
            hh = self.height[y0:y1, x0:x1]
            th = np.clip((hh - (0.62 - dry * 0.35)) * 6, 0, 1)
            D *= 0.35 + 0.65 * th
        self._finish(D, pig, edge, gran, x0, y0)
        return D

    def ink(self, pts, width=1.6, color=INK, density=2.4, wobble=0.6, breaks=0.0, closed=False, taper=True):
        """A fine ink line. width in output px."""
        pts = np.asarray(pts, np.float64)
        if closed:
            pts = np.vstack([pts, pts[:1]])
        path = resample(self.P(pts), 1.5 * self.S)
        if len(path) < 3:
            return
        path = wobble_path(path, wobble * self.S, rng, freq=0.012)
        n = len(path)
        t = np.linspace(0, 1, n)
        prof = 0.75 + 0.35 * smooth_noise(n, rng, k=max(4, n // 60))
        if taper:
            prof *= np.clip(np.minimum(t, 1 - t) * n / 18, 0.35, 1)
        x0, y0, x1, y1 = self._box(path, (width + 4) * self.S)
        shape = (y1 - y0, x1 - x0)
        D = np.zeros(shape, np.float32)
        keep = np.ones(n, bool)
        if breaks:
            i = 0
            while i < n:
                if rng.random() < breaks / 400:
                    keep[i:i + int(rng.integers(4, 12))] = False
                i += 1
        segs = np.split(np.arange(n), np.where(np.diff(keep.astype(int)) != 0)[0] + 1)
        for seg in segs:
            if not keep[seg[0]] or len(seg) < 2:
                continue
            poly = ribbon(path[seg], width * self.S * prof[seg] / 2)
            D = np.maximum(D, self._fill(shape, poly, x0, y0))
        D *= density * (0.85 + 0.3 * (1 - self.height[y0:y1, x0:x1]))
        self.layers.append((D, np.asarray(color, np.float32), x0, y0))

    def dots(self, centers, r, pig, density=1.0, edge=0.8):
        pts = np.asarray(centers, np.float64)
        x0, y0, x1, y1 = self._box(self.P(pts), (r + 10) * self.S)
        shape = (y1 - y0, x1 - x0)
        m = np.zeros(shape, np.float32)
        for (x, y) in centers:
            poly = deform(self.P(circle(x, y, r, 10)), 2, 0.12, rng)
            m = np.maximum(m, self._fill(shape, poly, x0, y0))
        return self.mask_wash(m, pig, density, edge=edge, soften=0.6, blotch=0.3, x0=x0, y0=y0)

    # -------------------------------------------------------- output
    def render(self, deckle=True, margin=0.03, light=0.022, crop=None):
        """crop: (x0, y0, x1, y1) in output px, applied before the sheet's edge is
        torn, so a tighter framing still gets a deckle all the way round."""
        img = np.ones((self.h, self.w, 3), np.float32) * self.paper
        for D, pig, x0, y0 in self.layers:
            h, w = D.shape
            img[y0:y0 + h, x0:x0 + w] *= np.power(np.clip(pig, 1e-3, 1)[None, None, :], np.clip(D, 0, 8)[..., None])
        # Paper tooth lit from the upper left.
        gy, gx = np.gradient(cv2.GaussianBlur(self.height, (0, 0), 0.8 * self.S))
        shade = 1 + light * (-(gx + gy)) * 12
        img *= np.clip(shade, 0.85, 1.1)[..., None]
        img = np.clip(img, 0, 1)
        W, H = self.W, self.H
        if crop:
            x0, y0, x1, y1 = [int(v * self.S) for v in crop]
            img = img[y0:y1, x0:x1]
            W, H = crop[2] - crop[0], crop[3] - crop[1]
        h, w = img.shape[:2]
        alpha = np.ones((h, w), np.float32)
        if deckle:
            alpha = deckle_mask(h, w, margin, self.S)
            edge = cv2.GaussianBlur(alpha, (0, 0), 3 * self.S)
            img *= (0.975 + 0.025 * edge)[..., None]
        out = np.dstack([img, alpha])
        out = cv2.resize(out, (W, H), interpolation=cv2.INTER_AREA)
        return (np.clip(out, 0, 1) * 255).astype(np.uint8)

    def save(self, path, **kw):
        rgba = self.render(**kw)
        cv2.imwrite(path, cv2.cvtColor(rgba, cv2.COLOR_RGBA2BGRA))
        return rgba


# ---------------------------------------------------------------- helpers


def deform(pts, depth, var, r):
    pts = np.asarray(pts, np.float64)
    n = len(pts)
    vv = np.full(n, var) * (0.6 + 0.8 * r.random(n))
    for _ in range(depth):
        n = len(pts)
        nxt = np.roll(pts, -1, axis=0)
        vn = np.roll(vv, -1)
        seg = nxt - pts
        L = np.hypot(seg[:, 0], seg[:, 1])[:, None]
        mid = (pts + nxt) / 2 + r.normal(0, 1, (n, 2)) * L * ((vv + vn) / 2)[:, None] * 0.5
        out = np.empty((2 * n, 2))
        out[0::2] = pts
        out[1::2] = mid
        vout = np.empty(2 * n)
        vout[0::2] = vv
        vout[1::2] = (vv + vn) / 2 * (0.7 + 0.5 * r.random(n))
        pts, vv = out, vout
    return pts


def circle(cx, cy, r, n=24, rx=None, ry=None, a0=0.0):
    rx = rx or r
    ry = ry or r
    t = np.linspace(0, 2 * np.pi, n, endpoint=False) + a0
    return np.stack([cx + rx * np.cos(t), cy + ry * np.sin(t)], 1)


def rect(x, y, w, h):
    return np.array([[x, y], [x + w, y], [x + w, y + h], [x, y + h]], np.float64)


def resample(path, step):
    path = np.asarray(path, np.float64)
    d = np.hypot(*np.diff(path, axis=0).T)
    s = np.concatenate([[0], np.cumsum(d)])
    if s[-1] == 0:
        return path
    n = max(2, int(s[-1] / step))
    u = np.linspace(0, s[-1], n)
    return np.stack([np.interp(u, s, path[:, 0]), np.interp(u, s, path[:, 1])], 1)


def smooth_noise(n, r, k=None):
    k = k or max(3, n // 25)
    g = r.normal(0, 1, k + 2)
    x = np.linspace(0, k + 1, n)
    v = np.interp(x, np.arange(k + 2), g)
    v = cv2.GaussianBlur(v.reshape(1, -1).astype(np.float32), (0, 0), max(1, n / k / 2)).ravel()
    return v / (np.abs(v).max() + 1e-6)


def wobble_path(path, amp, r, freq=0.02):
    n = len(path)
    if n < 3:
        return path
    tang = np.gradient(path, axis=0)
    tang /= np.hypot(tang[:, 0], tang[:, 1])[:, None] + 1e-9
    norm = np.stack([-tang[:, 1], tang[:, 0]], 1)
    return path + norm * (amp * smooth_noise(n, r))[:, None]


def ribbon(path, half):
    tang = np.gradient(path, axis=0)
    tang /= np.hypot(tang[:, 0], tang[:, 1])[:, None] + 1e-9
    norm = np.stack([-tang[:, 1], tang[:, 0]], 1)
    half = np.asarray(half)[:, None] if np.ndim(half) else half
    left = path + norm * half
    right = path - norm * half
    return np.vstack([left, right[::-1]])


def deckle_mask(h, w, margin, S):
    m = int(min(h, w) * margin)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    d = np.minimum.reduce([xx, w - 1 - xx, yy, h - 1 - yy])
    n = fractal_noise(h, w, scales=(60 * S, 20 * S, 6 * S), weights=[0.5, 0.3, 0.2])
    edge = m * (0.35 + 0.9 * n)
    a = np.clip((d - edge) / (1.2 * S) + 0.5, 0, 1)
    return a.astype(np.float32)


def resample_closed(poly, step):
    p = np.vstack([poly, poly[:1]])
    r = resample(p, step)
    return r[:-1]


def smooth_closed(v, k):
    """Low-frequency noise along a closed path: smooth the per-vertex jitter."""
    from scipy.ndimage import gaussian_filter1d
    n = len(v)
    out = gaussian_filter1d(np.asarray(v, np.float64), sigma=max(1.0, n / k / 2), axis=0, mode="wrap")
    return out / (np.abs(out).max() + 1e-6)


# ---------------------------------------------------------------- drawing aids


def sketch(sheet, pts, closed=True, overshoot=3.0, width=1.5, density=2.2, color=INK, wobble=0.5):
    """Ink a polygon edge by edge, overshooting the corners like a quick hand."""
    pts = np.asarray(pts, np.float64)
    n = len(pts)
    m = n if closed else n - 1
    for i in range(m):
        a, b = pts[i], pts[(i + 1) % n]
        d = b - a
        L = np.hypot(*d) + 1e-9
        u = d / L
        o1 = rng.uniform(-0.3, 1.0) * overshoot
        o2 = rng.uniform(-0.3, 1.0) * overshoot
        a2 = a - u * o1
        b2 = b + u * o2
        k = max(2, int(L / 30))
        line = np.linspace(a2, b2, k + 1)
        sheet.ink(line, width=width, density=density, color=color, wobble=wobble)


def scribble(sheet, x, y, w, h, lines=4, width=0.9, density=1.6, color=INK, last=0.6):
    """Suggest handwriting: wavy lines across a box."""
    gap = h / max(1, lines)
    for i in range(lines):
        ww = w * (last if i == lines - 1 else rng.uniform(0.75, 1.0))
        xs = np.linspace(x, x + ww, max(6, int(ww / 3)))
        ys = y + i * gap + gap * 0.5 + np.sin(xs * rng.uniform(0.5, 0.9)) * gap * 0.12 + rng.normal(0, gap * 0.04, len(xs))
        sheet.ink(np.stack([xs, ys], 1), width=width, density=density, color=color, wobble=0.3, taper=True)


def rotate(pts, ang_deg, cx=None, cy=None):
    pts = np.asarray(pts, np.float64)
    if cx is None:
        cx, cy = pts.mean(0)
    a = math.radians(ang_deg)
    R = np.array([[math.cos(a), -math.sin(a)], [math.sin(a), math.cos(a)]])
    return (pts - [cx, cy]) @ R.T + [cx, cy]


def arc(cx, cy, rx, ry, a0, a1, n=40):
    t = np.radians(np.linspace(a0, a1, n))
    return np.stack([cx + rx * np.cos(t), cy + ry * np.sin(t)], 1)


def cursive(sheet, x, y, width, size=7.0, transform=None, ink_width=1.0, density=1.9, color=INK):
    """A line of handwriting: prolate-cycloid loops, broken into words.

    Loops come from x = k t - a sin(t), y = -b cos(t) with a > k, the same curve
    a pen makes running a looped hand along a line."""
    xs_all = []
    cx = x
    while cx < x + width - size * 2:
        letters = int(rng.integers(2, 7))
        span = min(letters * size * 1.25, x + width - cx)
        n = max(8, int(span / 1.2))
        t = np.linspace(0, letters * 2 * np.pi, n)
        k = span / (letters * 2 * np.pi)
        a = k * rng.uniform(1.15, 1.6)
        amp = size * rng.uniform(0.38, 0.55) * (1 + 0.35 * np.sin(t * 0.37 + rng.uniform(0, 6)))
        px = cx + k * t - a * np.sin(t) + a * np.sin(t[0])
        py = y - amp * np.cos(t) * 0.75 + amp * 0.2
        # an ascender now and then
        for _ in range(int(rng.integers(0, 2))):
            j = int(rng.integers(0, n))
            py[max(0, j - 3):j + 3] -= size * 0.6 * np.hanning(len(py[max(0, j - 3):j + 3]))
        pts = np.stack([px, py], 1)
        if transform is not None:
            pts = transform(pts)
        sheet.ink(pts, width=ink_width, density=density, color=color, wobble=0.15, taper=True)
        cx += span + size * rng.uniform(0.8, 1.4)
