/*
 * score_analyzer.cpp - Luck Lab Score Analyzer
 *
 * A C++ program that analyzes a set of player scores from lucky games.
 * Computes totals, averages, highs/lows, and prints a leaderboard.
 *
 * Compilation: g++ -std=c++17 -Wall -Wextra -pedantic score_analyzer.cpp -o score_analyzer.exe
 * Usage:       ./score_analyzer.exe
 */

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <iomanip>
#include <numeric>

struct PlayerScore {
    std::string name;
    int score;
    int wins;
};

/*
 * Calculate the total score across all players.
 */
int total_score(const std::vector<PlayerScore>& players)
{
    int sum = 0;
    for (const auto& p : players) {
        sum += p.score;
    }
    return sum;
}

/*
 * Calculate the average score across all players.
 */
double average_score(const std::vector<PlayerScore>& players)
{
    if (players.empty()) return 0.0;
    return static_cast<double>(total_score(players)) / players.size();
}

/*
 * Find the player with the highest score.
 * Returns a copy; assumes non-empty vector.
 */
PlayerScore best_player(const std::vector<PlayerScore>& players)
{
    auto it = std::max_element(players.begin(), players.end(),
        [](const PlayerScore& a, const PlayerScore& b) {
            return a.score < b.score;
        });
    return *it;
}

/*
 * Find the player with the lowest score.
 * Returns a copy; assumes non-empty vector.
 */
PlayerScore worst_player(const std::vector<PlayerScore>& players)
{
    auto it = std::min_element(players.begin(), players.end(),
        [](const PlayerScore& a, const PlayerScore& b) {
            return a.score < b.score;
        });
    return *it;
}

/*
 * Count total number of wins across all players.
 */
int total_wins(const std::vector<PlayerScore>& players)
{
    int sum = 0;
    for (const auto& p : players) {
        sum += p.wins;
    }
    return sum;
}

/*
 * Print a sorted leaderboard (highest score first).
 */
void print_leaderboard(std::vector<PlayerScore> players)
{
    std::sort(players.begin(), players.end(),
        [](const PlayerScore& a, const PlayerScore& b) {
            return a.score > b.score;
        });

    std::cout << "\n========= LEADERBOARD =========\n";
    std::cout << std::left << std::setw(6) << "Rank"
              << std::setw(16) << "Player"
              << std::setw(8) << "Score"
              << "Wins\n";
    std::cout << "---------------------------------\n";

    for (size_t i = 0; i < players.size(); i++) {
        std::cout << std::left << std::setw(6) << (i + 1)
                  << std::setw(16) << players[i].name
                  << std::setw(8) << players[i].score
                  << players[i].wins << "\n";
    }
    std::cout << "=================================\n\n";
}

int main()
{
    /* Sample player data from lucky games */
    std::vector<PlayerScore> players = {
        {"Alice",    340, 5},
        {"Bob",      210, 3},
        {"Charlie",  480, 7},
        {"Diana",    150, 2},
        {"Eve",      390, 6},
        {"Frank",    270, 4},
        {"Grace",    510, 8},
        {"Henry",    180, 2}
    };

    std::cout << "========================================\n";
    std::cout << "   Luck Lab - Score Analyzer (C++)\n";
    std::cout << "========================================\n\n";

    std::cout << "Analyzing " << players.size() << " players...\n\n";

    std::cout << "Total Score:       " << total_score(players) << "\n";
    std::cout << "Average Score:     " << std::fixed << std::setprecision(2)
              << average_score(players) << "\n";
    std::cout << "Total Wins:        " << total_wins(players) << "\n";
    std::cout << "Highest Score:     "
              << best_player(players).name << " ("
              << best_player(players).score << ")\n";
    std::cout << "Lowest Score:      "
              << worst_player(players).name << " ("
              << worst_player(players).score << ")\n";

    print_leaderboard(players);

    std::cout << "Analysis complete.\n";

    return 0;
}