---
theme: default
title: SWIFT Zoom Workshop
info: Hands-on zoom simulations with MUSIC-2 and SWIFT
colorSchema: light
drawings:
  persist: false
transition: slide-left
mdc: true
---

# SWIFT Zoom Workshop

## MUSIC-2 → SWIFT

<div class="legend mt-12">
  <span class="chip hr">high-res / zoom</span>
  <span class="chip bkg">background</span>
  <span class="chip bad">bad geometry</span>
  <span class="chip good">good geometry</span>
</div>

<!--
These four colours are used consistently through the deck.
-->

---

# What is a zoom simulation?

<div class="grid grid-cols-[1.3fr_1fr] gap-8 items-center">
<div class="big">

- <span class="hr-t">High resolution</span> in a chosen Lagrangian region
- <span class="bkg-t">Coarser and coarser</span> particles outside it
- Full box still supplies the tides

<div class="callout mt-8">Particles go where the science is</div>

</div>
<div class="nest">
  <div class="ring r1"><div class="ring r2"><div class="ring r3"><div class="core">zoom</div></div></div></div>
</div>
</div>

<!--
Trade-off: one volume now spans a huge range of particle masses and densities, which the code has to handle efficiently.
-->

---

# Target: TESSERA `P00000/R0000`

<div class="grid grid-cols-3 gap-6 mt-12">
  <div class="stat"><div class="num">δ = −0.08</div><div class="lbl">underdense</div></div>
  <div class="stat"><div class="num">57.5 Mpc</div><div class="lbl">effective radius</div></div>
  <div class="stat"><div class="num">35,608</div><div class="lbl">region points</div></div>
</div>

<div class="big mt-14">

MUSIC-2 fits an <span class="hr-t">ellipsoid</span> to the region points

</div>

<!--
Exact density contrast from notebook 1: delta = -0.0815. Selected from parent volume P00000.
-->

---
layout: section
---

# 1. Initial conditions

## Generate the zoom with MUSIC-2

---

# MUSIC-2: box and levels

```ini {all|2-3|4-6|7-8}
[setup]
boxlength   = 1600.0   # Mpc/h
zstart      = 63
levelmin    = 6        # whole box: 64³
levelmin_TF = 8        # transfer-function level
levelmax    = 10       # inside region: 1024³
baryons     = no
use_2LPT    = yes
```

<!--
1600 Mpc/h = 2388.8 Mpc. zstart = 63 matches a_begin = 1/64 in the SWIFT config.
levelmin_TF: level at which the transfer-function convolution is done; must be >= levelmin.
use_2LPT: second-order Lagrangian displacements.
-->

---

# MUSIC-2: region and output

```ini {1-3|5-6|8-10}
[setup]
region            = ellipsoid
region_point_file = tessera_P00000_R0000_region_points.txt

[execution]
NumThreads = 8

[output]
format   = swift
filename = zoom_ics.hdf5
```

<!--
region / region_point_file: the shape and the Lagrangian points it must enclose.
NumThreads: MUSIC-2 threads.
format = swift: writes SWIFT-ready HDF5 directly.
-->

---

# Resolution hierarchy

<div class="grid grid-cols-[1.2fr_1fr] gap-10 items-center">
<div>

| Level | Grid | Mass [M<sub>☉</sub>] |
|---:|---:|---:|
| <span class="bkg-t">6</span> | 64³ | 2.4 × 10¹⁵ |
| 7 | 128³ | 3.1 × 10¹⁴ |
| 8 | 256³ | 3.8 × 10¹³ |
| 9 | 512³ | 4.8 × 10¹² |
| <span class="hr-t">10</span> | 1024³ | 6.0 × 10¹¹ |

</div>
<div class="big">

Each level: mass **÷ 8**

<div class="callout bad-b mt-8">
Level 10 is a <b>workshop</b> cut.<br/>Production: level 13
</div>

</div>
</div>

<!--
Masses from zoom_ics.hdf5 (59.6 to 2.44e5 x 1e10 Msun). Levels 7-9 are the buffer shells.
Level 13 would be 1.16e9 Msun and 512x more particles in the region.
levelmin_TF = 8 is the convolution level, not a separate particle species.
-->

---

# What MUSIC-2 made

<img src="/assets/generated/zoom_ics_projection.png" class="plot mx-auto" style="height: 400px" />

<!--
x-y projection of data/zoom_ics.hdf5. Rings of intermediate-mass particles surround the high-res ellipsoid.
-->

---

# From MUSIC-2 to SWIFT

<div class="grid grid-cols-2 gap-8 mt-10">
  <div class="card hr-b">
    <h2><code>PartType1</code></h2>
    <p class="big">High-res DM</p>
    <p class="big muted">67,160 · one mass</p>
  </div>
  <div class="card bkg-b">
    <h2><code>PartType2</code></h2>
    <p class="big">Background DM</p>
    <p class="big muted">364,384 · many masses</p>
  </div>
