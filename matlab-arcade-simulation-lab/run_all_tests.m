function results = run_all_tests()
%RUN_ALL_TESTS  Run all unit tests for MATLAB Arcade Simulation Lab
%   results = run_all_tests() discovers and runs all test files in the
%   tests/ directory, returning a results struct.
%
%   See also run_all_demos

% Add core utilities to MATLAB path
addpath(fullfile('src', 'core'));

fprintf('\n========================================\n');
fprintf('  MATLAB Arcade Simulation Lab - Tests\n');
fprintf('========================================\n\n');

import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
import matlab.unittest.plugins.TestRunProgressPlugin;

% Discover all test files in tests/ directory
test_files = dir(fullfile('tests', '*Test*.m'));
if isempty(test_files)
    % Fallback: try to find tests without matlab.unittest
    fprintf('  No test files discovered via TestSuite.\n');
    fprintf('  Running manual test discovery...\n');
    results = run_manual_tests();
    return;
end

suite = TestSuite.fromFolder('tests');
runner = TestRunner.withTextOutput();
runner.addPlugin(TestRunProgressPlugin.withVerbosity(3));
results = runner.run(suite);

fprintf('\n========================================\n');
fprintf('  Test Summary: %d passed, %d failed, %d incomplete\n', ...
    sum([results.Passed]), sum([results.Failed]), sum([results.Incomplete]));
fprintf('========================================\n\n');
end

function results = run_manual_tests()
%RUN_MANUAL_TESTS  Manual test runner when matlab.unittest is unavailable
test_files = dir(fullfile('tests', '*Test*.m'));
test_count = 0;
pass_count = 0;
fail_count = 0;

for i = 1:length(test_files)
    [~, test_name, ~] = fileparts(test_files(i).name);
    fprintf('  Running %s...\n', test_name);
    test_count = test_count + 1;
    try
        feval(test_name);
        pass_count = pass_count + 1;
        fprintf('    PASSED\n');
    catch ME
        fail_count = fail_count + 1;
        fprintf('    FAILED: %s\n', ME.message);
    end
end

fprintf('\n  Manual Test Summary: %d passed, %d failed out of %d\n', ...
    pass_count, fail_count, test_count);

results.passed = pass_count;
results.failed = fail_count;
results.total = test_count;
end