function tests = testCoreUtilities
%TESTCOREUTILITIES  Unit tests for core utility functions
%   Run all tests: run_all_tests()
%   Run single test: testCoreUtilities()
%
%   See also run_all_tests

tests = functiontests(localfunctions);
end

%% Fixtures
function setupOnce(testCase)
    % Set random seed for reproducible tests
    arcadeSeed(42);
    testCase.TestData.seed = 42;
end

%% arcadeRandomChoice Tests
function testRandomChoiceValid(testCase)
    items = {'heads', 'tails'};
    result = arcadeRandomChoice(items);
    verifyTrue(testCase, any(strcmp(result, items)));
end

function testRandomChoiceSingleItem(testCase)
    items = {'only'};
    result = arcadeRandomChoice(items);
    verifyEqual(testCase, result, 'only');
end

function testRandomChoiceDistribution(testCase)
    arcadeSeed(42);
    items = {'A', 'B'};
    counts = struct('A', 0, 'B', 0);
    for i = 1:1000
        result = arcadeRandomChoice(items);
        counts.(result) = counts.(result) + 1;
    end
    ratio = counts.A / counts.B;
    verifyTrue(testCase, ratio > 0.8 && ratio < 1.2);
end

function testRandomChoiceEmptyError(testCase)
    verifyError(testCase, @() arcadeRandomChoice({}), ...
        'Arcade:InvalidArgument');
end

function testRandomChoiceNumericArray(testCase)
    items = [10, 20, 30];
    result = arcadeRandomChoice(items);
    verifyTrue(testCase, any(result == items));
end

%% arcadeNormalizeName Tests
function testNormalizeNameHeads(testCase)
    result = arcadeNormalizeName('heads');
    verifyEqual(testCase, result, 'heads');
end

function testNormalizeNameTails(testCase)
    result = arcadeNormalizeName('tails');
    verifyEqual(testCase, result, 'tails');
end

function testNormalizeNameH(testCase)
    result = arcadeNormalizeName('h');
    verifyEqual(testCase, result, 'heads');
end

function testNormalizeNameT(testCase)
    result = arcadeNormalizeName('t');
    verifyEqual(testCase, result, 'tails');
end

function testNormalizeNameCaseInsensitive(testCase)
    verifyEqual(testCase, arcadeNormalizeName('HEADS'), 'heads');
    verifyEqual(testCase, arcadeNormalizeName('Heads'), 'heads');
    verifyEqual(testCase, arcadeNormalizeName('TAILS'), 'tails');
    verifyEqual(testCase, arcadeNormalizeName('Tails'), 'tails');
end

function testNormalizeNameTrim(testCase)
    verifyEqual(testCase, arcadeNormalizeName('  heads  '), 'heads');
    verifyEqual(testCase, arcadeNormalizeName('  tails  '), 'tails');
end

function testNormalizeNameInvalid(testCase)
    verifyEqual(testCase, arcadeNormalizeName('bad'), 'invalid');
    verifyEqual(testCase, arcadeNormalizeName('123'), 'invalid');
    verifyEqual(testCase, arcadeNormalizeName(''), 'invalid');
end

function testNormalizeNameEdgeCases(testCase)
    verifyEqual(testCase, arcadeNormalizeName('  H  '), 'heads');
    verifyEqual(testCase, arcadeNormalizeName('  T  '), 'tails');
    verifyEqual(testCase, arcadeNormalizeName(' head'), 'invalid');
end

%% arcadeClamp Tests
function testClampWithinBounds(testCase)
    verifyEqual(testCase, arcadeClamp(0.5, 0, 1), 0.5);
end

function testClampBelowMin(testCase)
    verifyEqual(testCase, arcadeClamp(-0.5, 0, 1), 0);
end

function testClampAboveMax(testCase)
    verifyEqual(testCase, arcadeClamp(1.5, 0, 1), 1);
end

function testClampExactBounds(testCase)
    verifyEqual(testCase, arcadeClamp(0, 0, 1), 0);
    verifyEqual(testCase, arcadeClamp(1, 0, 1), 1);
end

