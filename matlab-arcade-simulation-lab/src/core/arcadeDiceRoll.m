function result = arcadeDiceRoll(sides, num_dice, modifier)
%ARADEDICEROLL  Simulate rolling one or more dice
%   result = arcadeDiceRoll(sides) rolls a single die with given sides.
%   result = arcadeDiceRoll(sides, num_dice) rolls multiple dice and
%       returns the sum.
%   result = arcadeDiceRoll(sides, num_dice, modifier) adds a modifier
%       to the sum (can be negative).
%
%   Examples:
%       arcadeDiceRoll(6)           -> single d6
%       arcadeDiceRoll(6, 2)        -> 2d6 sum
%       arcadeDiceRoll(20, 1, 5)    -> d20 + 5
%       arcadeDiceRoll(100)         -> d100 (percentage)
%
%   See also arcadeRandomChoice, arcadeClamp

if nargin < 1 || ~isnumeric(sides) || ~isscalar(sides) || sides < 2
    error('Arcade:InvalidArgument', 'DICEROLL requires sides >= 2');
end
if nargin < 2 || isempty(num_dice)
    num_dice = 1;
end
if nargin < 3 || isempty(modifier)
    modifier = 0;
end

if ~isnumeric(num_dice) || ~isscalar(num_dice) || num_dice < 1 || num_dice ~= round(num_dice)
    error('Arcade:InvalidArgument', 'Number of dice must be a positive integer');
end
if ~isnumeric(modifier) || ~isscalar(modifier)
    error('Arcade:InvalidArgument', 'Modifier must be a numeric scalar');
end

% Roll each die and sum
sides = round(sides);
total = 0;
for i = 1:num_dice
    total = total + randi(sides);
end

% Apply modifier
result = total + modifier;
end