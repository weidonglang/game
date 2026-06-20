function valid = arcadeValidateProbability(p)
%ARADEVALIDATEPROBABILITY  Validate that a value is a valid probability
%   valid = arcadeValidateProbability(p) returns true if p is a numeric
%   scalar in the range [0, 1]. Returns false otherwise.
%
%   Examples:
%       arcadeValidateProbability(0.5)   -> true
%       arcadeValidateProbability(1.5)   -> false
%       arcadeValidateProbability(-0.1)  -> false
%
%   See also arcadeClamp, arcadeAssert

valid = isnumeric(p) && isscalar(p) && isreal(p) && p >= 0 && p <= 1;
end