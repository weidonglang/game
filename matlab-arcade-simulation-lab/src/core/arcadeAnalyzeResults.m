function stats = arcadeAnalyzeResults(scores, labels)
%ARADEANALYZERESULTS  Compute summary statistics for simulation results
%   stats = arcadeAnalyzeResults(scores, labels) returns a struct with
%   summary statistics for the given scores. Labels is an optional cell
%   array for labeling the data groups.
%
%   Returns struct fields:
%       stats.mean     - mean score (NaN-safe)
%       stats.std      - standard deviation (NaN-safe)
%       stats.min      - minimum score
%       stats.max      - maximum score
%       stats.median   - median score
%       stats.range    - max - min
%       stats.count    - number of non-NaN values
%       stats.label    - label string (if provided)
%       stats.ci_lower - 95% confidence interval lower bound
%       stats.ci_upper - 95% confidence interval upper bound
%
%   Examples:
%       arcadeAnalyzeResults([10, 20, 30, 40, 50])
%       arcadeAnalyzeResults([85, 92, 78], 'Player A')
%
%   See also arcadeSafeMean, arcadeSafeStd, arcadeScoreTable

if ~isnumeric(scores)
    error('Arcade:InvalidArgument', 'ANALYZERESULTS requires numeric scores');
end

if nargin < 2
    labels = {''};
end

% Remove NaN for statistics
clean_scores = scores(~isnan(scores));

stats.mean = arcadeSafeMean(scores);
stats.std = arcadeSafeStd(scores);
stats.count = length(clean_scores);

if isempty(clean_scores)
    stats.min = NaN;
    stats.max = NaN;
    stats.median = NaN;
    stats.range = NaN;
    stats.ci_lower = NaN;
    stats.ci_upper = NaN;
else
    stats.min = min(clean_scores);
    stats.max = max(clean_scores);
    stats.median = median(clean_scores);
    stats.range = stats.max - stats.min;
    
    % Approximate 95% confidence interval using normal assumption
    if stats.count > 1
        se = stats.std / sqrt(stats.count);
        stats.ci_lower = stats.mean - 1.96 * se;
        stats.ci_upper = stats.mean + 1.96 * se;
    else
        stats.ci_lower = stats.mean;
        stats.ci_upper = stats.mean;
    end
end

% Handle labels
if iscell(labels) && ~isempty(labels)
    stats.label = labels{1};
elseif ischar(labels)
    stats.label = labels;
else
    stats.label = '';
end
end