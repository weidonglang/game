function m = arcadeSafeMean(x)
%ARADESAFEMEAN  Compute mean ignoring NaN values
%   m = arcadeSafeMean(x) returns the mean of all non-NaN elements in
%   array x. If all elements are NaN or x is empty, returns NaN.
%
%   Examples:
%       arcadeSafeMean([1, 2, 3, NaN])  -> 2
%       arcadeSafeMean([NaN, NaN])      -> NaN
%
%   See also arcadeSafeStd, nanmean

% Remove NaN values
x_clean = x(~isnan(x));

% Compute mean
if isempty(x_clean)
    m = NaN;
else
    m = mean(x_clean);
end
end