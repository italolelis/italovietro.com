// The episode page's interactive parts: the timeline, and the figures a chapter
// can declare in front matter (partials/episode/ask.html, figure.html). Loaded
// only by layouts/episodes/single.html.
//
// Every one of them renders a complete, static version without this file -- the
// timeline as a ruler, a question already answered, a model at its starting
// point, a flow with both branches showing. What the script adds is the asking:
// controls stay `hidden` in the HTML and are only shown here, so a visitor
// without JavaScript never meets a button that does nothing.

const fmt = (template, value) => template.replace('%s', value);
const lang = document.documentElement.lang || 'en';
const decimal = (n, digits) => n.toLocaleString(lang, { minimumFractionDigits: digits, maximumFractionDigits: digits });
const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// --- Timeline: where the reader is in the recording ----------------------------
//
// The reading line sits a little above the middle of the window. The chapter
// whose heading has crossed it is the current one, and the playhead moves
// through that chapter's stretch of the recording in proportion to how much of
// its text has crossed -- an estimate, so it is only ever drawn. The clock
// prints something real: the start of the chapter, or the last quote passed.
const clockText = (t) => {
    const s = Math.max(0, Math.round(t));
    return `${String(Math.floor(s / 60)).padStart(2, '0')}:${String(s % 60).padStart(2, '0')}`;
};

function initTimeline() {
    const tl = document.querySelector('[data-timeline]');
    const headings = [...document.querySelectorAll('.ep-chapter[data-chapter]')];
    if (!tl || !headings.length) return;

    const duration = parseFloat(tl.dataset.duration);
    const ruler = tl.querySelector('[data-ruler]');
    const head = tl.querySelector('[data-head]');
    const clock = tl.querySelector('[data-clock]');
    const name = tl.querySelector('[data-chapter-name]');
    const tip = document.querySelector('[data-tip]');
    const segs = [...tl.querySelectorAll('.ep-timeline__seg')];
    const dots = [...tl.querySelectorAll('.ep-timeline__moment')];
    const legend = [...document.querySelectorAll('.ep-map [data-chapter]')];
    // Everything on the page that is a moment in the recording, in page order.
    const marks = [...document.querySelectorAll('.ep-chapter[data-t], .ep-moment[data-t]')];
    const end = document.querySelector('.ep-colophon');

    let current = undefined;
    const setCurrent = (id) => {
        if (id === current) return;
        current = id;
        segs.forEach((s) => s.classList.toggle('is-current', s.dataset.chapter === id));
        legend.forEach((a) => {
            const on = a.dataset.chapter === id;
            a.classList.toggle('is-current', on);
            if (on) a.setAttribute('aria-current', 'location');
            else a.removeAttribute('aria-current');
        });
        const seg = segs.find((s) => s.dataset.chapter === id);
        name.textContent = seg ? seg.dataset.name : tl.dataset.intro;
    };

    const update = () => {
        const line = window.innerHeight * 0.4;
        let i = -1;
        headings.forEach((h, k) => { if (h.getBoundingClientRect().top < line) i = k; });
        if (i < 0) {
            setCurrent(null);
            clock.textContent = '00:00';
            head.style.left = '0%';
            return;
        }
        const h = headings[i];
        const t0 = parseFloat(h.dataset.t);
        const next = headings[i + 1];
        const t1 = next ? parseFloat(next.dataset.t) : duration;
        const from = h.getBoundingClientRect().top;
        const stop = next || end;
        const to = stop ? stop.getBoundingClientRect().top : from + 1;
        const f = Math.min(1, Math.max(0, (line - from) / Math.max(1, to - from)));
        let shown = t0;
        marks.forEach((m) => { if (m.getBoundingClientRect().top < line) shown = parseFloat(m.dataset.t); });
        const t = Math.max(shown, t0 + f * (t1 - t0));
        setCurrent(h.dataset.chapter);
        clock.textContent = clockText(shown);
        head.style.left = `${(t / duration) * 100}%`;
    };

    // Hover: the nearest quote within reach of the cursor, previewed under the
    // ruler. Click: that quote if one is lit, otherwise the last chapter or quote
    // at or before the point clicked.
    let hot = null;
    const nearest = (x) => {
        let best = null;
        let dist = 10;
        dots.forEach((d) => {
            const r = d.getBoundingClientRect();
            const dx = Math.abs(r.left + r.width / 2 - x);
            if (dx <= dist) { dist = dx; best = d; }
        });
        return best;
    };
    const showTip = (dot) => {
        if (dot === hot) return;
        if (hot) hot.classList.remove('is-hot');
        hot = dot;
        if (!dot) { tip.hidden = true; return; }
        dot.classList.add('is-hot');
        tip.querySelector('.ep-timeline__tip-clock').textContent = clockText(parseFloat(dot.dataset.t));
        tip.querySelector('.ep-timeline__tip-text').textContent = `“${dot.dataset.text}”`;
        tip.hidden = false;
        // Under the dot, kept inside the bar's column, against the window.
        const inner = tl.querySelector('.ep-timeline__inner').getBoundingClientRect();
        const r = dot.getBoundingClientRect();
        const w = tip.offsetWidth;
        const left = Math.min(Math.max(inner.left, r.left - w / 2), inner.right - w);
        tip.style.left = `${left}px`;
        tip.style.top = `${tl.getBoundingClientRect().bottom + 6}px`;
    };
    if (tip && window.matchMedia('(hover: hover)').matches) {
        ruler.addEventListener('mousemove', (e) => showTip(nearest(e.clientX)));
        ruler.addEventListener('mouseleave', () => showTip(null));
    }

    ruler.addEventListener('click', (e) => {
        let dest = null;
        if (hot) {
            dest = document.getElementById(`m-${hot.dataset.t}`);
        } else {
            const r = ruler.getBoundingClientRect();
            const target = ((e.clientX - r.left) / r.width) * duration;
            marks.forEach((m) => { if (parseFloat(m.dataset.t) <= target) dest = m; });
        }
        (dest || headings[0]).scrollIntoView({ behavior: reduced ? 'auto' : 'smooth', block: 'start' });
    });

    let queued = false;
    window.addEventListener('scroll', () => {
        if (queued) return;
        queued = true;
        requestAnimationFrame(() => { queued = false; update(); });
    }, { passive: true });
    window.addEventListener('resize', update);
    update();
}

