function choice = arcadeRandomChoice(items)
%ARADERANDOMCHOICE  Pick a random element from a cell array
%   choice = arcadeRandomChoice(items) returns a single random element
%   from the cell array items. Each element has equal probability.
%
%   Examples:
%       arcadeRandomChoice({'heads', 'tails'})
%       arcadeRandomChoice({'rock', 'paper', 'scissors'})
%
%   See also arcadeWeightedChoice, arcadeSeed

if ~iscell(items) || isempty(items)
    error('Arcade:InvalidArgument', 'RANDOMCHOICE requires a non-empty cell array');
end

idx = randi(length(items));
choice = items{idx};
end