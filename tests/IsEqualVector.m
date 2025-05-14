classdef IsEqualVector < matlab.unittest.constraints.BooleanConstraint
    %ISEQUALVECTOR Boolean constraint that determines if a given vector is
    %equal to an expected vector, up to row/column orientation.

    % Copyright 2025 The MathWorks, Inc.
    
    properties ( SetAccess = immutable )
        % Test vector with the expected value.
        VectorWithExpectedValue
        % Absolute tolerance value.
        AbsoluteTolerance
        % Relative tolerance value.
        RelativeTolerance
    end % properties ( SetAccess = immutable )
    
    methods
        
        function constraint = IsEqualVector( vector, opts )
            
            % Check and assign the constructor input arguments.
            arguments ( Input )
                % The test value (a vector).
                vector(:, 1) = NaN
                % Absolute tolerance used for comparison with the actual 
                % value.
                opts.AbsTol(1, 1) ...
                    matlab.unittest.constraints.AbsoluteTolerance = 0
                % Relative tolerance used for comparison with the actual
                % value.
                opts.RelTol(1, 1) ...
                    matlab.unittest.constraints.RelativeTolerance = 0
            end % arguments ( Input )
            
            constraint.VectorWithExpectedValue = vector;
            constraint.AbsoluteTolerance = opts.AbsTol;
            constraint.RelativeTolerance = opts.RelTol;
            
        end % constructor
        
        function tf = satisfiedBy( constraint, actual )
            
            tf = constraint.vectorMatchesExpected( actual );
            
        end % satisfiedBy
        
        function diag = getDiagnosticFor( constraint, actual )
            
            % Format a string diagnostic for the constraint.
            import matlab.unittest.diagnostics.StringDiagnostic
            
            if constraint.vectorMatchesExpected( actual )
                
                diag = StringDiagnostic( "IsEqualVector passed." );
                
            else
                
                diag = StringDiagnostic( sprintf( ...
                    "IsEqualVector failed.\nActual value: " + ...
                    "[%s]\nExpected value: [%s]", ...
                    num2str( actual(:).' ), ...
                    num2str( constraint.VectorWithExpectedValue(:).' ) ) );
                
            end % if
            
        end % getDiagnosticFor
        
    end % methods
    
    methods ( Access = protected )
        
        function diag = getNegativeDiagnosticFor( constraint, actual )
            
            % Format a negative string diagnostic for the constraint.
            import matlab.unittest.diagnostics.StringDiagnostic
            
            if constraint.vectorMatchesExpected( actual )
                
                diag = StringDiagnostic( sprintf( ...
                    "Negated IsEqualVector failed.\nActual and " + ...
                    "expected values were the same but should not" + ...
                    " have been." ) );
                
            else
                
                diag = StringDiagnostic( "Negated IsEqualVector passed." );
                
            end % if
            
        end % getNegativeDiagnosticFor
        
    end % methods ( Access = protected )
    
    methods ( Access = private )
        
        function tf = vectorMatchesExpected( constraint, actual )
            
            % Is the provided value a vector?
            sz = size( actual );
            assert( nnz( sz == 1 ) >= length( sz ) - 1, ...
                "The provided value is not a vector." )
            
            % Create an IsEqualTo constraint with the given tolerance.
            import matlab.unittest.constraints.*
            iseqto = IsEqualTo( constraint.VectorWithExpectedValue, ...
                "Within", constraint.AbsoluteTolerance | ...
                constraint.RelativeTolerance );
            
            % Does the actual value satisfy the constraint, when converted
            % to a column?
            tf = iseqto.satisfiedBy( actual(:) );
            
        end % vectorMatchesExpected
        
    end % methods ( Access = private )
    
end % classdef