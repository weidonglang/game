function clamped = arcadeClamp(value, lo, hi)
%ARADECLAMP  Clamp a value between lower and upper bounds
%   clamped = arcadeClamp(value, lo, hi) returns value constrained to
%   the range [lo, hi]. If value < lo, returns lo. If value > hi,
%   returns hi. Otherwise returns value unchanged.
%
%   Examples:
%       arcadeClamp(5, 0, 10)   -> 5
%       arcadeClamp(-1, 0, 10)  -> 0
%       arcadeClamp(15, 0, 10)  -> 10
%
%   See also arcadeSafeMean, arcadeValidateProbability

% Validate inputs
if nargin < 3
    error('Arcade:InvalidArgument', 'CLAMP requires three arguments: value, lo, hi');
end
if ~isnumeric(value) || ~isnumeric(lo) || ~isnumeric(hi)
    error('Arcade:InvalidArgument', 'CLAMP requires numeric arguments');
end
if lo > hi
    error('Arcade:InvalidArgument', 'Lower bound must not exceed upper bound');
end

% Perform clamping
clamped = min(max(value, lo), hi);
end