function summary = summarizeDiceDuel(all_rounds, players)
%SUMMARIZEDICEDUEL  Summarize the results of a dice duel tournament
%   summary = summarizeDiceDuel(all_rounds, players) computes
%   final scores and statistics from all rounds of a dice duel tournament.
%
%   Input:
%       all_rounds - cell array, each cell contains the struct array from
%                    one round of resolveDiceDuelRound
%       players    - cell array of player name strings
%
%   Output:
%       summary    - struct with fields:
%           summary.scores      - total points per player
%           summary.rounds      - number of rounds played
%           summary.winner      - name of winner(s), 'Tie' if multiple
%           summary.results     - cell array with per-round match results
%           summary.table       - formatted score table
%           summary.wins        - total wins per player
%           summary.draws       - total draws per player
%           summary.losses      - total losses per player
%
%   Algorithm:
%       1. Validate all_rounds is non-empty cell array
%       2. Validate players is non-empty cell array
%       3. Initialize scores, wins, draws, losses arrays (1 x n_players, zeros)
%       4. For each round r = 1..n_rounds:
%          a. For each match m = 1..length(round_data):
%             i. Find player indexes via strcmp for p1 and p2
%             ii. Update scores: p1 += match.points1, p2 += match.points2
%             iii. Update win/draw/loss counts for each player based on points
%       5. Determine winner(s): find max score, check for ties
%       6. Build summary struct with scores, rounds, winner, results, table, wins, draws, losses
%       7. Return summary
%
%   Edge Cases:
%       - Empty all_rounds: throw error
%       - Empty players: throw error
%       - Player not found: skip (empty p_idx)
%       - Multiple ties for max score: winner = 'Tie'
%
%   Complexity: O(r * m) time for r rounds, m matches per round; O(r * m) space
%
%   Examples:
%       summary = summarizeDiceDuel(all_rounds, players);
%
%   See also playDiceDuel, resolveDiceDuelRound

if ~iscell(all_rounds) || isempty(all_rounds)
    error('Arcade:InvalidArgument', ...
        'SUMMARIZEDICEDUEL requires a non-empty cell array');
end

if ~iscell(players) || isempty(players)
    error('Arcade:InvalidArgument', ...
        'SUMMARIZEDICEDUEL requires a non-empty cell array of players');
end

n_players = length(players);
n_rounds = length(all_rounds);

% Initialize tracking
scores = zeros(1, n_players);
wins = zeros(1, n_players);
draws = zeros(1, n_players);
losses = zeros(1, n_players);

for r = 1:n_rounds
    round_data = all_rounds{r};
    for m = 1:length(round_data)
        match = round_data(m);
        p1_idx = find(strcmp(players, match.player1));
        p2_idx = find(strcmp(players, match.player2));
        if ~isempty(p1_idx)
            scores(p1_idx) = scores(p1_idx) + match.points1;
            if match.points1 == 1
                wins(p1_idx) = wins(p1_idx) + 1;
            elseif match.points1 == 0.5
                draws(p1_idx) = draws(p1_idx) + 1;
            else
                losses(p1_idx) = losses(p1_idx) + 1;
            end
        end
        if ~isempty(p2_idx)
            scores(p2_idx) = scores(p2_idx) + match.points2;
            if match.points2 == 1
                wins(p2_idx) = wins(p2_idx) + 1;
            elseif match.points2 == 0.5
                draws(p2_idx) = draws(p2_idx) + 1;
            else
                losses(p2_idx) = losses(p2_idx) + 1;
            end
        end
    end
end

% Determine winner(s)
[max_score, ~] = max(scores);
winners = players(scores == max_score);
if length(winners) == 1
    winner_str = winners{1};
else
    winner_str = 'Tie';
end

% Build output struct
summary.scores = scores;
summary.rounds = n_rounds;
summary.winner = winner_str;
summary.results = all_rounds;
summary.table = arcadeScoreTable(players, scores);
summary.wins = wins;
summary.draws = draws;
summary.losses = losses;
end