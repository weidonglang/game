function summary = summarizeCoinFlip(all_rounds, players)
%SUMMARIZECOINFLIP  Summarize results of a coin flip tournament
%   summary = summarizeCoinFlip(all_rounds, players) computes
%   final scores and statistics from all rounds of a coin flip tournament.
%
%   Input:
%       all_rounds - cell array, each cell is a struct array of round matches
%       players    - cell array of player name strings
%
%   Output:
%       summary - struct with fields:
%           .scores  - total points per player
%           .rounds  - number of rounds played
%           .winner  - name of winner, 'Tie' if multiple
%           .table   - formatted score table string
%           .wins    - total wins per player
%           .losses  - total losses per player
%
%   Algorithm:
%       1. Initialize scores/wins/losses arrays for each player
%       2. For each round, for each match, find player indexes and update
%       3. Determine winner(s) by max score
%       4. Build summary struct
%
%   Edge Cases:
%       - Empty all_rounds: throws error
%       - Empty players: throws error
%       - Player not found: silently skipped
%       - Tie: winner = 'Tie'
%
%   Complexity: O(r * m) time, O(n) space
%
%   See also playCoinFlip, simulateCoinFlipRound

if ~iscell(all_rounds) || isempty(all_rounds)
    error('Arcade:InvalidArgument', ...
        'SUMMARIZECOINFLIP requires a non-empty cell array');
end

if ~iscell(players) || isempty(players)
    error('Arcade:InvalidArgument', ...
        'SUMMARIZECOINFLIP requires a non-empty cell array of players');
end

n_players = length(players);
n_rounds = length(all_rounds);

scores = zeros(1, n_players);
wins = zeros(1, n_players);
losses = zeros(1, n_players);

for r = 1:n_rounds
    round_data = all_rounds{r};
    for m = 1:length(round_data)
        match = round_data(m);
        p1_idx = find(strcmp(players, match.player1), 1);
        p2_idx = find(strcmp(players, match.player2), 1);
        if ~isempty(p1_idx)
            scores(p1_idx) = scores(p1_idx) + match.points1;
            if strcmp(match.winner, match.player1)
                wins(p1_idx) = wins(p1_idx) + 1;
            else
                losses(p1_idx) = losses(p1_idx) + 1;
            end
        end
        if ~isempty(p2_idx)
            scores(p2_idx) = scores(p2_idx) + match.points2;
            if strcmp(match.winner, match.player2)
                wins(p2_idx) = wins(p2_idx) + 1;
            else
                losses(p2_idx) = losses(p2_idx) + 1;
            end
        end
    end
end

[max_score, ~] = max(scores);
winners = players(scores == max_score);
if length(winners) == 1
    winner_str = winners{1};
else
    winner_str = 'Tie';
end

summary.scores = scores;
summary.rounds = n_rounds;
summary.winner = winner_str;
summary.table = arcadeScoreTable(players, scores);
summary.wins = wins;
summary.losses = losses;
end