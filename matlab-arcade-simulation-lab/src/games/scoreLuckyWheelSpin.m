function score = scoreLuckyWheelSpin(spin_result, bet_amount)
%SCORELUCKYWHEELSPIN  Calculate points scored from a lucky wheel spin
%   score = scoreLuckyWheelSpin(spin_result, bet_amount) computes the
%   points earned based on the wheel section landed on and the bet amount.
%
%   Input:
%       spin_result - struct from spinLuckyWheel with fields:
%           .section - section name string
%           .prize   - numeric prize value
%       bet_amount  - numeric bet amount (default 100)
%
%   Output:
%       score - numeric score = prize * (bet_amount / 100)
%               For Bankrupt (prize=-1): score = -bet_amount
%               For Lose a Turn (prize=0): score = 0
%
%   Algorithm:
%       1. Validate spin_result is a struct with section and prize fields
%       2. Default bet_amount to 100 if not provided
%       3. score = spin_result.prize * (bet_amount / 100)
%       4. Return score
%
%   Edge Cases:
%       - nargin < 1: throw error
%       - nargin < 2 or empty bet_amount: default to 100
%       - bet_amount <= 0: throw error
%
%   Complexity: O(1) time, O(1) space
%
%   Examples:
%       sr.section = '20'; sr.prize = 20;
%       scoreLuckyWheelSpin(sr, 100) -> 20
%
%   See also spinLuckyWheel, playLuckyWheelTournament

if nargin < 1 || isempty(spin_result)
    error('Arcade:InvalidArgument', ...
        'SCORELUCKYWHEELSPIN requires a spin_result struct');
end

if ~isstruct(spin_result) || ~isfield(spin_result, 'prize') || ~isfield(spin_result, 'section')
    error('Arcade:InvalidArgument', ...
        'SCORELUCKYWHEELSPIN requires spin_result with section and prize fields');
end

if nargin < 2 || isempty(bet_amount)
    bet_amount = 100;
end

if ~isnumeric(bet_amount) || ~isscalar(bet_amount) || bet_amount < 0
    error('Arcade:InvalidArgument', ...
        'SCORELUCKYWHEELSPIN requires a non-negative bet_amount');
end

% Bankrupt: lose entire bet
if strcmpi(spin_result.section, 'Bankrupt')
    score = -bet_amount;
else
    score = spin_result.prize * (bet_amount / 100);
end
end