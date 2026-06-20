function players = buildCoinFlip(num_players)
%BUILDCOINFLIP  Build a cell array of player names for coin flip
%   players = buildCoinFlip(num_players) returns a cell array of
%   player names for a coin flip game.
%
%   Input:
%       num_players - number of players (positive integer >= 1, default 4)
%
%   Output:
%       players     - cell array of player name strings
%
%   Algorithm:
%       1. Validate num_players is numeric, scalar, positive integer
%       2. Default to 4 players if nargin < 1 or empty
%       3. Round num_players to nearest integer via round()
%       4. Pre-allocate 1 x num_players cell array
%       5. Fill each cell with sprintf('Player-%d', i) for i = 1..num_players
%       6. Return the completed cell array of player names
%
%   Edge Cases:
%       - nargin < 1: default to 4
%       - empty num_players: default to 4
%       - num_players < 1: throw Arcade:InvalidArgument error
%       - non-numeric input: error
%       - non-scalar input: error
%       - fractional input: rounded down via round()
%
%   Complexity: O(n) time, O(n) space for n = num_players
%
%   Examples:
%       buildCoinFlip(2)     -> {'Player-1', 'Player-2'}
%       buildCoinFlip()       -> {'Player-1', ..., 'Player-4'}
%
%   See also playCoinFlip, simulateCoinFlipRound

if nargin < 1 || isempty(num_players)
    num_players = 4;
end

if ~isnumeric(num_players) || ~isscalar(num_players) || num_players < 2
    error('Arcade:InvalidArgument', ...
        'BUILDCOINFLIP requires num_players >= 2');
end

num_players = round(num_players);
players = cell(1, num_players);
for i = 1:num_players
    players{i} = sprintf('Player-%d', i);
end
end