</div>

<div class="callout mt-10">MUSIC-2 set the <b>particles</b>. SWIFT sets the <b>cells</b>.</div>

<!--
SWIFT measures the extent of the PartType1 distribution and builds the zoom region around it.
-->

---
layout: section
---

# 2. Run the zoom

## Choose the SWIFT geometry

---

# The `ZoomRegion` block

```yaml {all|2-4|5-7|8-9}
ZoomRegion:
  region_pad_factor:          1.1
  zoom_top_level_depth:       2
  zoom_min_top_level_cells:   -1
  bkg_top_level_cells:        -1
  buffer_cell_depth:          0
  neighbour_max_tree_depth:   2
  bkg_subdepth_diff_grav:     3
  max_com_dx:                 0.1
```

<p class="caption">From <code>examples/parameter_example.yml</code> · documented comments on the next slides</p>

---

# Sizing the zoom region

```yaml
# How much larger the zoom region will be than the high
# res particle distribution in the ICs?
region_pad_factor:          1.1
# The depth of the zoom top level cells in a single
# background cell.
zoom_top_level_depth:       2
# (Optional) Minimum target zoom cdim. If positive, this
# overrides zoom_top_level_depth and the required depth
# is derived.
zoom_min_top_level_cells:   -1
```

<div class="callout bad-b">Positive <code>zoom_min_top_level_cells</code> <b>overrides</b> <code>zoom_top_level_depth</code></div>

<!--
Workshop: zoom_min_top_level_cells = 8 cannot be matched exactly. output.log: "Using zoom_top_level_depth=2, giving Zoom cdim=12."
Comments are the canonical parameter_example.yml text, moved above each key and wrapped.
-->

---

# Background and neighbours

```yaml
# How many cells should the background be resolved with?
# (This is treated as gospel, but if it is set to -1 we
# will try and find the optimal value to minimise the
# padding around the zoom region)
bkg_top_level_cells:        -1
# (Optional, only used when buffer cells are needed) The
# depth of the top level buffer cells in a single
# background cell. (default: 0)
buffer_cell_depth:          0
# (Optional) The depth of the cell trees neighbouring the
# zoom region (default: -1)
neighbour_max_tree_depth:   2
```

---

# Gravity tasks and rebuilds

```yaml
# The minimum difference between the leaf depth and the
# task depth for background cells.
bkg_subdepth_diff_grav:     3
# (Optional) The maximum allowed displacement of the
# centre of mass of the zoom region from the centre of the
# box in units of the zoom region extent. When this is
# exceeded, we rebuild the zoom region.
max_com_dx:                 0.1
```

<div class="callout">Geometry → cells → tasks → runtime</div>

<!--
Padding, per-cell occupancy, task count and runtime all follow from these choices.
-->

---

# Look first: `--dump-zoom-geometry`

<div class="flow mt-12">
  <div>load particles</div><span>→</span>
  <div>build cells</div><span>→</span>
  <div>write diagnostics</div><span>→</span>
  <div class="stop">exit</div>
</div>

<div class="big mt-12">

No timestep taken — **cheap to iterate**

</div>

```bash
swift --cosmology --self-gravity --dump-zoom-geometry params.yml
```

<!--
Writes zoom_metadata.yml and zoom_cell_data.dat; tools/zooms/plot_zoom_geometry.py makes the plots.
-->

---

# <span class="bad-t">Bad:</span> 8 background cells

<div class="grid grid-cols-[1fr_1fr] gap-8 items-center">
<div>
  <img src="/assets/geometry_bkg8/cell_types.png" class="plot" style="height: 380px" />
  <div class="keys"><span class="k-bkg">background</span><span class="k-nb">neighbour</span><span class="k-zoom">zoom</span></div>
</div>
<div class="facts">
  <div><b>299 Mpc</b> background cells</div>
  <div><b>597 Mpc</b> zoom region</div>
  <div><b>~124 Mpc</b> high-res extent</div>
</div>
</div>

<!--
The zoom region must be a whole number of background cells: here 2 x 2 x 2, far larger than the particles it covers. 8³ zoom cells, each ~75 Mpc.
-->

---

# <span class="good-t">Good:</span> 33 background cells

<div class="grid grid-cols-[1fr_1fr] gap-8 items-center">
<div>
  <img src="/assets/geometry_bkg33_mesh256/cell_types.png" class="plot" style="height: 380px" />
  <div class="keys"><span class="k-bkg">background</span><span class="k-nb">neighbour</span><span class="k-zoom">zoom</span></div>
</div>
<div class="facts">
  <div><b>72.4 Mpc</b> background cells</div>
  <div><b>217 Mpc</b> zoom region</div>
  <div><b>12³</b> zoom cells, 18.1 Mpc</div>
  <div><b>256³</b> PM mesh</div>
