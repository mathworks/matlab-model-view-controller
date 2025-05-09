classdef View < Component
    %VIEW Visualizes the data, responding to any relevant model events.
    
    % Copyright 2021-2025 The MathWorks, Inc.

    properties
        % Line width.
        LineWidth(1, 1) double {mustBePositive, mustBeFinite} = 1.5
        % Line color.
        LineColor {validatecolor} = "k"
    end % properties

    properties ( GetAccess = ?matlab.unittest.TestCase, ...
            SetAccess = private )
        % Line object used to visualize the model data.
        Line(:, 1) matlab.graphics.primitive.Line {mustBeScalarOrEmpty}
    end % properties ( GetAccess = ?matlab.unittest.TestCase, ...
    % SetAccess = private )

    properties ( Access = private )
        % Listener object used to respond dynamically to model events.
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = View( model, namedArgs )
            %VIEW View constructor.

            arguments ( Input )
                model(1, 1) Model
                namedArgs.?View
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@Component( model )

            % Listen for changes to the data.
            obj.Listener = listener( obj.Model, ...
                "DataChanged", @obj.onDataChanged );

            % Set any user-specified properties.
            set( obj, namedArgs )

            % Refresh the view.
            onDataChanged( obj )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the view.

            % Create the view graphics.
            ax = axes( "Parent", obj );
            obj.Line = line( ...
                "Parent", ax, ...
                "XData", NaN, ...
                "YData", NaN, ...
                "Color", ax.ColorOrder(1, :), ...
                "LineWidth", 1.5 );

        end % setup

        function update( obj )
            %UPDATE Update the view in response to changes in the public 
            %properties.

            set( obj.Line, "LineWidth", obj.LineWidth, ...
                "Color", obj.LineColor )

        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function onDataChanged( obj, ~, ~ )
            %ONDATACHANGED Listener callback, responding to the model event
            %"DataChanged".

            % Retrieve the most recent data and update the line.
            data = obj.Model.Data;
            set( obj.Line, "XData", 1:numel( data ), "YData", data )

        end % onDataChanged

    end % methods ( Access = private )

end % classdef