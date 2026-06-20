function tests = testGamesPackA
%TESTGAMESPACKA  Unit tests for Arcade Games Pack A
%   tests = testGamesPackA runs all unit tests for Coin Flip Tournament,
%   Dice Duel, and Lucky Wheel tournaments.
%
%   See also run_all_tests

tests = functiontests(localfunctions);
end

% =========================================================================
% Coin Flip Tournament Tests
% =========================================================================

function testBuildCoinFlipDefault(testCase)
players = buildCoinFlip();
verifyEqual(testCase, length(players), 4);
verifyTrue(testCase, iscell(players));
verifyEqual(testCase, players{1}, 'Player-1');
verifyEqual(testCase, players{4}, 'Player-4');
end

function testBuildCoinFlipCustom(testCase)
players = buildCoinFlip(6);
verifyEqual(testCase, length(players), 6);
verifyEqual(testCase, players{1}, 'Player-1');
verifyEqual(testCase, players{6}, 'Player-6');
end

function testBuildCoinFlipError(testCase)
verifyError(testCase, @() buildCoinFlip(1), 'Arcade:InvalidArgument');
verifyError(testCase, @() buildCoinFlip(0), 'Arcade:InvalidArgument');
verifyError(testCase, @() buildCoinFlip(-1), 'Arcade:InvalidArgument');
end

function testScoreCoinFlipGuessHeads(testCase)
verifyEqual(testCase, scoreCoinFlipGuess('heads', 'heads'), 1);
verifyEqual(testCase, scoreCoinFlipGuess('Heads', 'heads'), 1);
verifyEqual(testCase, scoreCoinFlipGuess('HEADS', 'heads'), 1);
verifyEqual(testCase, scoreCoinFlipGuess(' h ', 'heads'), 1);
end

function testScoreCoinFlipGuessTails(testCase)
verifyEqual(testCase, scoreCoinFlipGuess('tails', 'tails'), 1);
verifyEqual(testCase, scoreCoinFlipGuess('Tails', 'tails'), 1);
verifyEqual(testCase, scoreCoinFlipGuess('TAILS', 'tails'), 1);
verifyEqual(testCase, scoreCoinFlipGuess(' t ', 'tails'), 1);
end

function testScoreCoinFlipGuessWrong(testCase)
verifyEqual(testCase, scoreCoinFlipGuess('heads', 'tails'), 0);
verifyEqual(testCase, scoreCoinFlipGuess('tails', 'heads'), 0);
end

function testScoreCoinFlipGuessInvalid(testCase)
verifyEqual(testCase, scoreCoinFlipGuess('invalid', 'heads'), -1);
verifyEqual(testCase, scoreCoinFlipGuess('x', 'tails'), -1);
verifyEqual(testCase, scoreCoinFlipGuess('', 'heads'), -1);
end

function testSimulateCoinFlipRoundStructure(testCase)
players = buildCoinFlip(3);
round_data = simulateCoinFlipRound(players);
verifyEqual(testCase, length(round_data), 3);
for i = 1:3
    verifyTrue(testCase, isfield(round_data(i), 'player'));
    verifyTrue(testCase, isfield(round_data(i), 'guess'));
    verifyTrue(testCase, isfield(round_data(i), 'coin_result'));
    verifyTrue(testCase, isfield(round_data(i), 'points'));
    verifyTrue(testCase, ismember(round_data(i).coin_result, {'heads', 'tails'}));
    verifyTrue(testCase, ismember(round_data(i).points, [-1, 0, 1]));
end
end

function testSimulateCoinFlipRoundPlayerNames(testCase)
players = {'Alice', 'Bob'};
round_data = simulateCoinFlipRound(players);
verifyEqual(testCase, round_data(1).player, 'Alice');
verifyEqual(testCase, round_data(2).player, 'Bob');
end

function testSummarizeCoinFlipBasic(testCase)
players = buildCoinFlip(3);
all_rounds = cell(1, 2);
for r = 1:2
    all_rounds{r} = simulateCoinFlipRound(players);
end
summary = summarizeCoinFlip(all_rounds, players);
verifyEqual(testCase, summary.rounds, 2);
verifyEqual(testCase, length(summary.scores), 3);
verifyTrue(testCase, ischar(summary.winner));
verifyTrue(testCase, ischar(summary.table));
end

function testSummarizeCoinFlipDeterministic(testCase)
players = {'Alice', 'Bob'};
round_data(1).player = 'Alice'; round_data(1).guess = 'heads';
round_data(1).coin_result = 'heads'; round_data(1).points = 1;
round_data(2).player = 'Bob'; round_data(2).guess = 'heads';
round_data(2).coin_result = 'tails'; round_data(2).points = 0;
all_rounds = {round_data};
summary = summarizeCoinFlip(all_rounds, players);
verifyEqual(testCase, summary.scores(1), 1);
verifyEqual(testCase, summary.scores(2), 0);
end

