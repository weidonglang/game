function result = arcadeCompareGroups(group_a, group_b, labels)
%ARADECOMPAREGROUPS  Compare two groups of scores with statistics
%   result = arcadeCompareGroups(group_a, group_b, labels) performs a
%   comparison between two arrays of scores, computing mean, std, and
%   effect size for each group.
%
%   Returns struct with fields:
%       result.group_a - stats for group A
%       result.group_b - stats for group B
%       result.diff_mean - difference in means (A - B)
%       result.effect_size - Cohen's d effect size
%       result.ratio - ratio of means (A / B)
%
%   Examples:
%       arcadeCompareGroups([85,90,78], [70,75,80])
%       arcadeCompareGroups(randn(1,50)+5, randn(1,50), {'Control','Test'})
%
%   See also arcadeAnalyzeResults, arcadeSafeMean, arcadeSafeStd

if nargin < 1 || ~isnumeric(group_a)
    error('Arcade:InvalidArgument', 'COMPAREGROUPS requires numeric arrays');
end
if nargin < 2 || ~isnumeric(group_b)
    error('Arcade:InvalidArgument', 'COMPAREGROUPS requires two numeric arrays');
end
if nargin < 3
    labels = {'Group A', 'Group B'};
end

% Analyze each group
result.group_a = arcadeAnalyzeResults(group_a, labels{1});
result.group_b = arcadeAnalyzeResults(group_b, labels{2});

% Compute comparison metrics
result.diff_mean = result.group_a.mean - result.group_b.mean;

% Cohen's d effect size
pooled_std = sqrt((result.group_a.std^2 + result.group_b.std^2) / 2);
if pooled_std > 0
    result.effect_size = result.diff_mean / pooled_std;
else
    result.effect_size = 0;
end

% Ratio of means (handle zero denominator)
if result.group_b.mean ~= 0
    result.ratio = result.group_a.mean / result.group_b.mean;
else
    result.ratio = NaN;
end
end