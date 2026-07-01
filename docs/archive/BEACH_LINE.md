# Beach Line (archived)

> **Status:** Deferred. Removed from the current mockups and the active
> `ISLE_SPARKS_SPEC.md` on **July 1, 2026**, pending future reconsideration.
> This file preserves the full implementation so it can be restored.

## What it was

A thin, **broad, smooth, flowing** stroke **circumscribing a streaked spark**
(the isle's "beach"). It appeared at **streak ≥ 2**, alongside the streak number
badge. Warm-sand tone (`#F59E0B`), low opacity (~0.6), round caps/joins. It did
**not** grow as the streak number grew — only the number grew.

The shape was a closed Catmull-Rom spline through points sampled around the
spark's center on a single closed loop. The radial excursion was built from
**one low-frequency sine + a small integer harmonic** (F-fold symmetry) so every
lobe was a **similar, smooth curve** and the line never hit a hard edge.

## Algorithm summary

- **Element-aware:** reads the parent spark's rendered size (`sz`) and sizes
  the SVG to a broad band so the line never overlaps the spark or clips.
- Inner radius `innerR = sz/2 + 4` (clears the spark edge).
- Outer radius `canvasR = sz/2 * 1.8 + 4` (broad band).
- SVG dimension `dim = ceil(canvasR * 2)`, centered on the spark.
- Per-element seed (idx-based) so each spark's beach is slightly rotated/unique.
- `N = 200` samples around `[0, 2π]`.
- Radial excursion (no clamping, pure sines → no hard edges):
  ```
  exc = sin(t*F + ph[0]) * 0.72 + sin(t*F*2 + ph[1]) * 0.10     // F = 4
  ```
  Max `|exc| ≈ 0.82` → stays comfortably inside the band, **never saturated**.
- Points: `rr = base + half*exc`, `base = (innerR+canvasR)/2`,
  `half = (canvasR-innerR)/2`.
- Closed Catmull-Rom spline through the points → `M…C…Z`.
- Stroke: `stroke #F59E0B`,
  `stroke-width = max(1.5, sz/42)`, `stroke-opacity 0.6`, round caps/joins.

## Iteration history (for context)

- **v1 (original):** single sine, 14 tight waves, tiny amplitude → read like
  gear teeth ("too squiggly").
- **v2:** five layered sines (freqs 2 / 3.7 / 7.3 / 13 / 23) + random phase +
  clamping → coastline-like, but with hard edges from saturation and
  dissimilar lobes.
- **v3 (archived):** two low sines (2.0 + 3.2) + clamping → flowing, but clamp
  still produced rare hard edges and lobes were not similar.
- **v4 (archived):** one low freq (F=4) + small integer harmonic (2F), no
  clamp → smooth, similar curves, no hard edges. **This is the version
  preserved below.**

## CSS

```css
/* ---- BEACH LINE (squiggly circumscription via SVG) ---- */
.beach-svg {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
  z-index: 0;
}
```

## HTML usage (inside a streaked spark div)

```html
<div class="spark size-lg lit" style="position:relative;">
  <svg class="beach-svg" width="118" height="118" viewBox="0 0 118 118"></svg>
  <span class="streak-badge">12</span>
  ...
</div>
```

The `width` / `height` / `viewBox` are **overwritten by the JS** to fit the
broad band, so any placeholder values are fine.

## JS (generator) — full code

```html
<script>
  // Broad, smooth, flowing "beach" line around each spark — no hard edges.
  // One low frequency + a small integer harmonic + seeded phase => a few broad lobes
  // with SIMILAR curves (F-fold symmetry), smooth end-to-end (no clamping). Confined
  // to a band [innerR, canvasR] so it hugs the spark broadly without touching/clipping.
  function _beachRng(seed){ let s=seed>>>0||1; return ()=>{ s=(s*1664525+1013904223)>>>0; return s/4294967296; }; }
  function _beachSpline(pts){
    const n=pts.length; let d=`M${pts[0][0].toFixed(2)} ${pts[0][1].toFixed(2)} `;
    for(let i=0;i<n;i++){
      const p0=pts[(i-1+n)%n], p1=pts[i], p2=pts[(i+1)%n], p3=pts[(i+2)%n];
      const c1x=p1[0]+(p2[0]-p0[0])/6, c1y=p1[1]+(p2[1]-p0[1])/6;
      const c2x=p2[0]-(p3[0]-p1[0])/6, c2y=p2[1]-(p3[1]-p1[1])/6;
      d+=`C${c1x.toFixed(2)} ${c1y.toFixed(2)} ${c2x.toFixed(2)} ${c2y.toFixed(2)} ${p2[0].toFixed(2)} ${p2[1].toFixed(2)} `;
    }
    return d+'Z';
  }
  function beachPath(cx, cy, innerR, canvasR, seed){
    const r=_beachRng(seed);
    const ph=[0,1].map(()=>r()*Math.PI*2);
    const base=(innerR+canvasR)/2, half=(canvasR-innerR)/2;
    const N=200, pts=[];
    const F=4;                            // few broad lobes -> flowing & abstract
    for(let i=0;i<N;i++){
      const t=i/N*Math.PI*2;
      // single low freq + small integer harmonic => smooth, similar curves; no clamping => no hard edges
      let exc = Math.sin(t*F   +ph[0])*0.72
              + Math.sin(t*F*2 +ph[1])*0.10;
      const rr=base+half*exc;
      pts.push([cx+rr*Math.cos(t), cy+rr*Math.sin(t)]);
    }
    return _beachSpline(pts);
  }
  document.querySelectorAll('.beach-svg').forEach((svg, idx) => {
    const spark=svg.parentElement;
    const sz=spark.getBoundingClientRect().width||96;
    const innerR=sz/2+4;                 // clear the spark edge
    const canvasR=sz/2*1.8+4;            // broad band
    const dim=Math.ceil(canvasR*2);
    svg.setAttribute('width',dim); svg.setAttribute('height',dim);
    svg.setAttribute('viewBox',`0 0 ${dim} ${dim}`);
    const path=document.createElementNS('http://www.w3.org/2000/svg','path');
    path.setAttribute('d', beachPath(canvasR, canvasR, innerR, canvasR, idx*2654435761+12345));
    path.setAttribute('fill','none'); path.setAttribute('stroke','#F59E0B');
    path.setAttribute('stroke-width', Math.max(1.5, sz/42).toFixed(2));
    path.setAttribute('stroke-opacity','0.6');
    path.setAttribute('stroke-linejoin','round'); path.setAttribute('stroke-linecap','round');
    svg.appendChild(path);
  });
</script>
```

`shape-lab.html` used the same generator with a slightly more compact style —
same algorithm and parameters.

## Where it was used (removed July 1, 2026)

- `docs/design/mockups/sparks.html` — on the **Streaked** state spark, the two
  **Streak Detail** examples (streak 3, streak 47), and one floating spark in
  the Home composition.
- `docs/design/mockups/shape-lab.html` — on the **streaked example**.
- `docs/design/ISLE_SPARKS_SPEC.md` — §1 motivation, §3 states table
  (Streaked row), §3 "Streak badge & beach line" subsection, §9 UI components
  (Beach line row), §11 mockups reference.

## Flutter note (for build)

The spec listed it as `(SVG/CustomPainter)`. The natural Flutter rendering is
a `CustomPainter` (or `CustomPaint` with a `Path`) drawing the same closed
spline — the same `(innerR, canvasR, F, amplitudes, N, ph, seed)` parameters
translate directly.

## How to restore

1. **Re-add the CSS** rule for `.beach-svg` in each mockup's `<style>` block.
2. **Re-add `<svg class="beach-svg" ...></svg>`** as the first child inside
   every streaked spark `<div>` that should show a beach.
3. **Paste the JS** (above) into the bottom of each mockup's `<script>` block.
4. **Restore the spec** entries: the "broad, smooth, flowing 'beach' line"
   clause in the §3 Streaked state row, a "Streak badge & beach line"
   subsection (with the Beach line bullet), the Beach line UI component row
   in §9, the "+ beach-line stroke" item in the §9 visual-tokens list, and
   the §1 + §11 references.
5. For Flutter: implement a `BeachLinePainter extends CustomPainter` with the
   same parameters and wire it into the `IsleSpark` widget's streaked state.
