args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) > 0) {
  script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = FALSE))
} else {
  script_dir <- file.path(getwd(), "traffic-light-dispatch", "analysis")
}

root_dir <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
csv_path <- file.path(root_dir, "data", "traffic_log.csv")
out_path <- file.path(root_dir, "analysis", "traffic_wait.png")

if (!file.exists(csv_path)) stop("Missing CSV log: ", csv_path)
log <- read.csv(csv_path)
required <- c("time_sec", "north_queue", "south_queue", "east_queue", "west_queue", "phase", "avg_wait")
if (!all(required %in% names(log))) stop("Unexpected traffic log columns.")

png(out_path, width = 1000, height = 650)
par(mfrow = c(2, 1), mar = c(4, 4, 3, 2))
matplot(log$time_sec,
        log[, c("north_queue", "south_queue", "east_queue", "west_queue")],
        type = "l", lty = 1, lwd = 3,
        col = c("#2B6CB0", "#38A169", "#DD6B20", "#805AD5"),
        xlab = "Time (seconds)", ylab = "Queue length",
        main = "Traffic queues by direction")
legend("topleft", legend = c("North", "South", "East", "West"),
       col = c("#2B6CB0", "#38A169", "#DD6B20", "#805AD5"),
       lty = 1, lwd = 3, bty = "n")
grid()

plot(log$time_sec, log$avg_wait,
     type = "l", lwd = 3, col = "#D53F8C",
     xlab = "Time (seconds)", ylab = "Average wait",
     main = "Average waiting time")
grid()
dev.off()

cat("Wrote", out_path, "\n")
