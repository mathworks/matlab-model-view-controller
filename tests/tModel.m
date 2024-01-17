classdef tModel < matlab.unittest.TestCase
    %TMODEL Unit tests for the Model.

    properties ( Access = private )
        % Reference to the model.
        M(:, 1) Model {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    % Runs once, when the class is set up.
    methods ( TestClassSetup )

        function checkConstruction( testCase )

            % Stop the entire test process if the model constructor fails.
            modelConstructor = @() Model();
            testCase.fatalAssertWarningFree( modelConstructor )

        end % checkConstruction

    end % methods ( TestClassSetup )

    % Runs many times, once before each test method.
    methods ( TestMethodSetup )

        function setupModel( testCase )

            % Guarantee that each test uses the same starting model.
            testCase.M = Model();

            % Clean up.
            testCase.addTeardown( @() delete( testCase.M ) )

        end % setupModel

    end % methods ( TestMethodSetup )

    % Individual test points.
    methods ( Test )

        function tModelIsHandle( testCase )

            % Model should be a valid handle class.
            testCase.verifyTrue( isvalid( testCase.M ) )

        end % tModelIsHandle

        function tInitialDataPropertyEmpty( testCase )

            % Model's Data property should initialize to empty 0x1 double.
            testCase.verifyEmpty( testCase.M.Data )
            testCase.verifySize( testCase.M.Data, [0, 1] )
            testCase.verifyClass( testCase.M.Data, "double" )

        end % tInitialDataPropertyEmpty

        function tRandomMethodGeneratesNewData( testCase )

            % Random method should generate a 20 x 1 vector of doubles
            random( testCase.M )
            testCase.verifySize( testCase.M.Data, [20, 1] )
            testCase.verifyClass( testCase.M.Data, "double" )

        end % tRandomMethodGeneratesNewData

        function tResetMethodRestoresDataToEmpty( testCase )

            % Generate data, then reset.
            random( testCase.M );
            reset( testCase.M );

            % Model's Data property should reset to empty 0x1 double.
            testCase.verifyEmpty( testCase.M.Data )
            testCase.verifySize( testCase.M.Data, [0, 1] )
            testCase.verifyClass( testCase.M.Data, "double" )

        end % tResetMethodRestoresDataToEmpty

        function tDataChangedEvent( testCase )

            % Create a listener.
            eventNotified = false;
            listener( testCase.M, "DataChanged", @onDataChanged );

            function onDataChanged( ~, ~ )

                % Scoped variable in nested function.
                eventNotified = true;

            end % onDataChanged

            % Trigger a data change.
            random( testCase.M );

            % Check that eventNotified is true.
            testCase.verifyTrue( eventNotified )

        end % tDataChangedEvent

    end % methods ( Test )

end % classdef