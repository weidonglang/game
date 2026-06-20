function bar = arcadeTextBar(progress, width)
%ARADETEXTBAR  Create a text-based progress bar string
%   bar = arcadeTextBar(progress, width) returns a formatted text
%   progress bar string. Progress is a value in [0,1]. Width is the
%   number of characters in the bar.
%
%   Uses '#' for filled and '-' for empty characters.
%
%   Examples:
%       arcadeTextBar(1.0, 10)    -> '##########'
%       arcadeTextBar(0.5, 10)    -> '#####-----'
%       arcadeTextBar(0, 10)      -> '----------'
%
%   See also arcadeFormatPercent

if nargin < 2 || isempty(width)
    width = 20;
end

% Validate width
if ~isnumeric(width) || ~isscalar(width) || width < 1
    error('Arcade:InvalidArgument', 'TEXTBAR width must be a positive scalar');
end

% Calculate filled and empty characters
filled = round(min(max(progress, 0), 1) * width);
empty = width - filled;

% Build the bar string using # for filled and - for empty
bar = [repmat('#', 1, filled), repmat('-', 1, empty)];
end
