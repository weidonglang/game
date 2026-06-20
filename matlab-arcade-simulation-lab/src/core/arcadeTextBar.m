function bar = arcadeTextBar(progress, width)
%ARADETEXTBAR  Create a text-based progress bar string
%   bar = arcadeTextBar(progress, width) returns a formatted text
%   progress bar string. Progress is a value in [0,1]. Width is the
%   number of characters in the bar (default 20).
%
%   Examples:
%       arcadeTextBar(0.75)       -> '[=============       ] 75%'
%       arcadeTextBar(0.5, 10)    -> '[=====     ] 50%'
%
%   See also arcadeFormatPercent

if nargin < 2
    width = 20;
end

% Clamp progress to [0, 1]
progress = min(max(progress, 0), 1);

% Validate width
if ~isnumeric(width) || ~isscalar(width) || width < 1
    error('Arcade:InvalidArgument', 'TEXTBAR width must be a positive scalar');
end

% Calculate filled and empty characters
filled = round(progress * width);
empty = width - filled;

% Build the bar string
bar = sprintf('[%s%s] %s', ...
    repmat('=', 1, filled), ...
    repmat(' ', 1, empty), ...
    arcadeFormatPercent(progress));
end