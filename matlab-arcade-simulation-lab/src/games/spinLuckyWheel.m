function result = spinLuckyWheel(sections)
%SPINLUCKYWHEEL  Spin a lucky wheel and return the winning section
%   result = spinLuckyWheel(sections) randomly selects a section from the
%   wheel and returns details about the result.
%
%   Input:
%       sections - cell array of section name strings (default: 3 sections)
%                  e.g. {'10', '20', 'Bankrupt'}
%
%   Output:
%       result - struct with fields:
%           .section - string label of the winning section
%           .prize   - numeric prize value (parsed from numeric strings)
%                      'Bankrupt' -> -1, 'Lose a Turn' -> 0
%
%   Algorithm:
%       1. Default sections = {'10', '20', '50', '100', 'Bankrupt', 'Lose a Turn'}
%       2. Validate sections is a non-empty cell array of strings
%       3. Randomly select a section index using randi
%       4. Parse prize: if section is numeric string -> str2double, 'Bankrupt' -> -1, else -> 0
%       5. Build and return result struct with section and prize
%
%   Edge Cases:
%       - nargin < 1 or empty: use default 6 sections
%       - Single section: always returns that section
%
%   Complexity: O(1) time, O(1) space
%
%   Examples:
%       spinLuckyWheel()
%       spinLuckyWheel({'10', '20', 'Bankrupt'})
%
%   See also scoreLuckyWheelSpin, playLuckyWheelTournament

if nargin < 1 || isempty(sections)
    sections = {'10', '20', '50', '100', 'Bankrupt', 'Lose a Turn'};
end

if ~iscell(sections) || isempty(sections)
    error('Arcade:InvalidArgument', ...
        'SPINLUCKYWHEEL requires a non-empty cell array of sections');
end

% Randomly select a section
n_sections = length(sections);
if n_sections == 1
    idx = 1;
else
    idx = randi(n_sections);
end

section_name = sections{idx};

% Parse prize value
if ~isempty(regexp(section_name, '^-?\d+(\.\d+)?$', 'once'))
    prize = str2double(section_name);
elseif strcmpi(section_name, 'Bankrupt')
    prize = -1;
elseif strcmpi(section_name, 'Lose a Turn')
    prize = 0;
else
    prize = 0;
end

result.section = section_name;
result.prize = prize;
end