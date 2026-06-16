set.seed(42)

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) > 0) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = FALSE)
  script_dir <- dirname(script_path)
} else {
  script_dir <- file.path(getwd(), "dice-duel-king", "analysis")
}

root_dir <- normalizePath(file.path(script_dir, ".."), mustWork = FALSE)
data_dir <- file.path(root_dir, "data")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

roll <- function(n, sides) sum(sample.int(sides, n, replace = TRUE))

skill_names <- c("steady", "heavy", "guard", "charge")

resolve_skill <- function(skill, charge) {
  if (skill == "steady") {
    value <- roll(2, 6)
    return(list(roll = value, damage = value + charge, block = 0, charge = 0))
  }
  if (skill == "heavy") {
    value <- roll(1, 20)
    damage <- if (value < 6) 0 else value + charge
    return(list(roll = value, damage = damage, block = 0, charge = 0))
  }
  if (skill == "guard") {
    value <- roll(1, 8)
    return(list(roll = value, damage = 2, block = value + floor(charge / 2), charge = 0))
  }
  value <- roll(1, 4)
  list(roll = value, damage = 1, block = 0, charge = min(charge + value + 2, 18))
}

choose_skill <- function(policy, self_hp, other_hp, charge) {
  if (policy == "steady") return("steady")
  if (policy == "heavy") return("heavy")
  if (policy == "guarded") {
    if (self_hp <= 9 && runif(1) < 0.55) return("guard")
    if (charge >= 8) return("heavy")
    if (runif(1) < 0.25) return("charge")
    return("steady")
  }
  if (policy == "charger") {
    if (charge >= 10) return("heavy")
    if (runif(1) < 0.55) return("charge")
    return("steady")
  }
  if (other_hp <= 10 && runif(1) < 0.5) return("heavy")
  if (runif(1) < 0.25) return("charge")
  sample(c("steady", "heavy", "guard"), 1, prob = c(0.55, 0.3, 0.15))
}

simulate_game <- function(player_policy, enemy_policy) {
  player_hp <- 30
  enemy_hp <- 30
  player_charge <- 0
  enemy_charge <- 0

  for (round in seq_len(80)) {
    player_skill <- choose_skill(player_policy, player_hp, enemy_hp, player_charge)
    enemy_skill <- choose_skill(enemy_policy, enemy_hp, player_hp, enemy_charge)
    player_result <- resolve_skill(player_skill, player_charge)
    enemy_result <- resolve_skill(enemy_skill, enemy_charge)
    player_charge <- player_result$charge
    enemy_charge <- enemy_result$charge

    enemy_hp <- enemy_hp - max(0, player_result$damage - enemy_result$block)
    player_hp <- player_hp - max(0, enemy_result$damage - player_result$block)

    if (player_hp <= 0 || enemy_hp <= 0) break
  }

  if (player_hp > enemy_hp) "player_win" else if (enemy_hp > player_hp) "enemy_win" else "draw"
}

policies <- c("balanced", "steady", "heavy", "guarded", "charger")
games_per_policy <- 2000
results <- data.frame(policy = character(), result = character(), stringsAsFactors = FALSE)

for (policy in policies) {
  outcomes <- replicate(games_per_policy, simulate_game(policy, "balanced"))
  results <- rbind(results, data.frame(policy = policy, result = outcomes, stringsAsFactors = FALSE))
}

summary <- aggregate(result ~ policy, results, function(x) mean(x == "player_win"))
names(summary) <- c("policy", "win_rate")
summary$games <- games_per_policy
summary <- summary[order(summary$win_rate, decreasing = TRUE), ]

write.csv(summary, file.path(data_dir, "strategy_summary.csv"), row.names = FALSE)

png(file.path(root_dir, "analysis", "strategy_win_rates.png"), width = 900, height = 560)
barplot(summary$win_rate,
        names.arg = summary$policy,
        ylim = c(0, 1),
        col = c("#5B8DEF", "#38A169", "#DD6B20", "#805AD5", "#D53F8C"),
        main = "Dice Duel King Strategy Win Rates",
        ylab = "Win rate vs balanced enemy")
grid(nx = NA, ny = NULL)
dev.off()

print(summary)
