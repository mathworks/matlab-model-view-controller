classdef tModel < Testable
    %TMODEL Unit tests for the application data model.
    %
    % See also Model.

    % Copyright 2025 The MathWorks, Inc.

    properties ( Access = private )
        % Reference to the model.
        ApplicationModel(:, 1) Model {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods ( TestClassSetup )

        function assertModelConstructionIsWarningFree( testCase )

            % Stop the entire test process if the model constructor fails.
            modelConstructor = @() Model();
            testCase.fatalAssertWarningFree( modelConstructor, ...
                "The model constructor was not warning free." )

        end % assertModelConstructionIsWarningFree

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function setupModel( testCase )

            % Guarantee that each test uses the same starting model.
            testCase.ApplicationModel = Model();

            % Clean up.
            testCase.addTeardown( @() delete( testCase.ApplicationModel ) )

        end % setupModel

    end % methods ( TestMethodSetup )

    methods ( Test, TestTags = "validHandle" )

        function tModelIsValidHandle( testCase )

            % The model should be a valid handle object.
            testCase.verifyTrue( isvalid( testCase.ApplicationModel ), ...
                "The model constructor did not create a valid " + ...
                "handle object." )

        end % tModelIsValidHandle

    end % methods ( Test, TestTags = "validHandle" )

    methods ( Test, TestTags = "initialValue" )

        function tInitialDataPropertyIsEmptyDouble( testCase )

            % The model's Data property should initialize to an empty 0x1
            % double.
            testCase.verifyClass( testCase.ApplicationModel.Data, ...
                "double", "The model's 'Data' property is not of " + ...
                "type double." )
            testCase.verifySize( testCase.ApplicationModel.Data, ...
                [0, 1], "The model's 'Data' property is not of size" + ...
                "0-by-1." )

        end % tInitialDataPropertyIsEmptyDouble

    end % methods ( Test, TestTags = "initialValue" )

    methods ( Test, TestTags = ["controlMethods", "dataGeneration"] )

        function tRandomMethodGeneratesDoubleVector( testCase )

            % The random method should generate a 20 x 1 vector of doubles.
            random( testCase.ApplicationModel )
            testCase.verifyClass( testCase.ApplicationModel.Data, ...
                "double", "The random method did not generate a " + ...
                "value of type double." )
            testCase.verifySize( testCase.ApplicationModel.Data, ...
                [20, 1], "The random method did not generate a " + ...
                "vector of size 20-by-1." )

        end % tRandomMethodGeneratesDoubleVector

        function tResetMethodRestoresEmptyVector( testCase )

            % Reset the model.
            reset( testCase.ApplicationModel )

            % The 'Data' property should be reset to an empty 0x1 double.
            testCase.verifyClass( testCase.ApplicationModel.Data, ...
                "double", "The reset method did not set the 'Data'" + ...
                " property to a value of type double." )
            testCase.verifySize( testCase.ApplicationModel.Data, ...
                [0, 1], "The reset method did not give the 'Data'" + ...
                " property a size of 0-by-1." )

            % Generate new data, then reset.
            random( testCase.ApplicationModel )
            reset( testCase.ApplicationModel )
            testCase.verifyClass( testCase.ApplicationModel.Data, ...
                "double", "Calling reset() after random() did not " + ...
                "set the 'Data' property to a value of type double." )
            testCase.verifySize( testCase.ApplicationModel.Data, ...
                [0, 1], "Calling reset() after random() did not " + ...
                "set the 'Data' property to a value of size 0-by-1." )

        end % tResetMethodRestoresEmptyVector

    end % methods ( Test, TestTags = ["controlMethods", "dataGeneration"] )

    methods ( Test, TestTags = "eventNotification" )

        function tRandomMethodNotifiesDataChangedEvent( testCase )

            % Verify that calling random() notifies the 'DataChanged'
            % event.
            constraint = NotifiesEvent( ...
                testCase.ApplicationModel, "DataChanged" );
            f = @() random( testCase.ApplicationModel );
            testCase.verifyThat( f, constraint, "The random method " + ...
                "did not cause the model to notify the " + ...
                "'DataChanged' event." )

        end % tRandomMethodNotifiesDataChangedEvent

        function tResetMethodNotifiesDataChangedEvent( testCase )

            % Verify that calling reset() notifies the 'DataChanged'
            % event.
            constraint = NotifiesEvent( ...
                testCase.ApplicationModel, "DataChanged" );
            f = @() reset( testCase.ApplicationModel );
            testCase.verifyThat( f, constraint, "The reset method " + ...
                "did not cause the model to notify the " + ...
                "'DataChanged' event." )

        end % tResetMethodNotifiesDataChangedEvent

    end % methods ( Test, TestTags = "eventNotification" )

end % classdef