// --- A guess: commit to a number, then see the real one -----------------------------
//
// The slider runs on the figure's own scale, logarithmic by default: linear would
// crowd the modest guesses into the first sliver of the track.
function initGuess(fig) {
    const controls = fig.querySelector('.ep-ask__controls');
    const range = controls.querySelector('input[type=range]');
    const out = controls.querySelector('output');
    const reveal = controls.querySelector('[data-reveal]');
    const answer = fig.querySelector('[data-answer]');
    const you = fig.querySelector('.ep-guess__row--you');
    const youBar = fig.querySelector('[data-you-bar]');
    const youVal = fig.querySelector('[data-you-val]');
    const realBar = fig.querySelector('.ep-guess__row--real .ep-guess__bar > span');
    const log = fig.dataset.scale !== 'linear';
    const min = parseFloat(fig.dataset.min);
    const max = parseFloat(fig.dataset.max);

    const toValue = (p) => (log ? Math.exp(Math.log(min) + p * (Math.log(max) - Math.log(min))) : min + p * (max - min));
    const toPos = (v) => (log ? (Math.log(v) - Math.log(min)) / (Math.log(max) - Math.log(min)) : (v - min) / (max - min));
    // Small ranges read to a decimal under 3 and whole numbers above; large ones
    // to two significant figures, because nobody guesses "287".
    const label = (v) => {
        if (fig.dataset.zero && v < min * 1.05) return fig.dataset.zero;
        let n;
        if (max <= 20) n = v < 3 ? decimal(v, 1) : decimal(Math.round(v), 0);
        else {
            const p = 10 ** Math.max(0, Math.floor(Math.log10(v)) - 1);
            n = decimal(Math.round(v / p) * p, 0);
        }
        return fmt(fig.dataset.unit, n);
    };
    const value = () => toValue(range.value / 1000);
    const sync = () => {
        const text = label(value());
        out.value = text;
        out.textContent = text;
        range.setAttribute('aria-valuetext', text);
    };

    range.value = Math.round(toPos(parseFloat(fig.dataset.start)) * 1000);
    const realWidth = realBar.style.width;
    realBar.style.width = '0%';
    controls.hidden = false;
    answer.hidden = true;
    sync();
    range.addEventListener('input', sync);
    reveal.addEventListener('click', () => {
        const v = value();
        youVal.textContent = label(v);
        you.hidden = false;
        answer.hidden = false;
        range.disabled = true;
        reveal.hidden = true;
        fig.classList.add('is-revealed');
        // Next frame, so both bars grow from zero rather than appearing at width.
        requestAnimationFrame(() => requestAnimationFrame(() => {
            youBar.style.width = `${Math.max(1.5, toPos(v) * 100)}%`;
            realBar.style.width = realWidth;
        }));
        const verdict = answer.querySelector('.ep-ask__verdict');
        verdict.setAttribute('tabindex', '-1');
        verdict.focus({ preventScroll: true });
    });
}

