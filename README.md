# 🐝 StatBeeSticker

Sticker designs inspired by the **Department of Social Statistics** at the **University of Manchester**, featuring the iconic **Manchester bee** 🐝.

<img src="sticker/socialstats_hex.png" alt="StatBee Sticker" width="250" align="right" />

---

## 🎨 Overview

This R project creates a custom **hex sticker** that follows the University of Manchester’s brand colours:

- **Purple:** `#6B2C91`  
- **Yellow:** `#FFCC00`

The sticker combines:
- The **University of Manchester logo**  
- The **Department of Social Statistics** label  
- The **Manchester bee** icon  

All elements are composed with [`ggplot2`](https://ggplot2.tidyverse.org/) and [`magick`](https://docs.ropensci.org/magick/), creating a clean, high-resolution hex suitable for use in packages, websites, or presentations.

---

## ⚙️ How it works

The sticker is built in layers:

1. **Hex base** using `ggplot2`  
2. **University logo** composited near the top  
3. **Department text** rendered via `ragg` for crisp, font-safe output  
4. **Bee icon** positioned near the bottom  

The `magick` package handles all image compositing and alignment.

---

## 📦 Requirements

You’ll need the following R packages:

```r
install.packages(c("ggplot2", "magick", "fs", "ragg"))
