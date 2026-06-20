function round_results = simulateCoinFlipRound(players)
%SIMULATECOINFLIPROUND  Simulate one round of coin flip for all players
%   round_results = simulateCoinFlipRound(players) simulates one round
%   where each player guesses 'heads' or 'tails' randomly and the coin is
%   flipped once. Returns a struct array with each player's guess, the
%   coin result, and their points.
%
%   Input:
%       players       - cell array of player name strings
%
%   Output:
%       round_results - struct array with fields: player, guess, coin_result, points
%
%   Algorithm:
%       1. Validate players is non-empty cell array
%       2. Flip a single coin using arcadeCoinFlip() for the round
%       3. Determine number of players n = length(players)
%       4. Pre-allocate struct array with fields player, guess, coin_result, points
%       5. For each player i = 1..n:
%          a. Generate random guess via arcadeRandomChoice({'heads','tails'})
%          b. Score guess vs coin_result via scoreCoinFlipGuess()
%          c. Store in round_results(i)
%       6. Return the struct array of round results
%
%   Edge Cases:
%       - Empty players cell array: throw Arcade:InvalidArgument
%       - Non-cell players input: error from ~iscell check
%       - Single player: works correctly (one entry in result)
%       - Players with empty names: allowed, processed normally
%
%   Complexity: O(n) time, O(n) space for n = number of players
%
%   Examples:
%       simulateCoinFlipRound({'Alice', 'Bob'})
%
%   See also playCoinFlipTournament, buildCoinFlipPlayers

if ~iscell(players) || isempty(players)
    error('Arcade:InvalidArgument', ...
        'SIMULATECOINFLIPROUND requires a non-empty cell array');
end

% Flip the coin once for this round
coin_result = arcadeCoinFlip();

n = length(players);
round_results = struct('player', cell(1, n), ...
    'guess', cell(1, n), ...
    'coin_result', cell(1, n), ...
    'points', cell(1, n));

for i = 1:n
    % Each player makes a random guess
    guess = arcadeRandomChoice({'heads', 'tails'});
    score_val = scoreCoinFlipGuess(guess, coin_result);
    round_results(i).player = players{i};
    round_results(i).guess = guess;
    round_results(i).coin_result = coin_result;
    round_results(i).points = score_val;
end
end
