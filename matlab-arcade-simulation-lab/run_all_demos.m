function run_all_demos()
%RUNALLDEMOS  Run all demo scripts for the Arcade Simulation Lab
%   run_all_demos() executes all available demonstrations to showcase
%   the functionality of the arcade simulation toolkit.
%
%   Demos include:
%       1. Coin Flip Simulation - random coin tosses
%       2. Dice Rolling - simulate various dice rolls
%       3. Tournament Simulation - round-robin competitions
%       4. Score Table & Analysis - display and analyze results
%       5. Weighted Random Choices - probability-based selection
%       6. Text Progress Bar - visual feedback for simulations
%       7. Shuffle Demo - random permutation of items
%
%   See also run_all_tests, arcadeConfig

fprintf('========================================\n');
fprintf('  MATLAB Arcade Simulation Lab - Demos\n');
fprintf('========================================\n');
fprintf('\n');

%% Demo 1: Coin Flip Simulation
fprintf('--- Demo 1: Coin Flip Simulation ---\n');
arcadeSeed(1234);
results_heads = 0;
results_tails = 0;
num_flips = 1000;
for i = 1:num_flips
    flip = arcadeCoinFlip();
    if strcmp(flip, 'heads')
        results_heads = results_heads + 1;
    else
        results_tails = results_tails + 1;
    end
end
pct_heads = results_heads / num_flips * 100;
pct_tails = results_tails / num_flips * 100;
fprintf('Flipped %d coins:\n', num_flips);
fprintf('  Heads: %d (%.1f%%)\n', results_heads, pct_heads);
fprintf('  Tails: %d (%.1f%%)\n', results_tails, pct_tails);
fprintf('  Difference from ideal: %.1f%%\n', abs(pct_heads - 50));
fprintf('\n');

%% Demo 2: Dice Rolling
fprintf('--- Demo 2: Dice Rolling ---\n');
arcadeSeed(5678);
fprintf('Single d6 rolls:\n');
for i = 1:5
    result = arcadeDiceRoll(6);
    fprintf('  Roll %d: %d\n', i, result);
end
fprintf('2d6 + 3: %d\n', arcadeDiceRoll(6, 2, 3));
fprintf('d20 roll: %d\n', arcadeDiceRoll(20));
fprintf('d100 (percentage): %d\n', arcadeDiceRoll(100));
fprintf('\n');

%% Demo 3: Normalization and Validation
fprintf('--- Demo 3: Input Normalization & Validation ---\n');
test_inputs = {'Heads', '  heads  ', 'TAILS', 't', 'h', 'invalid!', '  '};
for i = 1:length(test_inputs)
    input_str = test_inputs{i};
    normalized = arcadeNormalizeName(input_str);
    valid = arcadeValidateProbability(0.5);
    fprintf('  normalize(''%s'') -> ''%s''\n', input_str, normalized);
end
fprintf('  Probability validation [0.5, 1.5]: [%d, %d]\n', ...
    arcadeValidateProbability(0.5), arcadeValidateProbability(1.5));
fprintf('\n');

%% Demo 4: Weighted Random Selection
fprintf('--- Demo 4: Weighted Random Choices ---\n');
arcadeSeed(9012);
items = {'Common', 'Uncommon', 'Rare', 'Legendary'};
weights = [0.50, 0.30, 0.15, 0.05];
fprintf('Item drop rates:\n');
for i = 1:length(items)
    fprintf('  %s: %.0f%%\n', items{i}, weights(i) * 100);
end
fprintf('Simulating 20 drops:\n');
drop_counts = zeros(1, length(items));
for i = 1:20
    choice = arcadeWeightedChoice(items, weights);
    idx = find(strcmp(items, choice));
    drop_counts(idx) = drop_counts(idx) + 1;
    fprintf('  Drop %2d: %s\n', i, choice);
end
fprintf('\n');

%% Demo 5: Shuffle
fprintf('--- Demo 5: Shuffle ---\n');
arcadeSeed(3456);
deck = {};
suits = {'Hearts', 'Diamonds', 'Clubs', 'Spades'};
values = {'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'};
for s = 1:length(suits)
    for v = 1:length(values)
        deck{end+1} = sprintf('%s of %s', values{v}, suits{s});
    end
end
fprintf('Deck has %d cards.\n', length(deck));
shuffled = arcadeShuffle(deck);
fprintf('Top 5 cards after shuffle:\n');
for i = 1:5
    fprintf('  %d. %s\n', i, shuffled{i});
end
fprintf('\n');

%% Demo 6: Tournament Simulation
fprintf('--- Demo 6: Tournament Simulation ---\n');
arcadeSeed(7890);
players = {'Alice', 'Bob', 'Carol', 'Dave'};
num_rounds = 50;
fprintf('Round-robin tournament with %d players:\n', length(players));
fprintf('Rounds per matchup: %d\n\n', num_rounds);

% Define different strategies
strategies = cell(1, length(players));
strategies{1} = @() arcadeRandomChoice({'cooperate', 'defect'});
strategies{2} = @() 'cooperate';  % Always cooperate
strategies{3} = @() 'defect';     % Always defect
strategies{4} = @() arcadeRandomChoice({'cooperate', 'defect'});

results = arcadeSimulateTournament(players, num_rounds, strategies);
fprintf('Final Scores:\n');
for i = 1:length(players)
    bar = arcadeTextBar(results.scores(i) / max(results.scores), 15);
    fprintf('  %-10s: %3d points %s\n', players{i}, results.scores(i), bar);
end
fprintf('\n');

%% Demo 7: Score Table & Analysis
fprintf('--- Demo 7: Score Table & Analysis ---\n');
tbl = results.table;
fprintf('Ranked Score Table:\n');
fprintf('  %-5s %-10s %-10s\n', 'Rank', 'Player', 'Score');
fprintf('  %-5s %-10s %-10s\n', '-----', '----------', '----------');
for i = 1:size(tbl, 1)
    fprintf('  %-5s %-10s %-10s\n', tbl{i,1}, tbl{i,2}, tbl{i,3});
end

% Analyze scores
stats = arcadeAnalyzeResults(results.scores, 'Tournament');
fprintf('\nScore Analysis:\n');
fprintf('  Mean: %.1f (CI: %.1f - %.1f)\n', stats.mean, stats.ci_lower, stats.ci_upper);
fprintf('  Median: %.1f\n', stats.median);
fprintf('  Std Dev: %.1f\n', stats.std);
fprintf('  Range: %.1f\n', stats.range);
fprintf('  Count: %d\n', stats.count);
fprintf('\n');

%% Demo 8: Text Progress Bar
fprintf('--- Demo 8: Text Progress Bars ---\n');
progress_values = [0, 0.15, 0.25, 0.33, 0.50, 0.667, 0.75, 0.90, 1.0];
for i = 1:length(progress_values)
    p = progress_values(i);
    bar = arcadeTextBar(p, 25);
    fprintf('  Progress %5.1f%%: %s\n', p * 100, bar);
end
fprintf('\n');

%% Demo 9: Large Number Formatting
fprintf('--- Demo 9: Score Formatting ---\n');
scores_to_format = [42, 1234, 50000, 1000000, 999999999];
for i = 1:length(scores_to_format)
    formatted = arcadeFormatScore(scores_to_format(i));
    pct = arcadeFormatPercent(scores_to_format(i) / 1000000000);
    fprintf('  %10d -> %s (%s of max)\n', scores_to_format(i), formatted, pct);
end
fprintf('\n');

%% Summary
fprintf('========================================\n');
fprintf('  All demos completed successfully!\n');
fprintf('========================================\n');
end