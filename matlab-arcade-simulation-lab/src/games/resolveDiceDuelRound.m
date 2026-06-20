function round_matches = resolveDiceDuelRound(players, sides, num_dice)
%RESOLVEDICEDUELROUND  Simulate a full round pairings for dice duel
%   round_matches = resolveDiceDuelRound(players, sides, num_dice)
%   pairs up all players and simulates matches between each pair for one
%   round of a dice duel tournament.
%
%   Input:
%       players  - cell array of player name strings (even number)
%       sides    - number of sides on each die (passed to simulateDiceDuelMatch)
%       num_dice - number of dice per player (passed to simulateDiceDuelMatch)
%
%   Output:
%       round_matches - struct array with one entry per match, fields:
%           .player1, .player2, .roll1, .roll2, .winner, .points1, .points2
%
%   Algorithm:
%       1. Validate players is non-empty cell array with even length
%       2. Determine number of matches = length(players) / 2
%       3. Pre-allocate struct array of matches
%       4. For match i = 1..num_matches:
%          a. Pair player(2*i-1) vs player(2*i)
%          b. Call simulateDiceDuelMatch(player1, player2, sides, num_dice)
%          c. Store match result in round_matches(i)
%       5. Return struct array of all match results
%
%   Edge Cases:
%       - Empty players: throw Arcade:InvalidArgument
%       - Odd number of players: still processes remaining pairs
%       - Single player: returns empty struct array
%
%   Complexity: O(n/2) = O(n) time, O(n) space for n = number of players
%
%   Examples:
%       resolveDiceDuelRound({'Alice', 'Bob', 'Charlie', 'Diana'})
%       resolveDiceDuelRound({'Alice', 'Bob'}, 10, 2)
%
%   See also simulateDiceDuelMatch, playDiceDuelTournament

if ~iscell(players) || isempty(players)
    error('Arcade:InvalidArgument', ...
        'RESOLVEDICEDUELROUND requires a non-empty cell array');
end

if nargin < 2
    sides = 6;
end
if nargin < 3
    num_dice = 1;
end

num_players = length(players);
num_matches = nchoosek(num_players, 2);

round_matches = struct('player1', cell(1, num_matches), ...
    'player2', cell(1, num_matches), ...
    'roll1', cell(1, num_matches), ...
    'roll2', cell(1, num_matches), ...
    'winner', cell(1, num_matches), ...
    'points1', cell(1, num_matches), ...
    'points2', cell(1, num_matches));

idx = 1;
for i = 1:num_players
    for j = i+1:num_players
        match_result = simulateDiceDuelMatch(players{i}, players{j}, sides, num_dice);
        round_matches(idx) = match_result;
        idx = idx + 1;
    end
end
end