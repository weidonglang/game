function round_matches = scoreDiceDuelRound(players, sides, num_dice)
%SCOREDICEDUELROUND  Simulate a full round pairings for dice duel
%   round_matches = scoreDiceDuelRound(players, sides, num_dice)
%   pairs up all players and simulates matches between each pair for one
%   round of a dice duel tournament.
%
%   Input:
%       players  - cell array of player name strings (even number)
%       sides    - number of sides on each die (passed to rollDicePool)
%       num_dice - number of dice per player (passed to rollDicePool)
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
%          b. Call rollDicePool(player1, player2, sides, num_dice)
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
%       scoreDiceDuelRound({'Alice', 'Bob', 'Charlie', 'Diana'})
%       scoreDiceDuelRound({'Alice', 'Bob'}, 10, 2)
%
%   See also rollDicePool, playDiceDuel

if ~iscell(players) || isempty(players)
    error('Arcade:InvalidArgument', ...
        'SCOREDICEDUELROUND requires a non-empty cell array');
end

if nargin < 2
    sides = 6;
end
if nargin < 3
    num_dice = 1;
end

num_players = length(players);
num_matches = floor(num_players / 2);

round_matches = struct('player1', cell(1, num_matches), ...
    'player2', cell(1, num_matches), ...
    'roll1', cell(1, num_matches), ...
    'roll2', cell(1, num_matches), ...
    'winner', cell(1, num_matches), ...
    'points1', cell(1, num_matches), ...
    'points2', cell(1, num_matches));

for i = 1:num_matches
    p1 = players{2*i - 1};
    p2 = players{2*i};
    match_result = rollDicePool(p1, p2, sides, num_dice);
    round_matches(i) = match_result;
end
end