// --- A choice: pick one, then see the right one -------------------------------------
function initChoice(fig) {
    const options = [...fig.querySelectorAll('.ep-choice__option')];
    const answer = fig.querySelector('[data-answer]');
    const right = parseInt(fig.dataset.answerIndex, 10);
    options.forEach((o) => { o.classList.remove('is-correct'); o.disabled = false; });
    answer.hidden = true;
    options.forEach((o) => {
        o.addEventListener('click', () => {
            const picked = parseInt(o.dataset.index, 10);
            options.forEach((x) => { x.disabled = true; });
            options[right].classList.add('is-correct');
            if (picked !== right) o.classList.add('is-wrong');
            o.setAttribute('aria-pressed', 'true');
            fig.classList.add('is-answered');
            answer.hidden = false;
            const verdict = answer.querySelector('.ep-ask__verdict');
            verdict.setAttribute('tabindex', '-1');
            verdict.focus({ preventScroll: true });
        });
    });
}

// --- A toy model: switch stages on, watch the total ----------------------------------
function initModel(fig) {
    const after = fig.querySelector('[data-after]');
    const stack = after.querySelector('.ep-model__stack');
    const segs = [...after.querySelectorAll('[data-stage]')];
    const toggles = fig.querySelector('.ep-model__toggles');
    const readout = fig.querySelector('[data-readout]');
    const totalOut = fig.querySelector('[data-after-total]');
    const before = parseFloat(fig.dataset.total);
    const unit = fig.dataset.unit;
    const on = new Set();

    const render = () => {
        let total = 0;
        let longest = null;
        segs.forEach((s) => {
            const days = parseFloat(s.dataset.days) / (on.has(s.dataset.stage) ? parseFloat(s.dataset.cut) : 1);
            s.style.flexGrow = days;
            // Too narrow to hold its label: keep the colour, drop the word.
            s.classList.toggle('is-narrow', days / before < 0.09);
            total += days;
            if (!longest || days > longest.days) longest = { days, name: s.dataset.name };
        });
        stack.style.width = `${(total / before) * 100}%`;
        const speedup = before / total;
        const faster = speedup < 1.05 ? fig.dataset.lSame : fmt(fig.dataset.lFaster, decimal(speedup, 1));
        totalOut.textContent = fmt(unit, decimal(total, 1));
        readout.textContent = `${fmt(unit, decimal(total, 1))}, ${faster}. ${fmt(fig.dataset.lLongest, longest.name.toLowerCase())}`;
    };

    after.hidden = false;
    toggles.hidden = false;
    toggles.querySelectorAll('[data-toggle]').forEach((b) => {
        b.addEventListener('click', () => {
            const key = b.dataset.toggle;
            const pressed = b.getAttribute('aria-pressed') !== 'true';
            b.setAttribute('aria-pressed', String(pressed));
            if (pressed) on.add(key);
            else on.delete(key);
            render();
        });
    });
    render();
}

// --- A flow: pick a path, watch it light up -------------------------------------------
function initFlow(fig) {
    const controls = fig.querySelector('.ep-flow__controls');
    if (!controls) return;
    const buttons = [...controls.querySelectorAll('[data-path]')];
    const branches = [...fig.querySelectorAll('.ep-flow__branch')];
    controls.hidden = false;
    buttons.forEach((b) => {
        b.addEventListener('click', () => {
            const path = b.getAttribute('aria-pressed') === 'true' ? 'none' : b.dataset.path;
            buttons.forEach((x) => x.setAttribute('aria-pressed', String(x.dataset.path === path)));
            branches.forEach((x) => x.classList.toggle('is-taken', x.dataset.branch === path));
            // Restart the walk-through from the top on every choice.
            fig.dataset.path = 'none';
            void fig.offsetWidth;
            fig.dataset.path = path;
        });
    });
}

function init() {
    initTimeline();
    document.querySelectorAll('[data-ask="guess"]').forEach(initGuess);
    document.querySelectorAll('[data-ask="choice"]').forEach(initChoice);
    document.querySelectorAll('[data-model]').forEach(initModel);
    document.querySelectorAll('[data-flow]').forEach(initFlow);
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
