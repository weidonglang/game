function normalized = arcadeNormalizeName(name)
%ARADENORMALIZENAME  Normalize a player or game name for consistent comparison
%   normalized = arcadeNormalizeName(name) converts the input name to
%   lowercase, strips leading/trailing whitespace, and removes any
%   non-alphanumeric characters except underscores and hyphens.
%
%   If the resulting string is empty, returns 'invalid'.
%
%   Examples:
%       arcadeNormalizeName('  HeAdS  ')   -> 'heads'
%       arcadeNormalizeName('TAILS')       -> 'tails'
%       arcadeNormalizeName('Player_One!') -> 'player_one'
%
%   See also arcadeValidateProbability

if ~ischar(name)
    error('Arcade:InvalidArgument', 'NORMALIZE requires a string input');
end

% Strip leading and trailing whitespace
normalized = strtrim(name);

% Convert to lowercase
normalized = lower(normalized);

% Remove non-alphanumeric characters except underscore and hyphen
keep_mask = isstrprop(normalized, 'alphanum') | (normalized == '_') | (normalized == '-');
normalized = normalized(keep_mask);

% If empty, return 'invalid'
if isempty(normalized)
    normalized = 'invalid';
end
end