function testPlayCoinFlipDefault(testCase)
summary = playCoinFlip();
verifyEqual(testCase, summary.rounds, 10);
verifyEqual(testCase, length(summary.scores), 4);
end

function testPlayCoinFlipCustom(testCase)
summary = playCoinFlip(3, 5);
verifyEqual(testCase, summary.rounds, 5);
verifyEqual(testCase, length(summary.scores), 3);
end

% =========================================================================
% Dice Duel Tests
% =========================================================================

function testBuildDiceDuelDefault(testCase)
players = buildDiceDuel();
verifyEqual(testCase, length(players), 4);
verifyEqual(testCase, players{1}, 'Challenger-1');
verifyEqual(testCase, players{4}, 'Challenger-4');
end

function testBuildDiceDuelCustom(testCase)
players = buildDiceDuel(6);
verifyEqual(testCase, length(players), 6);
end

function testBuildDiceDuelError(testCase)
verifyError(testCase, @() buildDiceDuel(1), 'Arcade:InvalidArgument');
end

function testSimulateDiceDuelMatchBasic(testCase)
match = simulateDiceDuelMatch('Alice', 'Bob', 6, 1);
verifyEqual(testCase, match.player1, 'Alice');
verifyEqual(testCase, match.player2, 'Bob');
verifyTrue(testCase, isfield(match, 'roll1'));
verifyTrue(testCase, isfield(match, 'roll2'));
verifyTrue(testCase, isfield(match, 'winner'));
verifyTrue(testCase, isfield(match, 'points1'));
verifyTrue(testCase, isfield(match, 'points2'));
verifyTrue(testCase, ismember(match.winner, {'Alice', 'Bob', 'Draw'}));
verifyTrue(testCase, ismember(match.points1, [0, 0.5, 1]));
verifyTrue(testCase, ismember(match.points2, [0, 0.5, 1]));
verifyEqual(testCase, match.points1 + match.points2, 1);
end

function testSimulateDiceDuelMatchMultipleDice(testCase)
match = simulateDiceDuelMatch('X', 'Y', 6, 2);
verifyTrue(testCase, length(match.roll1) == 2);
verifyTrue(testCase, length(match.roll2) == 2);
end

function testSimulateDiceDuelMatchOrderedResult(testCase)
% Alice wins -> points1=1, points2=0; Bob wins -> points1=0, points2=1
% Draw -> points1=0.5, points2=0.5
match = simulateDiceDuelMatch('Alice', 'Bob', 6, 1);
if strcmp(match.winner, 'Alice')
    verifyEqual(testCase, match.points1, 1);
    verifyEqual(testCase, match.points2, 0);
elseif strcmp(match.winner, 'Bob')
    verifyEqual(testCase, match.points1, 0);
    verifyEqual(testCase, match.points2, 1);
else
    verifyEqual(testCase, match.points1, 0.5);
    verifyEqual(testCase, match.points2, 0.5);
end
end

function testResolveDiceDuelRoundStructure(testCase)
players = buildDiceDuel(4);
round_data = resolveDiceDuelRound(players, 6, 1);
% 4 players -> 6 matches (round-robin pairs)
num_matches = nchoosek(4, 2);
verifyEqual(testCase, length(round_data), num_matches);
end

function testResolveDiceDuelRoundTwoPlayers(testCase)
players = {'A', 'B'};
round_data = resolveDiceDuelRound(players, 6, 1);
verifyEqual(testCase, length(round_data), 1);
verifyEqual(testCase, round_data(1).player1, 'A');
verifyEqual(testCase, round_data(1).player2, 'B');
end

function testSummarizeDiceDuel(testCase)
players = {'A', 'B'};
round_data(1).player1 = 'A'; round_data(1).player2 = 'B';
round_data(1).roll1 = 4; round_data(1).roll2 = 2;
round_data(1).winner = 'A'; round_data(1).points1 = 1; round_data(1).points2 = 0;
all_rounds = {round_data};
summary = summarizeDiceDuel(all_rounds, players);
verifyEqual(testCase, summary.scores(1), 1);
verifyEqual(testCase, summary.scores(2), 0);
verifyEqual(testCase, summary.winner, 'A');
end

function testPlayDiceDuelDefault(testCase)
summary = playDiceDuel();
verifyEqual(testCase, summary.rounds, 10);
verifyEqual(testCase, length(summary.scores), 4);
verifyTrue(testCase, isfield(summary, 'wins'));
verifyTrue(testCase, isfield(summary, 'draws'));
verifyTrue(testCase, isfield(summary, 'losses'));
end

