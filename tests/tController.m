classdef tController < tComponent
    %TCONTROLLER Controller tests.
    %
    % See also Controller, Model, tModel, tComponent

    % Copyright 2025 The MathWorks, Inc.

    methods ( Test )

        function tPushingButtonGeneratesNewData( testCase )

            % Check that the 'Data' property in the model is empty.
            testCase.assertEmpty( testCase.ApplicationModel.Data, ...
                "The 'Data' property in the model was not empty " + ...
                "before starting this test." )

            % Push the button.
            c = testCase.ApplicationComponent;
            testCase.press( c.Button )

            % Verify that the 'Data' property in the model has been
            % populated.
            testCase.verifySize( testCase.ApplicationModel.Data, ...
                [20, 1], "The 'Data' property in the model was not" + ...
                " of size 20-by-1 after pressing the button on the " + ...
                "controller." )

        end % tPushingButtonGeneratesNewData

    end % methods ( Test )

end % classdef