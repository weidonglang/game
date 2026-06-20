function summary = summarizeLuckyWheel(all_rounds, players)
%SUMMARIZELUCKYWHEEL  Summarize results of a lucky wheel tournament
%   summary = summarizeLuckyWheel(all_rounds, players) summarizes
%   the results of a multi-round lucky wheel tournament.
%
%   Input:
%       all_rounds - cell array where each cell is a struct array of round data.
%                    Each struct has fields: player, section, prize, bank_before,
%                    bank_after, points
%       players    - cell array of player name strings
%
%   Output:
%       summary - struct with fields:
%           .rounds  - total number of rounds played
%           .scores  - numeric array of final scores (index matches players)
%           .winner  - string name of the winner (lexicographic tie-break)
%           .table   - formatted ASCII score table
%
%   Algorithm:
%       1. Initialize scores array zero for each player
%       2. For each round, for each spin in that round:
%          a. Find player index
%          b. Add points to that player's score
%       3. Find max score and winner (lexicographic tie-break)
%       4. Build and return summary struct
%
%   Edge Cases:
%       - Empty all_rounds: handles gracefully (zero rounds, zero scores)
%       - Empty players: handles gracefully (zero length)
%       - Player name not found: silently skipped (player_idx empty)
%       - Single player: always wins
%       - Tie: resolved lexicographically (first alphabetically wins)
%
%   Complexity: O(r * n) time for r rounds, n players; O(n) space
%
%   Examples:
%       summarizeLuckyWheel(all_rounds, {'Spinner-1', 'Spinner-2'})
%
%   See also playLuckyWheel, spinLuckyWheel

num_players = length(players);
num_rounds = length(all_rounds);

% Initialize scores
scores = zeros(1, num_players);

% Aggregate scores across all rounds
for r = 1:num_rounds
    round_data = all_rounds{r};
    for s = 1:length(round_data)
        player_name = round_data(s).player;
        player_idx = find(strcmp(players, player_name), 1);
        if ~isempty(player_idx)
            scores(player_idx) = scores(player_idx) + round_data(s).points;
        end
    end
end

% Find winner (lexicographic tie-break)
[max_score, max_idx] = max(scores);
winner_candidates = find(scores == max_score);
if length(winner_candidates) > 1
    winner_names = players(winner_candidates);
    [~, tie_idx] = min(winner_names);
    max_idx = winner_candidates(tie_idx);
end

% Build summary
summary.rounds = num_rounds;
summary.scores = scores;
summary.winner = players{max_idx};

% Build ASCII score table
summary.table = '';
for i = 1:num_players
    summary.table = [summary.table, sprintf('%s: %d\n', players{i}, scores(i))];
end
end