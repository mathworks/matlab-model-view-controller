classdef View < Component
    %VIEW Visualizes the data, responding to any relevant model events.
    %
    % Copyright 2021-2022 The MathWorks, Inc.

    properties ( Access = private )
        % Line object used to visualize the model data.
        Line(1, 1) matlab.graphics.primitive.Line
        % Listener object used to respond dynamically to model events.
        Listener(:, 1) event.listener {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = View( model, namedArgs )
            %VIEW View constructor.

            arguments
                model(1, 1) Model
                namedArgs.?View
            end % arguments

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

        function update( ~ )
            %UPDATE Update the view. This method is empty because there are
            %no public properties of the view.

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