function testClampNegativeBounds(testCase)
    verifyEqual(testCase, arcadeClamp(-5, -10, -1), -5);
end

%% arcadeValidateProbability Tests
function testValidateProbabilityValid(testCase)
    verifyTrue(testCase, arcadeValidateProbability(0));
    verifyTrue(testCase, arcadeValidateProbability(0.5));
    verifyTrue(testCase, arcadeValidateProbability(1));
end

function testValidateProbabilityInvalid(testCase)
    verifyFalse(testCase, arcadeValidateProbability(-0.1));
    verifyFalse(testCase, arcadeValidateProbability(1.5));
    verifyFalse(testCase, arcadeValidateProbability(NaN));
    verifyFalse(testCase, arcadeValidateProbability(Inf));
end

%% arcadeSeed Tests
function testSeedReproducibility(testCase)
    arcadeSeed(123);
    result1 = arcadeRandomChoice({'A', 'B', 'C', 'D'});
    arcadeSeed(123);
    result2 = arcadeRandomChoice({'A', 'B', 'C', 'D'});
    verifyEqual(testCase, result1, result2);
end

function testSeedDifferentResults(testCase)
    arcadeSeed(1);
    r1 = arcadeRandomChoice({1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
    arcadeSeed(999);
    r2 = arcadeRandomChoice({1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
    verifyNotEqual(testCase, r1, r2);
end

%% arcadeSafeMean Tests
function testSafeMeanBasic(testCase)
    verifyEqual(testCase, arcadeSafeMean([1, 2, 3, 4, 5]), 3);
end

function testSafeMeanWithNaN(testCase)
    verifyEqual(testCase, arcadeSafeMean([1, 2, NaN, 4, 5]), 3);
end

function testSafeMeanEmpty(testCase)
    verifyTrue(testCase, isnan(arcadeSafeMean([])));
end

function testSafeMeanAllNaN(testCase)
    verifyTrue(testCase, isnan(arcadeSafeMean([NaN, NaN])));
end

function testSafeMeanSingleValue(testCase)
    verifyEqual(testCase, arcadeSafeMean([42]), 42);
end

%% arcadeSafeStd Tests
function testSafeStdBasic(testCase)
    result = arcadeSafeStd([1, 2, 3, 4, 5]);
    verifyTrue(testCase, abs(result - std([1 2 3 4 5])) < 1e-10);
end

function testSafeStdWithNaN(testCase)
    result = arcadeSafeStd([1, 2, NaN, 4, 5]);
    expected = std([1 2 4 5]);
    verifyTrue(testCase, abs(result - expected) < 1e-10);
end

function testSafeStdEmpty(testCase)
    verifyTrue(testCase, isnan(arcadeSafeStd([])));
end

function testSafeStdConstant(testCase)
    verifyEqual(testCase, arcadeSafeStd([5, 5, 5]), 0);
end

%% arcadeScoreTable Tests
function testScoreTableBasic(testCase)
    names = {'Alice', 'Bob', 'Carol'};
    scores = [85, 92, 78];
    tbl = arcadeScoreTable(names, scores);
    verifyEqual(testCase, size(tbl), [3, 3]);
    verifyEqual(testCase, tbl{1,1}, '1');  % Top scorer
end

function testScoreTableTies(testCase)
    names = {'A', 'B', 'C'};
    scores = [50, 50, 30];
    tbl = arcadeScoreTable(names, scores);
    verifyEqual(testCase, tbl{1,1}, '1');
    verifyEqual(testCase, tbl{2,1}, '1');  % Tie for first
    verifyEqual(testCase, tbl{3,1}, '3');
end

function testScoreTableEmptyError(testCase)
    verifyError(testCase, @() arcadeScoreTable({}, []), 'Arcade:InvalidArgument');
end

function testScoreTableMismatchError(testCase)
    verifyError(testCase, @() arcadeScoreTable({'A','B'}, [1,2,3]), ...
        'Arcade:InvalidArgument');
end

%% arcadeTextBar Tests
function testTextBarFull(testCase)
    result = arcadeTextBar(1.0, 10);
    verifyEqual(testCase, result, '##########');
end

function testTextBarEmpty(testCase)
    result = arcadeTextBar(0, 10);
    verifyEqual(testCase, result, '----------');
end

function testTextBarHalf(testCase)
    result = arcadeTextBar(0.5, 10);
    verifyEqual(testCase, result, '#####-----');
end

function testTextBarClamping(testCase)
    result_high = arcadeTextBar(1.5, 5);
    result_low = arcadeTextBar(-0.5, 5);
    verifyEqual(testCase, result_high, '#####');
    verifyEqual(testCase, result_low, '-----');
end

%% arcadeConfig Tests
function testConfigDefault(testCase)
    cfg = arcadeConfig();
    verifyTrue(testCase, isstruct(cfg));
    verifyTrue(testCase, isfield(cfg, 'verbose'));
end

function testConfigCustom(testCase)
    cfg = arcadeConfig('verbose', false, 'max_iterations', 100);
    verifyFalse(testCase, cfg.verbose);
    verifyEqual(testCase, cfg.max_iterations, 100);
end

%% arcadeAssert Tests
function testAssertValid(testCase)
    arcadeAssert(true, 'Test', 'Should not error');
    verifyTrue(testCase, true);
end

function testAssertInvalid(testCase)
    verifyError(testCase, @() arcadeAssert(false, 'Test', 'Should error'), ...
        'Arcade:AssertionFailed');
end

%% arcadeWeightedChoice Tests
function testWeightedChoiceValid(testCase)
    items = {'A', 'B', 'C'};
    weights = [0.5, 0.3, 0.2];
    result = arcadeWeightedChoice(items, weights);
    verifyTrue(testCase, any(strcmp(result, items)));
end

function testWeightedChoiceSizeMismatch(testCase)
    verifyError(testCase, @() arcadeWeightedChoice({'A','B'}, [0.5,0.3,0.2]), ...
        'Arcade:InvalidArgument');
end

%% arcadeDiceRoll Tests
function testDiceRollSingle(testCase)
    result = arcadeDiceRoll(6);
    verifyTrue(testCase, result >= 1 && result <= 6);
end

function testDiceRollMultiple(testCase)
    result = arcadeDiceRoll(6, 2);
    verifyTrue(testCase, result >= 2 && result <= 12);
end

function testDiceRollWithModifier(testCase)
    result = arcadeDiceRoll(6, 1, 5);
    verifyTrue(testCase, result >= 6 && result <= 11);
end

function testDiceRollInvalidSides(testCase)
    verifyError(testCase, @() arcadeDiceRoll(1), 'Arcade:InvalidArgument');
end

function testDiceRollD20(testCase)
    for i = 1:20
        result = arcadeDiceRoll(20);
        verifyTrue(testCase, result >= 1 && result <= 20);
    end
end

function testDiceRollD100(testCase)
    result = arcadeDiceRoll(100);
    verifyTrue(testCase, result >= 1 && result <= 100);
end

%% arcadeShuffle Tests
function testShuffleSameElements(testCase)
    original = {'A', 'B', 'C', 'D', 'E'};
    shuffled = arcadeShuffle(original);
    verifyEqual(testCase, sort(shuffled), sort(original));
end

function testShuffleSameLength(testCase)
    original = {'A', 'B', 'C', 'D', 'E'};
    shuffled = arcadeShuffle(original);
    verifyEqual(testCase, length(shuffled), length(original));
end

function testShuffleNotAlwaysSame(testCase)
    original = {'A', 'B', 'C', 'D', 'E'};
    arcadeSeed(100);
    s1 = arcadeShuffle(original);
    arcadeSeed(200);
    s2 = arcadeShuffle(original);
    verifyNotEqual(testCase, s1, s2);
end

function testShuffleEmptyError(testCase)
    verifyError(testCase, @() arcadeShuffle({}), 'Arcade:InvalidArgument');
end

function testShuffleSingleElement(testCase)
    original = {'only'};
    shuffled = arcadeShuffle(original);
    verifyEqual(testCase, shuffled, {'only'});
end

%% arcadeCoinFlip Tests
function testCoinFlipValidResults(testCase)
    for i = 1:10
        result = arcadeCoinFlip();
        verifyTrue(testCase, strcmp(result, 'heads') || strcmp(result, 'tails'));
    end
end

function testCoinFlipDistribution(testCase)
    arcadeSeed(42);
    heads = 0;
    tails = 0;
    for i = 1:1000
        if strcmp(arcadeCoinFlip(), 'heads')
            heads = heads + 1;
        else
            tails = tails + 1;
        end
    end
    ratio = heads / tails;
    verifyTrue(testCase, ratio > 0.8 && ratio < 1.2);
end

%% arcadeSimulateTournament Tests
function testTournamentBasic(testCase)
    arcadeSeed(42);
    players = {'A', 'B'};
    strategies = {@() 'cooperate', @() 'cooperate'};
    results = arcadeSimulateTournament(players, 10, strategies);
    verifyEqual(testCase, size(results.matrix), [2, 2]);
    verifyEqual(testCase, results.names, {'A'; 'B'});
end

function testTournamentAllCooperate(testCase)
    arcadeSeed(42);
    players = {'A', 'B', 'C'};
    strategies = {@() 'cooperate', @() 'cooperate', @() 'cooperate'};
    results = arcadeSimulateTournament(players, 10, strategies);
    % All cooperators should have same scores
    verifyEqual(testCase, results.scores(1), results.scores(2));
    verifyEqual(testCase, results.scores(2), results.scores(3));
end

function testTournamentDefaultStrategies(testCase)
    arcadeSeed(42);
    players = {'X', 'Y'};
    results = arcadeSimulateTournament(players, 5);
    verifyTrue(testCase, isfield(results, 'scores'));
    verifyTrue(testCase, isfield(results, 'table'));
end

%% arcadeAnalyzeResults Tests
function testAnalyzeResultsBasic(testCase)
    scores = [10, 20, 30, 40, 50];
    stats = arcadeAnalyzeResults(scores, 'Test Group');
    verifyEqual(testCase, stats.mean, 30);
    verifyEqual(testCase, stats.min, 10);
    verifyEqual(testCase, stats.max, 50);
    verifyEqual(testCase, stats.count, 5);
    verifyEqual(testCase, stats.median, 30);
end

function testAnalyzeResultsWithNaN(testCase)
    stats = arcadeAnalyzeResults([10, NaN, 30]);
    verifyFalse(testCase, isnan(stats.mean));
    verifyEqual(testCase, stats.count, 2);
end

function testAnalyzeResultsSingleValue(testCase)
    stats = arcadeAnalyzeResults([42]);
    verifyEqual(testCase, stats.mean, 42);
    verifyEqual(testCase, stats.count, 1);
end

function testAnalyzeResultsEmpty(testCase)
    stats = arcadeAnalyzeResults([]);
    verifyTrue(testCase, isnan(stats.mean));
end

function testAnalyzeResultsLabel(testCase)
    stats = arcadeAnalyzeResults([1, 2, 3], 'Players');
    verifyEqual(testCase, stats.label, 'Players');
end

%% arcadeFormatScore Tests
function testFormatScoreSmall(testCase)
    verifyEqual(testCase, arcadeFormatScore(42), '42');
end

function testFormatScoreThousand(testCase)
    verifyEqual(testCase, arcadeFormatScore(1234), '1,234');
end

function testFormatScoreMillion(testCase)
    verifyEqual(testCase, arcadeFormatScore(1000000), '1,000,000');
end

function testFormatScoreNegative(testCase)
    verifyEqual(testCase, arcadeFormatScore(-50), '-50');
end

%% arcadeFormatPercent Tests
function testFormatPercentBasic(testCase)
    verifyEqual(testCase, arcadeFormatPercent(0.5), '50.0%');
end

function testFormatPercentWhole(testCase)
    verifyEqual(testCase, arcadeFormatPercent(1.0), '100.0%');
end

function testFormatPercentZero(testCase)
    verifyEqual(testCase, arcadeFormatPercent(0), '0.0%');
end