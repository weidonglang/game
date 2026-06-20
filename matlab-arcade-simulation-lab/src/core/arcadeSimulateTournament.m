function results = arcadeSimulateTournament(players, num_rounds, strategies)
%ARADESIMULATETOURNAMENT  Simulate a round-robin tournament
%   results = arcadeSimulateTournament(players, num_rounds, strategies)
%   simulates a tournament where each player plays every other player
%   for num_rounds rounds. Strategies is a cell array of function
%   handles defining each player's decision strategy.
%
%   Input:
%       players     - cell array of player names
%       num_rounds  - number of rounds per matchup (default 100)
%       strategies  - cell array of function handles (optional)
%
%   Output:
%       results     - struct with fields: matrix (scores), names, rounds
%
%   Examples:
%       arcadeSimulateTournament({'Alice','Bob','Carol'}, 50)
%
%   See also arcadeConfig, arcadeScoreTable

if nargin < 2 || isempty(num_rounds)
    num_rounds = 100;
end

if ~iscell(players) || isempty(players)
    error('Arcade:InvalidArgument', 'SIMULATETOURNAMENT requires a non-empty cell array of players');
end

if nargin < 3 || isempty(strategies)
    % Default: random strategies for each player
    strategies = cell(1, length(players));
    for i = 1:length(players)
        strategies{i} = @() arcadeRandomChoice({'cooperate', 'defect'});
    end
end

n = length(players);
if length(strategies) ~= n
    error('Arcade:InvalidArgument', 'Number of strategies must match number of players');
end

% Initialize score matrix (n x n), diagonal stays 0
score_matrix = zeros(n, n);

% Simulate each pair
for i = 1:n
    for j = i+1:n
        for round = 1:num_rounds
            % Each player makes a decision
            move_i = strategies{i}();
            move_j = strategies{j}();
            
            % Simple scoring: cooperate=1 point each, defect=0
            if strcmp(move_i, 'cooperate') && strcmp(move_j, 'cooperate')
                score_matrix(i, j) = score_matrix(i, j) + 1;
                score_matrix(j, i) = score_matrix(j, i) + 1;
            elseif strcmp(move_i, 'cooperate') && strcmp(move_j, 'defect')
                score_matrix(j, i) = score_matrix(j, i) + 3;
            elseif strcmp(move_i, 'defect') && strcmp(move_j, 'cooperate')
                score_matrix(i, j) = score_matrix(i, j) + 3;
            else
                % Both defect: each gets 0
            end
        end
    end
end

% Build results struct
results.matrix = score_matrix;
results.names = players;
results.rounds = num_rounds;
results.scores = sum(score_matrix, 2)';
results.table = arcadeScoreTable(players, results.scores);
end