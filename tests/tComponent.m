classdef (Abstract) tComponent < matlab.uitest.TestCase
    %TCOMPONENT Test infrastructure for views and controllers in the MVC
    %application.

    properties ( GetAccess = protected, SetAccess = private )
        % Reference to the Model.
        M(:, 1) Model {mustBeScalarOrEmpty}
        % Figure parent.
        Figure(:, 1) matlab.ui.Figure {mustBeScalarOrEmpty}
        % Class name of the component under test.
        ComponentType(1, 1) string
    end % properties ( GetAccess = protected, SetAccess = private )

    properties ( Access = protected )
        % View/controller component under test.
        Component(:, 1) CrashDataComponent {mustBeScalarOrEmpty}
    end % properties ( Access = protected )

    methods ( TestClassSetup )

        function checkConstruction( testCase )

            testClassName = class( testCase );
            testCase.ComponentType = extractAfter( testClassName, 1 );
            m = Model();
            componentConstructor = @() feval( testCase.ComponentType, ...
                m );
            testCase.fatalAssertWarningFree( componentConstructor )

        end % constructionCheck

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function setupModel( testCase )

            % Instantiate the model.
            testCase.M = Model();
            % Clean up the model after each test point.
            testCase.addTeardown( @() delete( testCase.M ) )

        end % setupModel

        function applyFigureFixture( testCase )

            % Apply the figure fixture and store a reference to the figure
            % for use in each test point.
            fixture = testCase.applyFixture( FigureFixture() );
            testCase.Figure = fixture.Figure;

        end % applyFigureFixture

        function createComponent( testCase )

            testCase.Component = feval( testCase.ComponentType, ...
                testCase.Model, "Parent", testCase.Figure );

        end % createComponent

    end % methods ( TestMethodSetup )

end % classdef