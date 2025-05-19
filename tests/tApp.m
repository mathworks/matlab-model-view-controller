classdef ( TestTags = ["system", "ui"] ) tApp < Testable
    %TAPP System-level test for the entire application.

    % Copyright 2025 The MathWorks, Inc.

    properties ( Access = private )
        % App figure.
        AppFigure(:, 1) matlab.ui.Figure
    end % properties ( Access = private )

    methods ( TestClassSetup )

        function launchApp( testCase )

            % Assert that the app can be launched without issues.
            fcn = @() appLauncherWrapper();
            testCase.fatalAssertWarningFree( fcn, ...
                "The application did not launch without warnings." )

            function appLauncherWrapper()

                f = launchMVCApp();
                figureCleanup = onCleanup( @() delete( f ) );

            end % appLauncherWrapper

        end % launchApp

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function startApp( testCase )

            % Launch the app and store the figure handle.
            testCase.AppFigure = launchMVCApp();
            testCase.addTeardown( @() delete( testCase.AppFigure ) )

        end % startApp

    end % methods ( TestMethodSetup )

    methods ( Test )

        function tResetButtonUpdatesView( testCase )

            % Identify the app's toolbar.
            kids = testCase.AppFigure.Children;
            toolbar = kids(1);

            % Identify the reset button.
            resetButton = toolbar.Children(1);

            % Push the button.
            testCase.press( resetButton )

            % Verify that the view's line has empty data.
            view = kids(2).Children(1);
            testCase.verifyEmpty( view.Line.XData, ...
                "The view's 'XData' property was not empty after " + ...
                "pressing the reset button on the toolbar." )
            testCase.verifyEmpty( view.Line.YData, ...
                "The view's 'YData' property was not empty after " + ...
                "pressing the reset button on the toolbar." )

        end % tResetButtonUpdatesView

        function tGenerateDataButtonUpdatesView( testCase )

            % Identify the controller.
            kids = testCase.AppFigure.Children;
            controller = kids(2).Children(2);

            % Press the button.
            testCase.press( controller.Button )

            % Verify that the view's line has nonempty data.
            view = kids(2).Children(1);
            testCase.verifyNotEmpty( view.Line.XData, ...
                "The view's 'XData' property was empty after " + ...
                "generating new data." )
            testCase.verifyNotEmpty( view.Line.YData, ...
                "The view's 'YData' property was empty after " + ...
                "generating new data." )

        end % tGenerateDataButtonUpdatesView

    end % methods ( Test )

end % classdef