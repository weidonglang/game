function str = arcadeFormatScore(score)
%ARADEFORMATSCORE  Format a numeric score as a display string
%   str = arcadeFormatScore(score) converts a numeric score to a
%   formatted string with comma separators for large numbers.
%
%   Examples:
%       arcadeFormatScore(1234)     -> '1,234'
%       arcadeFormatScore(1000000)  -> '1,000,000'
%       arcadeFormatScore(42)       -> '42'
%
%   See also arcadeFormatPercent, arcadeScoreTable

if ~isnumeric(score) || ~isscalar(score)
    error('Arcade:InvalidArgument', 'FORMATSCORE requires a numeric scalar');
end

% Format with comma separators
str = sprintf('%d', round(score));

% Insert commas every three digits from the right
comma_positions = length(str)-3:-3:2;
for pos = comma_positions
    str = [str(1:pos-1) ',' str(pos:end)];
end
end