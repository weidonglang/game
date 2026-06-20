function players = buildDiceDuel(num_players)
%BUILDDICEDUEL  Build a cell array of player names for dice duel
%   players = buildDiceDuel(num_players) returns a cell array of
%   player names for a dice duel tournament.
%
%   Input:
%       num_players - number of players (positive integer >= 2, default 4)
%
%   Output:
%       players     - cell array of player name strings
%
%   Algorithm:
%       1. Validate that num_players is numeric, scalar, >= 2
%       2. Default to 4 players if nargin < 1 or empty
%       3. Round num_players to nearest integer via round()
%       4. Pre-allocate 1 x num_players cell array
%       5. Fill each cell sprintf('Challenger-%d', i) for i = 1..num_players
%       6. Return the filled cell array
%
%   Edge Cases:
%       - nargin < 1 or empty: default to 4
%       - num_players < 2: error('Arcade:InvalidArgument')
%       - non-numeric input: error
%       - non-scalar input: error
%       - fractional input: rounded to nearest int
%
%   Complexity: O(n) time, O(n) space for n = num_players
%
%   Examples:
%       buildDiceDuel(2)      -> {'Challenger-1', 'Challenger-2'}
%       buildDiceDuel()        -> {'Challenger-1', ..., 'Challenger-4'}
%
%   See also simulateDiceDuelMatch, resolveDiceDuelRound

if nargin < 1 || isempty(num_players)
    num_players = 4;
end

if ~isnumeric(num_players) || ~isscalar(num_players) || num_players < 2
    error('Arcade:InvalidArgument', ...
        'BUILDDICEDUEL requires num_players >= 2');
end

num_players = round(num_players);
players = cell(1, num_players);
for i = 1:num_players
    players{i} = sprintf('Challenger-%d', i);
end
end