function tbl = arcadeScoreTable(names, scores)
%ARADESCORETABLE  Build a formatted score table from names and scores
%   tbl = arcadeScoreTable(names, scores) creates a cell array table
%   with ranked scores. Names is a cell array of player names, scores
%   is a numeric array. Returns a cell array sorted by score descending.
%
%   Ties are assigned the same rank.
%
%   Examples:
%       arcadeScoreTable({'Alice','Bob'}, [100,200])
%
%   See also arcadeFormatScore, arcadeFormatPercent

if ~iscell(names) || ~isnumeric(scores)
    error('Arcade:InvalidArgument', 'SCORETABLE expects cell array names and numeric scores');
end
if length(names) ~= length(scores)
    error('Arcade:InvalidArgument', 'Names and scores must have the same length');
end
if isempty(names)
    error('Arcade:InvalidArgument', 'SCORETABLE requires non-empty names and scores');
end

% Sort by score descending
[sorted_scores, sort_idx] = sort(scores, 'descend');
sorted_names = names(sort_idx);

% Build table
n = length(sorted_names);
tbl = cell(n, 3);

rank = 1;
prev_score = sorted_scores(1);
for i = 1:n
    if i > 1 && sorted_scores(i) < prev_score
        rank = i;
    end
    prev_score = sorted_scores(i);
    tbl{i, 1} = sprintf('%d', rank);        % Rank
    tbl{i, 2} = sorted_names{i};             % Name
    tbl{i, 3} = sprintf('%d', sorted_scores(i));  % Score
end
end
