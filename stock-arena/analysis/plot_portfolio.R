args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) > 0) {
  script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = FALSE))
} else {
  script_dir <- file.path(getwd(), "stock-arena", "analysis")
}

root_dir <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
csv_path <- file.path(root_dir, "data", "portfolio_log.csv")
out_path <- file.path(root_dir, "analysis", "portfolio_curve.png")

if (!file.exists(csv_path)) stop("Missing CSV log: ", csv_path)
log <- read.csv(csv_path)
required <- c("day", "cash", "portfolio_value", "alpha_price", "beta_price", "gamma_price")
if (!all(required %in% names(log))) stop("Unexpected Stock Arena log columns.")

peak <- cummax(log$portfolio_value)
drawdown <- (log$portfolio_value - peak) / peak

png(out_path, width = 1000, height = 700)
par(mfrow = c(2, 1), mar = c(4, 4, 3, 2))
plot(log$day, log$portfolio_value,
     type = "l", lwd = 3, col = "#2F855A",
     xlab = "Day", ylab = "Portfolio value",
     main = "Stock Arena Portfolio Value")
grid()
matplot(log$day,
        log[, c("alpha_price", "beta_price", "gamma_price")],
        type = "l", lty = 1, lwd = 3,
        col = c("#2B6CB0", "#DD6B20", "#805AD5"),
        xlab = "Day", ylab = "Asset price",
        main = "Asset Prices")
legend("topleft", legend = c("ALPHA", "BETA", "GAMMA"),
       col = c("#2B6CB0", "#DD6B20", "#805AD5"),
       lty = 1, lwd = 3, bty = "n")
grid()
dev.off()

cat("Wrote", out_path, "\n")
cat("Max drawdown:", round(min(drawdown) * 100, 2), "%\n")
