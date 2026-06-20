function str = arcadeFormatPercent(p)
%ARADEFORMATPERCENT  Format a probability as a percentage string
%   str = arcadeFormatPercent(p) converts a probability in [0,1] to a
%   formatted percentage string with one decimal place.
%
%   Examples:
%       arcadeFormatPercent(0.756)  -> '75.6%'
%       arcadeFormatPercent(1.0)    -> '100.0%'
%       arcadeFormatPercent(0.0)    -> '0.0%'
%
%   See also arcadeFormatScore, arcadeTextBar

% Clamp to [0, 1]
p = min(max(p, 0), 1);

% Format with one decimal place
str = sprintf('%.1f%%', p * 100);
end