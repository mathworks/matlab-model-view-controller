classdef tApp
    %TAPP Summary of this class goes here
    
    % Copyright 2025 The MathWorks, Inc.

    
    properties
        Property1
    end
    
    methods
        function obj = tApp(inputArg1,inputArg2)
            %TAPP Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

