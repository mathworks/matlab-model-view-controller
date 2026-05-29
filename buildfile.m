function plan = buildfile()
%BUILDFILE Build file for the MVC App toolbox.

% Copyright 2025-2026 The MathWorks, Inc.

% Create a plan from the local task functions.
plan = buildplan( localfunctions() );

% Package the toolbox by default.
plan.DefaultTasks = "package";

% Write down the folders of interest.
prj = plan.RootFolder;
tbx = fullfile( prj, "tbx" );
code = fullfile( tbx, tbxname() );
tests = fullfile( prj, "tests" );

% Add the standard clean task.
plan("clean") = matlab.buildtool.tasks.CleanTask();

% Add a custom check task.
plan("check:code") = matlab.buildtool.tasks.CodeIssuesTask( prj, ...
    "IncludeSubfolders", true, ...
    "Configuration", "factory", ...    
    "ErrorThreshold", 0, ...
    "WarningThreshold", 0, ...
    "InfoThreshold", 0 );
plan("check:project") = matlab.buildtool.Task( ...
    "Description", "Run MATLAB project checks", ...
    "Actions", @checkProject, ...
    "Inputs", prj );

% Add a test task to run the unit tests for the project. Generate and save
% a coverage report.
plan("test") = matlab.buildtool.tasks.TestTask( tests, ...
    "Dependencies", "check", ...
    "Strict", true, ...
    "Description", "Assert that all project tests pass.", ...
    "SourceFiles", code, ...
    "CodeCoverageResults", "reports/Coverage.html", ...
    "OutputDetail", "verbose" );

% Add the toolbox packaging task.
plan("package").Inputs = tbx;
plan("package").Outputs = "releases/*.mltbx";
plan("package").Dependencies = "test";

end % buildfile

function name = tbxname()
%TBXNAME Toolbox folder name.

name = "mvcapp";

end % tbxname

function checkProject( ~ )
% Identify and report any project issues.

prj = currentProject();
prj.updateDependencies();
checkResults = table( prj.runChecks() );
passed = checkResults.Passed;
notPassed = ~passed;
if any( notPassed )
    disp( checkResults(notPassed, :) )
    assert( all( passed ), "buildfile:checkProject:ProjectCheckFailed", ...
        "At least one project check has failed. " + ...
        "Resolve the failure(s) shown above to continue." )    
else
    fprintf( 1, "** All project checks passed.\n\n" )
end % if

end % checkProject

function packageTask( context )
% Package the toolbox.

% Import and update the toolbox metadata.
projectRoot = context.Plan.RootFolder;
toolboxJSON = fullfile( projectRoot, tbxname() + ".json" );
meta = jsondecode( fileread( toolboxJSON ) );
meta.ToolboxFolder = fullfile( projectRoot, meta.ToolboxFolder );
meta.ToolboxMatlabPath = fullfile( projectRoot, meta.ToolboxMatlabPath );

% Synchronize the toolbox version with the version in Contents.m.
versionString = feval( @( s ) s(1).Version, ver( tbxname() ) ); %#ok<FVAL>
meta.ToolboxVersion = versionString;

% Specify the location of the output toolbox.
mltbx = fullfile( projectRoot, "releases", ...
    meta.ToolboxName + " " + versionString + ".mltbx" );
meta.OutputFile = mltbx;

if getenv( "GITHUB_ACTIONS" ) == "true"
    % Check version and tag compatibility for release.
    ref = string( getenv( "GITHUB_REF" ) );
    gitTagNumber = extractAfter( ref, "refs/tags/v" );
    assert( versionString == gitTagNumber, ...
        "buildfile:packageTask:VersionTagMismatch", ...
        "Toolbox version %s (from Contents.m) does not " + ...
        "match the current Git tag number (%s).", ...
        versionString, gitTagNumber )
    % Define stable name for GitHub.
    stableName = replace( meta.ToolboxName, " ", "_" ) + ".mltbx";
    meta.OutputFile = fullfile( projectRoot, "releases", stableName );
else
    % Include the version number in the toolbox file name.
    meta.OutputFile = fullfile( projectRoot, ...
        "releases", meta.ToolboxName + " " + versionString + ".mltbx" );
end % if

% Define the toolbox packaging options.
folder = meta.ToolboxFolder;
id = meta.Identifier;
meta = rmfield( meta, ["Identifier", "ToolboxFolder"] );
opts = matlab.addons.toolbox.ToolboxOptions( folder, id, meta );

% Package the toolbox and add the license.
matlab.addons.toolbox.packageToolbox( opts )
fprintf( 1, "[+] %s\n", opts.OutputFile );
lic = fileread( "license.txt" );
mlAddonSetLicense( char( opts.OutputFile ), ...
    struct( "type", "BSD", "text", lic ) );

end % packageTask