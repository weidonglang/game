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
%           .rounds       - number of rounds played
%           .scores       - final scores per player
%           .winner       - name of the winner
%           .table        - formatted score table
%           .bank_history - numeric array tracking bank per player over rounds
%           .all_rounds   - cell array of all round data
%           .players      - cell array of player names
%
%   Algorithm:
%       1. Parse optional arguments (defaults: 4 players, 10 rounds)
%       2. Validate both inputs are >= 1
%       3. Build player names via buildLuckyWheel(num_players)
%       4. Initialize all_rounds cell array (1 x num_rounds)
%       5. Initialize bank tracking array (num_rounds x num_players)
%       6. For round r = 1..num_rounds:
%          a. For each player p = 1..num_players:
%             i.   Call spinLuckyWheel() for a random spin
%             ii.  Compute bank_before and bank_after using scores
%             iii. Store spin result in round_data(p)
%          b. Store round_data in all_rounds{r}
%          c. Update bank_history
%       7. Call summarizeLuckyWheel(all_rounds, players)
%       8. Add all_rounds, players, and bank_history to summary struct
%       9. Return completed tournament_results struct
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

% Track bank per player
bank = zeros(1, num_players);
bank_history = zeros(num_rounds, num_players);

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
        % Spin wheel for this player
        spin_result = spinLuckyWheel();
        
        % Score the spin (default bet of 100)
        points = scoreLuckyWheelSpin(spin_result, 100);
        
        % Track bank
        bank_before = bank(p);
        bank(p) = bank(p) + points;
        bank_after = bank(p);
        
        round_data(p).player = players{p};
        round_data(p).section = spin_result.section;
        round_data(p).prize = spin_result.prize;
        round_data(p).bank_before = bank_before;
        round_data(p).bank_after = bank_after;
        round_data(p).points = points;
    end
    all_rounds{r} = round_data;
    bank_history(r, :) = bank;
end

% Summarize and annotate
summary = summarizeLuckyWheel(all_rounds, players);
summary.all_rounds = all_rounds;
summary.players = players;
summary.bank_history = bank_history;
tournament_results = summary;
end