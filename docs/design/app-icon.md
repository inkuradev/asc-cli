# App Icon Design — asc

## Concept

The icon visualizes the **Command Center footprint as an abstract glowing ring**
— the same visual formula as AppHive but in Terran geometry and color. The
Command Center's top-down silhouette is an **octagon** (chamfered square, like
the building pad); rendered as a thick hollow ring with industrial steel texture
and cold blue-cyan plasma energy pulsing along its inner edge. An orange reactor
glow bleeds from the open center. The background carries a barely-visible
**Terran base tile grid** — square cells, darker than the field. No device
frame, no literal building, no lettermark.

**Color palette:**

| Role            | Color            | Hex       |
|-----------------|------------------|-----------|
| Background      | Deep navy        | `#0D1520` |
| Grid pattern    | Darker navy      | `#111E2E` |
| Ring material   | Gunmetal steel   | `#2A3F52` |
| Primary glow    | Cold cyan-blue   | `#4FC3F7` |
| Center bloom    | Reactor orange   | `#E87C2A` |
| Ring highlight  | Steel white      | `#C8D8E8` |

---

## AI Generation Prompt

### Primary prompt

```
macOS app icon for "asc", a command-line developer tool for App Store Connect.
Inspired by the Terran Command Center from StarCraft. Abstract icon: a thick
octagonal ring (chamfered square with clipped corners, like the Command Center
building pad seen directly from above), centered in the frame. The ring is
rendered as solid industrial steel — brushed metal surface with subtle panel
lines and bevel edges, giving it mass and weight. Along the inner edge of the
ring, cold cyan-blue plasma energy glows with volumetric intensity — like
electrical energy coursing through the structure, with soft light tendrils
reaching inward. The hollow center is open, filled with a deep warm orange
reactor bloom radiating outward from the core, transitioning to the dark navy
of the background. Background is deep navy (#0D1520) with a barely-visible
repeating square tile grid (Terran base terrain pattern) — the grid is subtle,
darker than the field, only legible up close. No text. No literal building.
Cinematic lighting, matte steel materials with metallic sheen, strong bloom on
the inner cyan glow, warm orange vignette at center. The composition fits
inside a rounded square (macOS icon format). Color palette: #0D1520 (deep navy
background), #2A3F52 (gunmetal ring), #4FC3F7 (cyan plasma glow),
#E87C2A (reactor orange center), #C8D8E8 (steel highlight). 1024x1024.
```

### Negative prompt

```
no text, no lettermark, no Zerg, no Protoss, no hexagons, no honeycomb,
no realistic photography, no isometric building, no literal structure,
no cheap gradients, no flat cartoon, no circular ring — must be octagonal
```

---

## Design Rationale

| Element            | Decision                                    | Reason                                                                              |
|--------------------|---------------------------------------------|-------------------------------------------------------------------------------------|
| **Shape**          | Thick octagonal ring (hollow center)        | Command Center footprint from above — same ring formula as AppHive's hexagon        |
| **Ring texture**   | Brushed steel + panel lines + bevel         | Terran industrial aesthetic: heavy, mechanical, authoritative                       |
| **Inner glow**     | Cold cyan-blue plasma along inner edge      | Terran energy color (scanners, shields, SCV sparks) — distinctive from AppHive amber|
| **Center bloom**   | Warm orange reactor light                   | Reactor = power source; `asc` is the power source for all ASC workflows             |
| **Background grid**| Square tile grid, barely visible            | Terran base terrain pattern — contrasts AppHive's hexagonal honeycomb background    |
| **Color**          | Deep navy + steel + cyan + orange           | Cold-industrial with hot-reactor contrast; Terran palette                           |
| **Format**         | Rounded square, no text                     | macOS icon standard, works at all sizes (16px–1024px)                               |

---

## Product Family Consistency

`asc` belongs to the **StarCraft building naming** family shared across the
developer tool suite:

| App      | SC Race  | Building        | Icon direction                        |
|----------|----------|-----------------|---------------------------------------|
| AppNexus | Protoss  | Nexus           | Crystalline blue/gold, geometric      |
| AppHive  | Zerg     | Hive            | Organic purple/amber, hexagonal       |
| asc      | Terran   | Command Center  | Industrial steel/orange, architectural |

The three icons should feel like opposite corners of the same universe — one
crystalline, one organic, one mechanical. Together they form a coherent product
family rooted in the StarCraft lore.

---

## Sizes Required

Use the `apple-icon-generator` skill to produce all sizes from a 1024×1024 source:

| Platform | Sizes                                    |
|----------|------------------------------------------|
| macOS    | 16, 32, 64, 128, 256, 512, 1024         |
| iOS      | 20, 29, 40, 60, 76, 83.5, 1024          |