</div>
</div>

<!--
Values from runs/zoom/zoom_metadata.yml.
-->

---

# Padding: where the zoom width goes

<img src="/assets/generated/zoom_width_budget.png" class="plot mx-auto" style="height: 360px" />

<div class="grid grid-cols-2 text-center big">
  <div class="bad-t"><b>4.8×</b> particle extent</div>
  <div class="good-t"><b>1.75×</b> particle extent</div>
</div>

<!--
Built from the particle extent (identical ICs), the 1.1 pad factor, and the final zoom width (bkg8: 2 background cells; bkg33: zoom_metadata.yml).
Grey is pure cell-alignment padding: 77% of each axis for bkg8, 37% for bkg33.
-->

---

# Occupancy: high-res particles per zoom cell

<div class="grid grid-cols-2 gap-6">
<div class="panel bad-b">
  <h3 class="bad-t">bkg 8</h3>
  <img src="/assets/geometry_bkg8/occupancy_dm.png" class="plot" style="height: 280px" />
  <p class="big">~12 cells, up to <b>10⁴</b></p>
</div>
<div class="panel good-b">
  <h3 class="good-t">bkg 33</h3>
  <img src="/assets/geometry_bkg33_mesh256/occupancy_dm.png" class="plot" style="height: 280px" />
  <p class="big">many cells, ≲ <b>500</b></p>
</div>
</div>

<!--
x axis: particles per cell (log). Bad: most zoom cells hold no high-res particles; a handful hold everything. Good: the work is spread across many cells.
-->

---

# Bad vs good

<div class="grid grid-cols-2 gap-6">
<div class="panel bad-b">
  <h3 class="bad-t">bkg 8</h3>
  <img src="/assets/geometry_bkg8/cell_types.png" class="plot" style="height: 350px" />
</div>
<div class="panel good-b">
  <h3 class="good-t">bkg 33 · mesh 256</h3>
  <img src="/assets/geometry_bkg33_mesh256/cell_types.png" class="plot" style="height: 350px" />
</div>
</div>

---

# More cells are not free

<div class="grid grid-cols-2 gap-8 mt-8">
  <div class="stat bad-b card"><div class="num bad-t">1,024</div><div class="lbl">top-level cells · bkg 8</div></div>
  <div class="stat good-b card"><div class="num good-t">37,665</div><div class="lbl">top-level cells · bkg 33</div></div>
</div>

<div class="big mt-10 text-center">

**1.34 M** tasks per rebuild (bkg 33)

</div>

<div class="callout mt-8">Balance: spread the high-res work, without drowning in overhead</div>

<!--
bkg8: 8³ zoom + 8³ background. bkg33: 12³ + 33³ (zoom_metadata.yml).
Task total from engine_print_task_counts in output.log (Total = 1339867). Every cell adds bookkeeping, pair interactions and rebuild cost.
-->

---

# Running SWIFT

```bash
swift --cosmology --self-gravity --zoom \
      --threads=16 -v 1 \
      --param=ZoomRegion:bkg_top_level_cells:33 \
      params.yml
```

<div class="grid grid-cols-2 gap-x-8 gap-y-3 mt-8 big">
  <div><code>--zoom</code> zoom geometry</div>
  <div><code>--threads</code> one process, thread pool</div>
  <div><code>-v 1</code> verbose log</div>
  <div><code>--param</code> override geometry</div>
</div>

<!--
The workshop scripts wrap this, also overriding ZoomRegion:zoom_min_top_level_cells:8 and Gravity:mesh_side_length:256.
-v 1 logs geometry, task counts and timings. output.log reports "Using 16 threads in the thread-pool" for the COSMA8 run.
-->

---

# Reading performance

<img src="/assets/generated/runtime_bkg33_mesh256.png" class="plot mx-auto" style="height: 330px" />

<div class="callout mt-4">Name logs per config — <code>output_bkg33_mesh256.log</code> — then overlay</div>

<!--
x: simulation time reached. y: cumulative sum of the per-step "Wall-clock time [ms]" column. Steeper = more expensive.
This run: 101 steps, a = 0.0156 -> 0.0261, ~458 s total.
-->

---

# Summary

<div class="grid grid-cols-2 gap-6 mt-8">
  <div class="card hr-b"><h2>MUSIC-2</h2><p class="big">sets particle resolution</p></div>
  <div class="card bkg-b"><h2><code>ZoomRegion</code></h2><p class="big">sets SWIFT cells</p></div>
  <div class="card good-b"><h2>Inspect</h2><p class="big">geometry before running</p></div>
  <div class="card bad-b"><h2>Measure</h2><p class="big">compare logs, don't guess</p></div>
</div>
