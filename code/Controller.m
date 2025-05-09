classdef Controller < Component
    %CONTROLLER Provides an interactive control to generate new data.

    % Copyright 2021-2025 The MathWorks, Inc.

    properties ( GetAccess = ?matlab.unittest.TestCase, ...
            SetAccess = private )
        % Push button for generating new data.
        Button(:, 1) matlab.ui.control.Button {mustBeScalarOrEmpty}
    end % properties ( GetAccess = ?matlab.unittest.TestCase, ...
    % SetAccess = private )

    methods

        function obj = Controller( model, namedArgs )
            % CONTROLLER Controller constructor.

            arguments ( Input )
                model(1, 1) Model
                namedArgs.?Controller
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@Component( model )

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the controller.

            % Create grid and button.
            g = uigridlayout( ...
                "Parent", obj, ...
                "RowHeight", "1x", ...
                "ColumnWidth", "1x", ...
                "Padding", 0 );
            obj.Button = uibutton( ...
                "Parent", g, ...
                "Text", "Generate Random Data", ...
                "ButtonPushedFcn", @obj.onButtonPushed );

        end % setup

        function update( ~ )
            %UPDATE Update the controller. This method is empty because
            %there are no public properties of the controller.

        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function onButtonPushed( obj, ~, ~ )

            % Invoke the random() method of the model.
            random( obj.Model )

        end % onButtonPushed

    end % methods ( Access = private )

end % classdef