function tournament_results = playLuckyWheel(num_players, num_rounds)
%PLAYLUCKYWHEEL  Run a multi-round lucky wheel tournament
%   tournament_results = playLuckyWheel(num_players, num_rounds) runs a
%   complete lucky wheel tournament with multiple players and rounds.
%
%   Input:
%       num_players - number of players (default 4, must be >= 1)
%       num_rounds  - number of rounds to play (default 10, must be >= 1)
%
%   Output:
%       tournament_results - struct from summarizeLuckyWheel with fields:
%           .rounds     - number of rounds played
%           .scores     - final scores per player
%           .winner     - name of the winner
%           .table      - formatted score table
%           .all_rounds - cell array of all round data
%           .players    - cell array of player names
%
%   Algorithm:
%       1. Parse optional arguments (defaults: 4 players, 10 rounds)
%       2. Validate both inputs are >= 1
%       3. Build player names via buildLuckyWheel(num_players)
%       4. Initialize all_rounds cell array (1 x num_rounds)
%       5. For round r = 1..num_rounds:
%          a. For each player p = 1..num_players:
%             i.   Call spinLuckyWheel(player_name, 6) for one spin
%             ii.  Store spin result in round_data(p)
%          b. Store round_data in all_rounds{r}
%       6. Call summarizeLuckyWheel(all_rounds, players)
%       7. Add all_rounds and players to summary struct
%       8. Return completed tournament_results struct
%
%   Edge Cases:
%       - nargin < 1 or empty num_players: default to 4
%       - nargin < 2 or empty num_rounds: default to 10
%       - num_players < 1: throw Arcade:InvalidArgument error
%       - num_rounds < 1: throw Arcade:InvalidArgument error
%
%   Complexity: O(r * n) time for r rounds, n players; O(r * n) space
%
%   Examples:
%       playLuckyWheel()
%       playLuckyWheel(6, 20)
%
%   See also buildLuckyWheel, spinLuckyWheel, summarizeLuckyWheel

if nargin < 1 || isempty(num_players)
    num_players = 4;
end
if nargin < 2 || isempty(num_rounds)
    num_rounds = 10;
end

if num_players < 1
    error('Arcade:InvalidArgument', ...
        'PLAYLUCKYWHEEL requires num_players >= 1');
end
if num_rounds < 1
    error('Arcade:InvalidArgument', ...
        'PLAYLUCKYWHEEL requires num_rounds >= 1');
end

% Build players
players = buildLuckyWheel(num_players);

% Run rounds
all_rounds = cell(1, num_rounds);
for r = 1:num_rounds
    round_data = struct('player', cell(1, num_players), ...
        'section', cell(1, num_players), ...
        'prize', cell(1, num_players), ...
        'bank_before', cell(1, num_players), ...
        'bank_after', cell(1, num_players), ...
        'points', cell(1, num_players));
    for p = 1:num_players
        round_data(p) = spinLuckyWheel(players{p}, 6);
    end
    all_rounds{r} = round_data;
end

% Summarize and annotate
summary = summarizeLuckyWheel(all_rounds, players);
summary.all_rounds = all_rounds;
summary.players = players;
tournament_results = summary;
end