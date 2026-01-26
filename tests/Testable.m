classdef Testable < matlab.uitest.TestCase
    %TESTABLE Convenience class used for testing purposes.

    % Copyright 2025 The MathWorks, Inc.

    methods ( TestClassSetup )

        function setRNGState( testCase )

            s = rng();
            testCase.addTeardown( @() rng( s ) )            
            rng( "default" )

        end % setRNGState

    end % methods ( TestClassSetup )
       
end % classdef