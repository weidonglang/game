function arcadeSeed(seed)
%ARADESEED  Set the random seed for reproducible simulations
%   arcadeSeed(seed) sets the MATLAB random number generator to a
%   specific seed for reproducible results. If seed is empty or not
%   provided, the generator is reset to its default state.
%
%   Examples:
%       arcadeSeed(42)      % Fixed seed for reproducibility
%       arcadeSeed()        % Reset to default
%
%   See also rng, arcadeRandomChoice, arcadeWeightedChoice

if nargin < 1 || isempty(seed)
    rng('default');
else
    assert(isnumeric(seed) && isscalar(seed) && seed >= 0, ...
        'Seed must be a non-negative scalar');
    rng(seed, 'twister');
end
end