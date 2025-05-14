function varargout = runMVCTests()
%RUNMVCTESTS Run the MVC application tests and generate a test report.
%
% results = runMVCTests() runs all MVC application tests and returns the 
% results.

% Copyright 2025 The MathWorks, Inc.

nargoutchk( 0, 1 )

% Record the current folder (the tests directory).
testsFolder = fileparts( mfilename( "fullpath" ) );

% Create the test suite from the project.
suite = testsuite( testsFolder );

% Record text output.
runner = testrunner( "textoutput", ...
    "LoggingLevel", "Verbose", ...
    "OutputDetail", "Verbose" );

% Add a code coverage plugin.
report = matlab.unittest.plugins.codecoverage.CoverageReport( ...
    testsFolder, "MainFile", "Coverage.html" );
codeFolder = fullfile( fileparts( testsFolder ), "code" );
plugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder( ...
    codeFolder, "Producing", report );
runner.addPlugin( plugin )

% Add a diagnostics recording plugin for the test report.
plugin = matlab.unittest.plugins.DiagnosticsRecordingPlugin( ...   
    "IncludingPassingDiagnostics", true, ...
    "LoggingLevel", "Verbose", ...
    "OutputDetail", "Verbose" );
runner.addPlugin( plugin )

% Run the tests.
results = runner.run( suite );

% Generate the test report.
results.generatePDFReport( "TestResults.pdf", ...
    "Title", "MVC Application Test Results" )

if nargout == 1
    varargout{1} = results;
end % if

end % runMVCTests

