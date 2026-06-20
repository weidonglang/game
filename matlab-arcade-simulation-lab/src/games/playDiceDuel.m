function tournament_results = playDiceDuel(num_players, num_rounds, sides, num_dice)
%PLAYDICEDUEL  Organize and run a multi-round dice duel tournament
%   tournament_results = playDiceDuel(num_players, num_rounds, sides, num_dice)
%   runs a complete dice duel tournament with pairings each round.
%
%   Input:
%       num_players - number of players (default 4, must be even)
%       num_rounds  - number of rounds to play (default 5)
%       sides       - number of sides per die (default 6)
%       num_dice    - number of dice per player (default 1)
%
%   Output:
%       tournament_results - struct with fields:
%           .summary  - summary struct from summarizeDiceDuel
%           .players  - cell array of player names
%           .rounds   - number of rounds played
%
%   Algorithm:
%       1. Parse optional arguments (defaults: 4 players, 5 rounds, 6 sides, 1 die)
%       2. Validate num_rounds >= 1
%       3. Build player names via buildDiceDuelPlayers(num_players)
%       4. Initialize all_rounds cell array
%       5. For round r = 1..num_rounds:
%          a. Shuffle player order via arcadeShuffle(players) for variety
%          b. Call scoreDiceDuelRound(shuffled_players, sides, num_dice)
%          c. Store match data in all_rounds{r}
%       6. Call summarizeDiceDuel(all_rounds, players)
%       7. Build and return tournament_results struct
%
%   Edge Cases:
%       - nargin < 1 or empty num_players: default to 4
%       - nargin < 2 or empty num_rounds: default to 5
%       - num_rounds < 1: throw Arcade:InvalidArgument error
%
%   Complexity: O(r * n) time for r rounds, n players; O(r * n) space
%
%   Examples:
%       playDiceDuel()
%       playDiceDuel(6, 10, 20, 1)
%
%   See also scoreDiceDuelRound, summarizeDiceDuel

if nargin < 1 || isempty(num_players)
    num_players = 4;
end
if nargin < 2 || isempty(num_rounds)
    num_rounds = 10;
end
if nargin < 3 || isempty(sides)
    sides = 6;
end
if nargin < 4 || isempty(num_dice)
    num_dice = 1;
end

if num_rounds < 1
    error('Arcade:InvalidArgument', ...
        'PLAYDICEDUEL requires num_rounds >= 1');
end

% Build players
players = buildDiceDuel(num_players);

% Run rounds
all_rounds = cell(1, num_rounds);
for r = 1:num_rounds
    % Shuffle player order each round for variety
    shuffled_players = arcadeShuffle(players);
    all_rounds{r} = scoreDiceDuelRound(shuffled_players, sides, num_dice);
end

% Summarize
summary = summarizeDiceDuel(all_rounds, players);

% Build output
summary.all_rounds = all_rounds;
summary.players = players;
tournament_results = summary;
end