function result = spinLuckyWheel(sections)
%SPINLUCKYWHEEL  Simulate a spin of the lucky wheel
%   result = spinLuckyWheel(sections) randomly selects a section
%   from the provided sections list and returns the section name and prize.
%
%   Input:
%       sections - cell array of section name strings (default standard 10-section wheel)
%                  Special sections: 'Bankrupt' -> prize = -1
%                                    'Lose a Turn' -> prize = 0
%                  Numeric sections (e.g. '20') -> prize = str2double(section)
%
%   Output:
%       result - struct with fields:
%           .section - name of the landed section (string)
%           .prize   - numeric prize value
%
%   Algorithm:
%       1. If nargin < 1, use default 10-section wheel
%       2. If sections is empty, error
%       3. Validate sections is a cell array of strings
%       4. Pick random section using randi
%       5. Compute prize: try str2double, or -1 for 'Bankrupt', or 0 for 'Lose a Turn'
%       6. Return result struct
%
%   Edge Cases:
%       - nargin < 1: default to standard 10-section wheel
%       - Empty sections: throw Arcade:InvalidArgument
%       - Non-cell input: throw Arcade:InvalidArgument
%       - Unknown section: prize = 0
%
%   Complexity: O(1) time, O(1) space
%
%   Examples:
%       spinLuckyWheel()                 % uses default sections
%       spinLuckyWheel({'10', '20', 'Bankrupt'})
%
%   See also scoreLuckyWheelSpin, playLuckyWheelTournament

if nargin < 1
    sections = {'5', '10', '15', '20', '25', '30', ...
        '35', '40', 'Bankrupt', 'Lose a Turn'};
end

if ~iscell(sections)
    error('Arcade:InvalidArgument', ...
        'SPINLUCKYWHEEL requires a cell array of section names');
end

if isempty(sections)
    error('Arcade:InvalidArgument', ...
        'SPINLUCKYWHEEL requires a non-empty cell array of section names');
end

% Pick random section
idx = randi(length(sections));
section_name = sections{idx};

% Compute prize value
prize = str2double(section_name);
if isnan(prize)
    if strcmpi(section_name, 'Bankrupt')
        prize = -1;
    elseif strcmpi(section_name, 'Lose a Turn')
        prize = 0;
    else
        prize = 0;
    end
end

result.section = section_name;
result.prize = prize;
end