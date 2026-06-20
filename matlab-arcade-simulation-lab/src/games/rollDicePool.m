function result = rollDicePool(player1, player2, sides, num_dice)
%ROLLDICEPOOL  Simulate a single dice duel between two players
%   result = rollDicePool(player1, player2, sides, num_dice)
%   simulates a dice duel where each player rolls a die and the higher
%   roll wins. Ties result in a draw.
%
%   Input:
%       player1  - name of first player (string)
%       player2  - name of second player (string)
%       sides    - number of sides on each die (default 6)
%       num_dice - number of dice per player (default 1)
%
%   Output:
%       result  - struct with fields:
%           result.player1   - name of first player
%           result.player2   - name of second player
%           result.roll1     - first player's roll total
%           result.roll2     - second player's roll total
%           result.winner    - name of winner, or 'Draw'
%           result.points1   - points awarded to player1 (1 for win, 0.5 for draw)
%           result.points2   - points awarded to player2
%
%   Algorithm:
%       1. Parse optional arguments: sides default 6, num_dice default 1
%       2. Validate both player names are character strings
%       3. Player 1 rolls: roll1 = arcadeDiceRoll(sides, num_dice)
%       4. Player 2 rolls: roll2 = arcadeDiceRoll(sides, num_dice)
%       5. Compare rolls:
%          a. roll1 > roll2  -> winner = player1, points1=1, points2=0
%          b. roll2 > roll1  -> winner = player2, points1=0, points2=1
%          c. roll1 == roll2 -> winner = 'Draw', points1=0.5, points2=0.5
%       6. Build and return result struct with all fields
%
%   Edge Cases:
%       - nargin < 3 or empty sides: default to 6
%       - nargin < 4 or empty num_dice: default to 1
%       - player1 non-string: throw Arcade:InvalidArgument
%       - player2 non-string: throw Arcade:InvalidArgument
%       - sides > 1e6: arcadeDiceRoll handles large values
%       - num_dice = 0: arcadeDiceRoll returns 0
%
%   Complexity: O(1) time, O(1) space
%
%   Examples:
%       rollDicePool('Alice', 'Bob')
%       rollDicePool('Alice', 'Bob', 20)
%       rollDicePool('Alice', 'Bob', 6, 2)
%
%   See also scoreDiceDuelRound, playDiceDuel

if nargin < 3 || isempty(sides)
    sides = 6;
end
if nargin < 4 || isempty(num_dice)
    num_dice = 1;
end

if ~ischar(player1) || ~ischar(player2)
    error('Arcade:InvalidArgument', ...
        'ROLLDICEPOOL requires string player names');
end

% Each player rolls
roll1 = arcadeDiceRoll(sides, num_dice);
roll2 = arcadeDiceRoll(sides, num_dice);

% Determine winner
if roll1 > roll2
    winner = player1;
    points1 = 1;
    points2 = 0;
elseif roll2 > roll1
    winner = player2;
    points1 = 0;
    points2 = 1;
else
    winner = 'Draw';
    points1 = 0.5;
    points2 = 0.5;
end

% Build result struct
result.player1 = player1;
result.player2 = player2;
result.roll1 = roll1;
result.roll2 = roll2;
result.winner = winner;
result.points1 = points1;
result.points2 = points2;
end