classdef tView < tComponent
    %TVIEW View tests.
    %
    % See also View, Model, tModel, tComponent

    % Copyright 2025 The MathWorks, Inc.

    methods ( Test )

        function tViewHasEmptyDoubleDataInitially( testCase )

            testCase.verifyThatViewLineDataIsEmptyDouble()

        end % tViewHasEmptyDoubleDataInitially

        function tViewHasEmptyDoubleDataAfterCallingReset( testCase )

            % Reset the model.
            testCase.ApplicationModel.reset()

            % Verify.
            testCase.verifyThatViewLineDataIsEmptyDouble()

            % Call random() and then reset().
            testCase.ApplicationModel.random()
            testCase.ApplicationModel.reset()

            % Verify.
            testCase.verifyThatViewLineDataIsEmptyDouble()

        end % tViewHasEmptyDoubleDataAfterCallingReset

        function tViewHasCorrectDataAfterCallingRandom( testCase )

            % Call the model's random() method.
            testCase.ApplicationModel.random()

            % Verify that the x- and y-data of the line are as expected.
            v = testCase.ApplicationComponent;
            actualx = v.Line.XData;
            actualy = v.Line.YData;
            constraintx = IsEqualVector( ...
                1 : numel( testCase.ApplicationModel.Data ) );
            constrainty = IsEqualVector( testCase.ApplicationModel.Data );
            testCase.verifyThat( actualx, constraintx, ...
                "After calling random(), the XData of the line in " + ...
                "the view does not match the expected data." )
            testCase.verifyThat( actualy, constrainty, ...
                "After calling ranromd(), the YData of the line in " + ...
                "the view does not match the model's 'Data' property." )

        end % tViewHasCorrectDataAfterCallingRandom

        function tUpdateMeViewAssignsPublicProperties( testCase )

            % Generate data.
            testCase.ApplicationModel.random()

            % Record the current line width and color.
            v = testCase.ApplicationComponent;
            lineWidth = v.LineWidth;
            lineColor = v.LineColor;

            % Set the line width and color properties.
            newLineWidth = 10;
            newLineColor = [1, 0, 0];
            set( v, "LineWidth", newLineWidth, "LineColor", newLineColor )
            drawnow()
            testCase.addTeardown( @() set( v, ...
                "LineWidth", lineWidth, "LineColor", lineColor ) )

            % Verify that the values have been set correctly.
            testCase.verifyEqual( v.LineWidth, newLineWidth, ...
                "Setting the 'LineWidth' property of the view " + ...
                "did not store the value correctly.", "AbsTol", 1e-6 )
            testCase.verifyEqual( v.LineColor, newLineColor, ...
                "Setting the 'LineColor' property of the view " + ...
                "did not store the value correctly.", "AbsTol", 1e-6 )

        end % tViewAssignsPublicProperties

    end % methods ( Test )

    methods ( Access = private )

        function verifyThatViewLineDataIsEmptyDouble( testCase )

            % Verify that the x- and y-data of the line are of type double.
            v = testCase.ApplicationComponent;
            actualx = v.Line.XData;
            actualy = v.Line.YData;
            testCase.verifyClass( actualx, "double", ...
                "The x-data of the line is not of type double." )
            testCase.verifyClass( actualy, "double", ...
                "The y-data of the line is not of type double." )

            % Verify that the x- and y-data of the line are empty.
            constraint = IsEqualVector( double.empty( 0, 1 ) );
            testCase.verifyThat( actualx, constraint, ...
                "The initial XData of the line in the view is not " + ...
                "an empty vector of size 1-by-0." )
            constraint = IsEqualVector( testCase.ApplicationModel.Data );
            testCase.verifyThat( actualy, constraint, ...
                "The initial YData of the line in the view is not " + ...
                "an empty vector of size 1-by-0." )

        end % verifyThatViewLineDataIsEmptyDouble

    end % methods ( Access = private )

end % classdef