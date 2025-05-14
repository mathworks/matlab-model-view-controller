classdef ( Abstract, TestTags = "ui" ) tComponent < matlab.uitest.TestCase
    %TCOMPONENT Common test infrastructure for views and controllers in the
    %simple MVC application.

    % Copyright 2025 The MathWorks, Inc.

    properties ( GetAccess = protected, SetAccess = private )
        % Reference to the model.
        ApplicationModel(:, 1) Model {mustBeScalarOrEmpty}
        % Figure parent.
        Figure(:, 1) matlab.ui.Figure {mustBeScalarOrEmpty}
        % Class name of the component under test.
        ComponentType(1, 1) string
    end % properties ( GetAccess = protected, SetAccess = private )

    properties ( Access = protected )
        % View/controller component under test.
        ApplicationComponent(:, 1) Component {mustBeScalarOrEmpty}
    end % properties ( Access = protected )

    methods ( TestClassSetup )

        function checkConstruction( testCase )

            % Identify the component under test.
            testClassName = class( testCase );
            testCase.ComponentType = extractAfter( testClassName, 1 );

            % Attempt to construct the component.
            m = Model();
            componentConstructor = @() feval( testCase.ComponentType, m );
            testCase.fatalAssertWarningFree( componentConstructor, ...
                "Calling the " + testCase.ComponentType + ...
                " constructor was not warning free." )

        end % checkConstruction

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function setupModel( testCase )

            % Instantiate the model.
            testCase.ApplicationModel = Model();

            % Clean up the model after each test point.
            testCase.addTeardown( @() delete( testCase.ApplicationModel ) )

        end % setupModel

        function applyFigureFixture( testCase )

            % Apply the figure fixture and store a reference to the figure
            % for use in each test point.
            fixture = testCase.applyFixture( FigureFixture() );
            testCase.Figure = fixture.Figure;

        end % applyFigureFixture

        function createComponent( testCase )

            testCase.ApplicationComponent = feval( ...
                testCase.ComponentType, testCase.ApplicationModel, ...
                "Parent", testCase.Figure );
            
        end % createComponent

    end % methods ( TestMethodSetup )

    methods ( Test, TestTags = "validHandle" )

        function tComponentIsValidHandle( testCase )

            % The component should be a valid handle object.
            testCase.verifyTrue( ...
                isvalid( testCase.ApplicationComponent ), ...
                "The " + testCase.ComponentType + " constructor did " + ...
                "not create a valid handle object." )

        end % tComponentIsValidHandle

    end % methods ( Test )

end % classdef