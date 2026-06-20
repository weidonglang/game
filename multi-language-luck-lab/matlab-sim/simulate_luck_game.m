%% simulate_luck_game.m
% Luck Lab - MATLAB Luck Simulation
%
% Simulates a coin-based lucky game session for multiple players.
% Tracks cumulative scores and prints summary statistics.
%
% Usage: Run this script in MATLAB or Octave:
%   >> simulate_luck_game

function simulate_luck_game()
    fprintf('========================================\n');
    fprintf('   Luck Lab - MATLAB Simulation\n');
    fprintf('========================================\n\n');

    % ---- Parameters ----
    num_players = 4;
    num_rounds  = 10;  % rounds per player
    outcomes    = {'Win', 'Lose'};

    % ---- Player names ----
    names = {'Alice', 'Bob', 'Charlie', 'Diana'};

    % ---- Score tracking ----
    scores = zeros(num_players, 1);
    wins   = zeros(num_players, 1);
    history = zeros(num_players, num_rounds);  % 1 = win, 0 = lose

    % ---- Simulate rounds ----
    rng(123);  % reproducible
    for r = 1:num_rounds
        for p = 1:num_players
            % 40% win rate per round
            result = rand() < 0.4;
            history(p, r) = result;
            if result
                scores(p) = scores(p) + randi([10, 50]);
                wins(p)   = wins(p) + 1;
            else
                scores(p) = scores(p) + randi([1, 5]);  % consolation
            end
        end
    end

    % ---- Compute statistics ----
    avg_score = mean(scores);
    best_idx  = find(scores == max(scores), 1);
    worst_idx = find(scores == min(scores), 1);

    % ---- Display results ----
    fprintf('--- Simulation Results ---\n');
    fprintf('Players: %d\n', num_players);
    fprintf('Rounds per player: %d\n\n', num_rounds);

    fprintf('%-12s %-10s %-10s %s\n', 'Player', 'Score', 'Wins', 'WinRate');
    fprintf('----------------------------------------\n');
    for p = 1:num_players
        rate = wins(p) / num_rounds;
        fprintf('%-12s %-10d %-10d %.2f\n', names{p}, scores(p), wins(p), rate);
    end
    fprintf('\n');

    fprintf('--- Summary ---\n');
    fprintf('Average Score: %.2f\n', avg_score);
    fprintf('Best:  %s (%d points)\n', names{best_idx}, scores(best_idx));
    fprintf('Worst: %s (%d points)\n', names{worst_idx}, scores(worst_idx));

    % ---- Win streak analysis ----
    fprintf('\n--- Win Streaks ---\n');
    for p = 1:num_players
        streak = 0;
        max_streak = 0;
        for r = 1:num_rounds
            if history(p, r) == 1
                streak = streak + 1;
                if streak > max_streak
                    max_streak = streak;
                end
            else
                streak = 0;
            end
        end
        fprintf('%s: longest streak = %d\n', names{p}, max_streak);
    end

    % ---- Plot cumulative scores (if graphics available) ----
    try
        figure;
        cumulative = cumsum(history, 2);
        hold on;
        colors = {'b', 'r', 'g', 'm'};
        for p = 1:num_players
            plot(1:num_rounds, cumulative(p, :) * 50, 'Color', colors{p}, ...
                 'LineWidth', 2, 'DisplayName', names{p});
        end
        xlabel('Round');
        ylabel('Cumulative Score (approx)');
        title('Luck Lab - Player Score Progression');
        legend('Location', 'northwest');
        grid on;
        fprintf('\nPlot displayed successfully.\n');
    catch
        fprintf('\nPlotting skipped (no display available).\n');
    end

    fprintf('\nSimulation complete.\n');
end