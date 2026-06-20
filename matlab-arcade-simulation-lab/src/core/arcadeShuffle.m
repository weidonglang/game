function shuffled = arcadeShuffle(items)
%ARADESHUFFLE  Randomly shuffle the order of items in a cell array
%   shuffled = arcadeShuffle(items) returns a new cell array with the
%   same elements in random order. The original array is not modified.
%
%   Examples:
%       arcadeShuffle({'A','B','C','D'})
%       arcadeShuffle({'heads','tails','edge'})
%
%   See also arcadeRandomChoice, arcadeSeed

if ~iscell(items)
    error('Arcade:InvalidArgument', 'SHUFFLE requires a cell array');
end

n = length(items);

% Generate random permutation
indices = randperm(n);

% Reorder items
shuffled = items(indices);
end