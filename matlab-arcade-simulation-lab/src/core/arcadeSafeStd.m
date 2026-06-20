function s = arcadeSafeStd(x)
%ARADESAFESTD  Compute standard deviation ignoring NaN values
%   s = arcadeSafeStd(x) returns the sample standard deviation of all
%   non-NaN elements in array x. If fewer than 2 non-NaN elements exist,
%   returns NaN.
%
%   Examples:
%       arcadeSafeStd([1, 2, 3, NaN])  -> 1
%       arcadeSafeStd([1])             -> NaN
%
%   See also arcadeSafeMean, nanstd

% Remove NaN values
x_clean = x(~isnan(x));

% Compute standard deviation
if length(x_clean) < 2
    s = NaN;
else
    s = std(x_clean);
end
end