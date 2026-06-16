args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = FALSE)
  script_dir <- dirname(script_path)
} else {
  script_dir <- file.path(getwd(), "reactor-cooling-crisis", "analysis")
}

root_dir <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
csv_path <- file.path(root_dir, "data", "reactor_log.csv")
out_path <- file.path(root_dir, "analysis", "reactor_curves.png")

if (!file.exists(csv_path)) {
  stop("Missing CSV log: ", csv_path)
}

log <- read.csv(csv_path)
required <- c("time_sec", "temperature", "cooling_flow", "control_rod_depth", "power_output", "risk_score")
if (!all(required %in% names(log))) {
  stop("CSV does not contain the expected Reactor Cooling Crisis columns.")
}

png(out_path, width = 1000, height = 700)
par(mfrow = c(2, 1), mar = c(4, 4, 3, 2))

plot(log$time_sec, log$temperature,
     type = "l", lwd = 3, col = "#D93636",
     xlab = "Time (seconds)", ylab = "Temperature",
     main = "Reactor Temperature")
abline(h = c(560, 760), col = c("#2F855A", "#C53030"), lty = 2, lwd = 2)
grid()

matplot(log$time_sec,
        log[, c("risk_score", "cooling_flow", "control_rod_depth", "power_output")],
        type = "l", lty = 1, lwd = 3,
        col = c("#DD6B20", "#2B6CB0", "#805AD5", "#2F855A"),
        xlab = "Time (seconds)", ylab = "Normalized value",
        main = "Risk and Operator Settings")
legend("topright",
       legend = c("Risk", "Cooling", "Rods", "Power"),
       col = c("#DD6B20", "#2B6CB0", "#805AD5", "#2F855A"),
       lty = 1, lwd = 3, bty = "n")
grid()

dev.off()
cat("Wrote", out_path, "\n")
