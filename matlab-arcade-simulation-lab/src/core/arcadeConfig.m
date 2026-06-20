function cfg = arcadeConfig(varargin)
%ARADECONFIG  Create default configuration for MATLAB Arcade Simulation Lab
%   cfg = arcadeConfig() returns a struct with default configuration
%   parameters used across all simulation modules.
%
%   cfg = arcadeConfig('verbose', false, 'max_iterations', 100) allows
%   overriding any default fields with custom key-value pairs.
%
%   Fields:
%       seed           - Random seed (default: [])
%       num_players    - Number of players per game
%       num_rounds     - Number of rounds per tournament
%       verbose        - Verbosity level (0=silent, 1=normal, 2=debug)
%       output_file    - Output file path (default: '')
%       save_results   - Whether to save results to file
%       demo_mode      - Whether to run in demo mode with fixed seed
%
%   See also arcadeSeed

cfg = struct();
cfg.seed = [];
cfg.num_players = 4;
cfg.num_rounds = 100;
cfg.verbose = 1;
cfg.output_file = '';
cfg.save_results = false;
cfg.demo_mode = false;

% Override with custom key-value pairs
for i = 1:2:length(varargin)-1
    key = varargin{i};
    value = varargin{i+1};
    cfg.(key) = value;
end

% Validate the configuration
if ~isempty(cfg.seed)
    assert(isnumeric(cfg.seed) && isscalar(cfg.seed) && cfg.seed >= 0, ...
        'Seed must be a non-negative numeric scalar');
end
assert(cfg.num_players >= 2, 'num_players must be at least 2');
assert(cfg.num_rounds >= 1, 'num_rounds must be at least 1');
assert(cfg.verbose >= 0 && cfg.verbose <= 2, 'verbose must be 0, 1, or 2');
end
