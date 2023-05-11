classdef Model < handle
    %MODEL Application data model.
    %
    % Copyright 2021-2022 The MathWorks, Inc.
    
    properties ( SetAccess = private )
        % Application data.
        Data(:, 1) double = double.empty( 0, 1 )
    end % properties ( SetAccess = private )
    
    events ( NotifyAccess = private )
        % Event broadcast when the data is changed.
        DataChanged
    end % events ( NotifyAccess = private )
    
    methods
        
        function random( obj )
            %RANDOM Generate new application data.
            
            % Generate column vector of random data.
            obj.Data = randn( 20, 1 );
            notify( obj, "DataChanged" )
            
        end % random
        
        function reset( obj )
            %RESET Restore the application data to its default value.
            
            % Reset the data to an empty column vector.
            obj.Data = double.empty( 0, 1 );
            notify( obj, "DataChanged" )
            
        end % reset
        
    end % methods
    
end % classdef