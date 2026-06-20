function result = scoreCoinFlipGuess(guess, actual)
%SCORECOINFLIPGUESS  Score a single coin flip guess
%   result = scoreCoinFlipGuess(guess, actual) compares the player's guess
%   to the actual coin flip result and returns 1 for a correct guess or
%   0 for an incorrect guess.
%
%   Input:
%       guess  - player's guess ('heads' or 'tails')
%       actual - actual coin flip result ('heads' or 'tails')
%
%   Output:
%       result - 1 if correct, 0 if incorrect, NaN if invalid
%
%   Algorithm:
%       1. Validate inputs are present and non-empty
%       2. Validate both inputs are character strings
%       3. Normalize guess and actual via lower(strtrim())
%       4. Validate guess is 'heads' or 'tails'
%       5. Validate actual is 'heads' or 'tails'
%       6. If guess == actual -> return 1 (correct)
%       7. Else -> return 0 (incorrect)
%       8. Any validation failure -> return NaN
%
%   Edge Cases:
%       - nargin < 2: throw Arcade:InvalidArgument error
%       - guess not a string: return NaN
%       - actual not a string: return NaN
%       - guess is 'heads'/'tails' but with extra whitespace: trimmed
%       - guess is 'HEADS' (uppercase): normalized to 'heads'
%       - guess is invalid like 'heads!': catch by strcmp validation
%
%   Complexity: O(1) time, O(1) space
%
%   Examples:
%       scoreCoinFlipGuess('heads', 'heads')  -> 1
%       scoreCoinFlipGuess('heads', 'tails')  -> 0
%       scoreCoinFlipGuess('invalid', 'heads') -> NaN
%
%   See also playCoinFlipTournament, simulateCoinFlipRound

if nargin < 2
    error('Arcade:InvalidArgument', ...
        'SCORECOINFLIPGUESS requires guess and actual');
end

if ~ischar(guess) || ~ischar(actual)
    result = NaN;
    return;
end

guess_norm = lower(strtrim(guess));
actual_norm = lower(strtrim(actual));

% Map shorthand
switch guess_norm
    case 'h'
        guess_norm = 'heads';
    case 't'
        guess_norm = 'tails';
end
switch actual_norm
    case 'h'
        actual_norm = 'heads';
    case 't'
        actual_norm = 'tails';
end

% Validate guess
if ~any(strcmp(guess_norm, {'heads', 'tails'}))
    result = -1;
    return;
end

% Validate actual
if ~any(strcmp(actual_norm, {'heads', 'tails'}))
    result = -1;
    return;
end

if strcmp(guess_norm, actual_norm)
    result = 1;
else
    result = 0;
end
end