function arcadeAssert(condition, message)
%ARADEASSERT  Assert with formatted error message
%   arcadeAssert(condition, message) throws an error with the given
%   message if condition is false. Similar to built-in assert() but
%   with consistent error formatting for the arcade framework.
%
%   Examples:
%       arcadeAssert(x > 0, 'x must be positive');
%       arcadeAssert(ischar(name), 'Name must be a string');
%
%   See also assert, arcadeValidateProbability

if ~condition
    if nargin < 2
        message = 'Assertion failed';
    end
    error('Arcade:AssertionFailed', 'ASSERT: %s', message);
end
end