# analyze_luck_results.R - Luck Lab R Analysis
#
# Analyzes simulated lucky game results: win rates, streak lengths,
# and distribution patterns for luck outcomes.
#
# Usage: Rscript analyze_luck_results.R

# Simulated game outcomes: 1 = win, 0 = lose
set.seed(42)
game_outcomes <- sample(c(1, 0), size = 100, replace = TRUE, prob = c(0.4, 0.6))

# Player names
players <- sprintf("Player_%02d", 1:10)
player_scores <- data.frame(
  name      = players,
  score     = sample(100:500, 10, replace = TRUE),
  wins      = sample(1:10, 10, replace = TRUE),
  games     = sample(10:20, 10, replace = TRUE),
  stringsAsFactors = FALSE
)
player_scores$win_rate <- round(player_scores$wins / player_scores$games, 2)

cat("========================================\n")
cat("   Luck Lab - R Analysis\n")
cat("========================================\n\n")

# ---- Overall Outcome Distribution ----
cat("--- Outcome Distribution (100 games) ---\n")
total_wins   <- sum(game_outcomes)
total_losses <- length(game_outcomes) - total_wins
cat(sprintf("  Wins:  %d (%.1f%%)\n", total_wins, 100 * total_wins / length(game_outcomes)))
cat(sprintf("  Losses:%d (%.1f%%)\n", total_losses, 100 * total_losses / length(game_outcomes)))
cat("\n")

# ---- Win Streak Analysis ----
cat("--- Longest Win Streak ---\n")
rle_result <- rle(game_outcomes)
win_streaks <- rle_result$lengths[rle_result$values == 1]
longest_win_streak <- if (length(win_streaks) > 0) max(win_streaks) else 0
cat(sprintf("  Longest win streak: %d games\n\n", longest_win_streak))

# ---- Player Statistics ----
cat("--- Player Statistics ---\n")
cat(sprintf("%-12s %-8s %-8s %-8s %s\n", "Player", "Score", "Wins", "Games", "WinRate"))
cat("------------------------------------------------\n")
for (i in seq_len(nrow(player_scores))) {
  p <- player_scores[i, ]
  cat(sprintf("%-12s %-8d %-8d %-8d %.2f\n",
              p$name, p$score, p$wins, p$games, p$win_rate))
}
cat("\n")

# ---- Summary Statistics ----
cat("--- Summary Statistics (scores) ---\n")
cat(sprintf("  Min:    %d\n", min(player_scores$score)))
cat(sprintf("  Max:    %d\n", max(player_scores$score)))
cat(sprintf("  Mean:   %.2f\n", mean(player_scores$score)))
cat(sprintf("  Median: %.1f\n", median(player_scores$score)))
cat(sprintf("  SD:     %.2f\n\n", sd(player_scores$score)))

# ---- Top Performer ----
top_player <- player_scores[which.max(player_scores$win_rate), ]
cat("--- Top Performer ---\n")
cat(sprintf("  %s with win rate %.2f\n\n", top_player$name, top_player$win_rate))

cat("Analysis complete.\n")