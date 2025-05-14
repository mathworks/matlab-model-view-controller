function plan = buildfile()
%BUILDFILE Example MVC application build file.

% Copyright 2025 The MathWorks, Inc.

% Define the build plan.
plan = buildplan( localfunctions() );

% Set the archive task to run by default.
plan.DefaultTasks = "archive";

% Add a test task to run the unit tests for the project. Generate and save
% a coverage report.
projectRoot = plan.RootFolder;
testsFolder = fullfile( projectRoot, "tests" );
codeFolder = fullfile( projectRoot, "code" );
plan("test") = matlab.buildtool.tasks.TestTask( testsFolder, ...
    "Strict", true, ...
    "Description", "Assert that all project tests pass.", ...
    "SourceFiles", codeFolder, ...
    "CodeCoverageResults", "reports/Coverage.html", ...
    "OutputDetail", "verbose" );

% The test task depends on the check task.
plan("test").Dependencies = "check";

% The archive task depends on the test task.
plan("archive").Dependencies = "test";

end % buildfile

function checkTask( context )
% Check the source code and project for any issues.

% Set the project root as the folder in which to check for any static code
% issues.
projectRoot = context.Plan.RootFolder;
codeIssuesTask = matlab.buildtool.tasks.CodeIssuesTask( projectRoot, ...
    "IncludeSubfolders", true, ...
    "Configuration", "factory", ...
    "Description", ...
    "Assert that there are no code issues in the project.", ...
    "WarningThreshold", 0 );
codeIssuesTask.analyze( context )

% Update the project dependencies.
prj = currentProject();
prj.updateDependencies()

% Run the checks.
checkResults = table( prj.runChecks() );

% Log any failed checks.
passed = checkResults.Passed;
notPassed = ~passed;
if any( notPassed )
    disp( checkResults(notPassed, :) )
else
    fprintf( "** All project checks passed.\n\n" )
end % if

% Check that all checks have passed.
assert( all( passed ), "buildfile:ProjectIssue", ...
    "At least one project check has failed. " + ...
    "Resolve the failures shown above to continue." )

end % checkTask

function archiveTask( ~ )
% Archive the project.

proj = currentProject();
projectRoot = proj.RootFolder;
exportName = fullfile( projectRoot, "MVC.mlproj" );
proj.export( exportName )

end % archiveTask