function testPlayDiceDuelCustom(testCase)
summary = playDiceDuel(3, 5);
verifyEqual(testCase, summary.rounds, 5);
verifyEqual(testCase, length(summary.scores), 3);
end

% =========================================================================
% Lucky Wheel Tests
% =========================================================================

function testBuildLuckyWheelDefault(testCase)
players = buildLuckyWheel();
verifyEqual(testCase, length(players), 4);
verifyEqual(testCase, players{1}, 'Spinner-1');
verifyEqual(testCase, players{4}, 'Spinner-4');
end

function testBuildLuckyWheelCustom(testCase)
players = buildLuckyWheel(3);
verifyEqual(testCase, length(players), 3);
end

function testBuildLuckyWheelError(testCase)
verifyError(testCase, @() buildLuckyWheel(1), 'Arcade:InvalidArgument');
end

function testSpinLuckyWheelDefault(testCase)
result = spinLuckyWheel();
verifyTrue(testCase, isstruct(result));
verifyTrue(testCase, isfield(result, 'section'));
verifyTrue(testCase, isfield(result, 'prize'));
verifyTrue(testCase, isnumeric(result.prize));
end

function testSpinLuckyWheelCustom(testCase)
sections = {'10', '20', 'Bankrupt'};
result = spinLuckyWheel(sections);
verifyTrue(testCase, ismember(result.section, sections));
end

function testSpinLuckyWheelPrizeValues(testCase)
% Test numeric section
result = spinLuckyWheel({'50'});
verifyEqual(testCase, result.section, '50');
verifyEqual(testCase, result.prize, 50);

% Test Bankrupt
result = spinLuckyWheel({'Bankrupt'});
verifyEqual(testCase, result.section, 'Bankrupt');
verifyEqual(testCase, result.prize, -1);

% Test Lose a Turn
result = spinLuckyWheel({'Lose a Turn'});
verifyEqual(testCase, result.section, 'Lose a Turn');
verifyEqual(testCase, result.prize, 0);
end

function testScoreLuckyWheelSpinNormal(testCase)
sr.section = '20'; sr.prize = 20;
verifyEqual(testCase, scoreLuckyWheelSpin(sr, 100), 20);
end

function testScoreLuckyWheelSpinBankrupt(testCase)
sr.section = 'Bankrupt'; sr.prize = -1;
verifyEqual(testCase, scoreLuckyWheelSpin(sr, 100), -100);
verifyEqual(testCase, scoreLuckyWheelSpin(sr, 50), -50);
verifyEqual(testCase, scoreLuckyWheelSpin(sr, 0), 0);
end

function testScoreLuckyWheelSpinLoseTurn(testCase)
sr.section = 'Lose a Turn'; sr.prize = 0;
verifyEqual(testCase, scoreLuckyWheelSpin(sr, 100), 0);
verifyEqual(testCase, scoreLuckyWheelSpin(sr, 0), 0);
end

function testSpinLuckyWheelError(testCase)
verifyError(testCase, @() spinLuckyWheel({}), 'Arcade:InvalidArgument');
verifyError(testCase, @() spinLuckyWheel('notacell'), 'Arcade:InvalidArgument');
end

function testSummarizeLuckyWheel(testCase)
players = {'A', 'B'};
round_data(1).player = 'A'; round_data(1).section = '20';
round_data(1).prize = 20; round_data(1).bank_before = 0;
round_data(1).bank_after = 20; round_data(1).points = 20;
round_data(2).player = 'B'; round_data(2).section = '10';
round_data(2).prize = 10; round_data(2).bank_before = 0;
round_data(2).bank_after = 10; round_data(2).points = 10;
all_rounds = {round_data};
summary = summarizeLuckyWheel(all_rounds, players);
verifyEqual(testCase, summary.rounds, 1);
verifyEqual(testCase, length(summary.scores), 2);
verifyEqual(testCase, summary.scores(1), 20);
verifyEqual(testCase, summary.scores(2), 10);
verifyEqual(testCase, summary.winner, 'A');
end

function testPlayLuckyWheelDefault(testCase)
summary = playLuckyWheel();
verifyEqual(testCase, summary.rounds, 10);
verifyEqual(testCase, length(summary.scores), 4);
verifyTrue(testCase, isfield(summary, 'bank_history'));
end

function testPlayLuckyWheelCustom(testCase)
summary = playLuckyWheel(3, 5);
verifyEqual(testCase, summary.rounds, 5);
verifyEqual(testCase, length(summary.scores), 3);
end