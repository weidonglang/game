function choice = arcadeWeightedChoice(items, weights)
%ARADEWEIGHTEDCHOICE  Pick a random element using weighted probabilities
%   choice = arcadeWeightedChoice(items, weights) returns a random
%   element from the cell array items, where the probability of each
%   item is proportional to its corresponding weight in the numeric
%   array weights. Weights are normalized to sum to 1 internally.
%
%   Examples:
%       arcadeWeightedChoice({'A','B','C'}, [0.1, 0.3, 0.6])
%
%   See also arcadeRandomChoice, arcadeValidateProbability

if ~iscell(items) || ~isnumeric(weights)
    error('Arcade:InvalidArgument', 'WEIGHTEDCHOICE expects cell array items and numeric weights');
end
if length(items) ~= length(weights)
    error('Arcade:InvalidArgument', 'Items and weights must have the same length');
end
if isempty(items)
    error('Arcade:InvalidArgument', 'Items must not be empty');
end
if any(weights < 0)
    error('Arcade:InvalidArgument', 'Weights must be non-negative');
end
if sum(weights) == 0
    error('Arcade:InvalidArgument', 'Sum of weights must be positive');
end

% Normalize weights to probabilities
probs = weights / sum(weights);

% Generate cumulative distribution
cumulative = cumsum(probs);

% Pick random number and find corresponding item
r = rand();
idx = find(r <= cumulative, 1, 'first');
choice = items{idx};
end