args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = FALSE)
  script_dir <- dirname(script_path)
} else {
  script_dir <- file.path(getwd(), "pixel-cell-war", "analysis")
}

root_dir <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
csv_path <- file.path(root_dir, "data", "cell_counts.csv")
out_path <- file.path(root_dir, "analysis", "cell_counts.png")

if (!file.exists(csv_path)) {
  stop("Missing CSV log: ", csv_path)
}

counts <- read.csv(csv_path)
if (!all(c("turn", "red_cells", "blue_cells", "green_cells", "empty_cells") %in% names(counts))) {
  stop("CSV does not contain the expected Pixel Cell War columns.")
}

png(out_path, width = 960, height = 560)
matplot(counts$turn,
        counts[, c("red_cells", "blue_cells", "green_cells", "empty_cells")],
        type = "l",
        lwd = 3,
        lty = 1,
        col = c("#D93636", "#2F6BFF", "#25A55A", "#777777"),
        xlab = "Turn",
        ylab = "Cells",
        main = "Pixel Cell War Faction Counts")
legend("topright",
       legend = c("Red", "Blue", "Green", "Empty"),
       col = c("#D93636", "#2F6BFF", "#25A55A", "#777777"),
       lty = 1,
       lwd = 3,
       bty = "n")
grid()
dev.off()

cat("Wrote", out_path, "\n")
