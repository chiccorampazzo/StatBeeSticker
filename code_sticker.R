# install.packages(c("ggplot2", "magick", "fs", "ragg"))  # if needed
library(ggplot2)
library(magick)
library(fs)
library(ragg)

# =========================
# ---- Brand colours -----
# =========================
uom_purple <- "#6B2C91"
uom_yellow <- "#FFCC00"

# ===============================================
# ---- helper: regular hexagon coordinates -------
# ===============================================
hex_df <- function(cx = 0, cy = 0, r = 1) {
  angles <- seq(0, 2 * pi, length.out = 7) + pi / 6
  data.frame(x = cx + r * cos(angles), y = cy + r * sin(angles))
}

# =========================
# ---- Directory & paths ---
# =========================
bee_path    <- "components/bee.png"
logo_path   <- "components/TAB_col_white_background.png"
dir_create("sticker")
base_path   <- "sticker/_base_hex.png"
out_path    <- "sticker/socialstats_hex.png"

# =========================
# ---- Layout options -----
# =========================
r_main   <- 1
border_w <- 2.8
pad      <- 0.15

# element sizes (relative to sticker width)
logo_scale <- 0.40
bee_scale  <- 0.38

# vertical layout (center positions as fractions of total height; top=0, bottom=1)
logo_center_y_frac <- 0.33
text_center_y_frac <- 0.475
bee_center_y_frac  <- 0.675

# department label (toggle one-line vs two-line if you like)
two_line <- TRUE
dept_text <- if (two_line) "Department of\nSocial Statistics" else "Department of Social Statistics"

# =========================
# ---- Base sticker (ggplot)
# =========================
p <- ggplot() +
  geom_polygon(
    data   = hex_df(0, 0, r_main),
    aes(x, y),
    fill   = uom_purple,
    colour = uom_yellow,
    linewidth = border_w,
    linejoin  = "round"
  ) +
  coord_equal(xlim = c(-r_main - pad, r_main + pad),
              ylim = c(-r_main - pad, r_main + pad), expand = FALSE) +
  theme_void()

ggsave(base_path, p, width = 3.2, height = 3.7, dpi = 600, bg = "transparent")

# ==========================================
# ---- Composite layers with {magick} -------
# ==========================================
stkr <- image_read(base_path)
stkr_info <- image_info(stkr)
W <- stkr_info$width
H <- stkr_info$height

# helper: center an overlay at a given Y fraction
place_centered <- function(base, overlay, center_y_frac) {
  oi <- image_info(overlay)
  x_off <- round((image_info(base)$width  - oi$width)  / 2)
  y_off <- round(center_y_frac * image_info(base)$height - oi$height / 2)
  image_composite(base, overlay, offset = paste0("+", x_off, "+", y_off))
}

# ---- University logo ----
stopifnot(file.exists(logo_path))
logo <- image_read(logo_path)
logo <- image_scale(logo, as.character(round(W * logo_scale)))
stkr <- place_centered(stkr, logo, logo_center_y_frac)

# ---- Department text (render with ggplot + ragg to avoid FreeType issues) ----
text_w_px <- round(W * 0.86)
text_h_px <- round(H * if (two_line) 0.18 else 0.14)
tmp_text  <- file.path(tempdir(), "dept_text.png")

p_text <- ggplot() +
  xlim(0, 1) + ylim(0, 1) +
  theme_void() +
  annotate(
    "text",
    x = 0.5, y = 0.5,
    label   = dept_text,
    colour  = uom_yellow,
    fontface= "bold",
    size    = if (two_line) 5 else 4.5,   # tune if needed
    lineheight = 0.98
  )

# save transparent text image at exact pixel size using ragg device
ggsave(
  filename = tmp_text, plot = p_text,
  width = text_w_px/600, height = text_h_px/600, dpi = 600,
  bg = "transparent", device = ragg::agg_png, limitsize = FALSE
)

text_img <- image_read(tmp_text)
stkr <- place_centered(stkr, text_img, text_center_y_frac)

# ---- Bee image (below the text) ----
stopifnot(file.exists(bee_path))
bee <- image_read(bee_path)
bee <- image_scale(bee, as.character(round(W * bee_scale)))
stkr <- place_centered(stkr, bee, bee_center_y_frac)

# ---- Save final ----
image_write(stkr, path = out_path)
message("✅ Sticker saved: ", out_path)

