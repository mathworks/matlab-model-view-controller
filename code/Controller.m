classdef Controller < Component
    %CONTROLLER Provides an interactive control to generate new data.
    %
    % Copyright 2021-2022 The MathWorks, Inc.
    
    methods
        
        function obj = Controller( model, namedArgs )
            % CONTROLLER Controller constructor.
            
            arguments
                model(1, 1) Model
                namedArgs.?Controller
            end % arguments
            
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
            uibutton( ...
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