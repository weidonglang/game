input_path <- file.path("maze-runner-game", "data", "path_log.csv")
output_path <- file.path("maze-runner-game", "analysis", "path_heatmap.png")

if (!file.exists(input_path)) {
  stop("No path log found at ", input_path)
}

logs <- read.csv(input_path, stringsAsFactors = FALSE)

if (nrow(logs) == 0) {
  stop("Path log exists but contains no rows.")
}

latest_session <- tail(unique(logs$session_id), 1)
session_logs <- logs[logs$session_id == latest_session, ]

max_x <- max(session_logs$x) + 1
max_y <- max(session_logs$y) + 1
heat <- matrix(0, nrow = max_y, ncol = max_x)

for (i in seq_len(nrow(session_logs))) {
  row_index <- session_logs$y[i] + 1
  col_index <- session_logs$x[i] + 1
  heat[row_index, col_index] <- heat[row_index, col_index] + 1
}

png(output_path, width = 800, height = 800)
par(mar = c(4, 4, 3, 5))
image(
  x = seq_len(ncol(heat)),
  y = seq_len(nrow(heat)),
  z = t(heat[nrow(heat):1, , drop = FALSE]),
  col = colorRampPalette(c("#f2efe6", "#d98f4e", "#b3362d"))(24),
  xlab = "X",
  ylab = "Y",
  main = paste("Maze Path Heatmap:", latest_session)
)
dev.off()

cat("Heatmap written to", output_path, "\n")
