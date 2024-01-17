classdef FigureFixture < matlab.unittest.fixtures.Fixture
    %FIGUREFIXTURE Custom test fixture.
    
    properties ( SetAccess = private )
        % Test figure.
        Figure(:, 1) matlab.ui.Figure {mustBeScalarOrEmpty}        
    end % properties ( SetAccess = private )
    
    methods
        
        function setup( fixture )
            
            % Create a new figure.
            fixture.Figure = uifigure();
            % Define the teardown action.
            fixture.addTeardown( @() delete( fixture.Figure ) )
            
        end % setup
        
        function fixture = FigureFixture()
            
            % Add descriptions.
            fixture.SetupDescription = "Create a new uifigure.";
            fixture.TeardownDescription = "Delete the uifigure.";
            
        end % constructor
        
    end % methods
    
end % classdef