function tournament_results = playCoinFlip(num_players, num_rounds)
%PLAYCOINFLIP  Run a multi-round coin flip tournament
%   tournament_results = playCoinFlip(num_players, num_rounds) runs a
%   complete coin flip tournament where players are paired up each round.
%
%   Input:
%       num_players - number of players (default 4, must be even)
%       num_rounds  - number of rounds to play (default 10)
%
%   Output:
%       tournament_results - struct from summarizeCoinFlip with added fields:
%           .all_rounds - cell array of all round data
%           .players    - cell array of player names
%
%   Algorithm:
%       1. Parse optional arguments (defaults: 4 players, 10 rounds)
%       2. Validate inputs (num_players must be even, >= 2; num_rounds >= 1)
%       3. Build player names via buildCoinFlip(num_players)
%       4. For round r = 1..num_rounds:
%          a. Shuffle players via arcadeShuffle
%          b. Call simulateCoinFlipRound to pair and simulate
%          c. Store round results
%       5. Call summarizeCoinFlip with all rounds
%       6. Add extra fields and return
%
%   Edge Cases:
%       - nargin < 1: default to 4 players
%       - nargin < 2: default to 10 rounds
%       - Odd num_players: last player sits out (handled by simulateCoinFlipRound)
%       - num_players < 2: throw error
%       - num_rounds < 1: throw error
%
%   Complexity: O(r * n) time for r rounds, n players; O(r * n) space
%
%   Examples:
%       playCoinFlip()
%       playCoinFlip(6, 20)
%
%   See also buildCoinFlip, simulateCoinFlipRound, summarizeCoinFlip

if nargin < 1 || isempty(num_players)
    num_players = 4;
end
if nargin < 2 || isempty(num_rounds)
    num_rounds = 10;
end

if num_players < 2
    error('Arcade:InvalidArgument', ...
        'PLAYCOINFLIP requires num_players >= 2');
end
if num_rounds < 1
    error('Arcade:InvalidArgument', ...
        'PLAYCOINFLIP requires num_rounds >= 1');
end

% Build players
players = buildCoinFlip(num_players);

% Run rounds
all_rounds = cell(1, num_rounds);
for r = 1:num_rounds
    shuffled_players = arcadeShuffle(players);
    all_rounds{r} = simulateCoinFlipRound(shuffled_players);
end

% Summarize
summary = summarizeCoinFlip(all_rounds, players);
summary.all_rounds = all_rounds;
summary.players = players;
tournament_results = summary;
end