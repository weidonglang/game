function result = arcadeCoinFlip()
%ARADECOINFLIP  Simulate flipping a fair coin
%   result = arcadeCoinFlip() returns 'heads' or 'tails' with equal
%   probability using a random number generator.
%
%   Examples:
%       arcadeCoinFlip()        -> 'heads'
%       arcadeCoinFlip()        -> 'tails'
%
%   See also arcadeRandomChoice, arcadeDiceRoll, arcadeSeed

result = arcadeRandomChoice({'heads', 'tails'});
end