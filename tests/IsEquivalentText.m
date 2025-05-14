classdef IsEquivalentText < matlab.unittest.constraints.BooleanConstraint
    %ISEQUIVALENTTEXT Boolean constraint that determines if a text array
    %(string or cellstr) is equal to an expected text array. Size and/or
    %orientation is also ignored: the two arrays are compared as column
    %vectors.

    % Copyright 2025 The MathWorks, Inc.

    properties ( SetAccess = immutable )
        % Test array with the expected value.
        ArrayWithExpectedValue
    end % properties ( SetAccess = immutable )

    methods

        function constraint = IsEquivalentText( txt )

            % Check and assign the constructor input arguments.
            arguments ( Input )
                % The test array (convertible to string).
                txt(:, :) string
            end % arguments ( Input )

            constraint.ArrayWithExpectedValue = txt(:);

        end % constructor

        function tf = satisfiedBy( constraint, actual )

            tf = constraint.arrayMatchesExpected( actual );

        end % satisfiedBy

        function diag = getDiagnosticFor( constraint, actual )

            % Format a string diagnostic for the constraint.
            if constraint.arrayMatchesExpected( actual )
                status = "passed.";
            else
                status = "failed.";
            end % if

            diag = matlab.unittest.diagnostics.StringDiagnostic( ...
                "IsEquivalentText " + status );

        end % getDiagnosticFor

    end % methods

    methods ( Access = protected )

        function diag = getNegativeDiagnosticFor( constraint, actual )

            % Format a negative string diagnostic for the constraint.
            import matlab.unittest.diagnostics.StringDiagnostic

            if constraint.arrayMatchesExpected( actual )
                diag = StringDiagnostic( sprintf( ...
                    "Negated IsEquivalentText failed.\nActual and " + ...
                    "expected values were the same but should not" + ...
                    " have been." ) );
            else
                diag = ...
                    StringDiagnostic( "Negated IsEquivalentText passed." );
            end % if

        end % getNegativeDiagnosticFor

    end % methods ( Access = protected )

    methods ( Access = private )

        function tf = arrayMatchesExpected( constraint, actual )

            % Convert the actual value to a column vector of strings.
            actual = convertCharsToStrings( actual );
            actual = actual(:);

            % Create an IsEqualTo constraint.
            iseqto = matlab.unittest.constraints.IsEqualTo( ...
                constraint.ArrayWithExpectedValue );

            % Does the actual value satisfy the constraint, when converted
            % to a string column?
            tf = iseqto.satisfiedBy( actual(:) );

        end % arrayMatchesExpected

    end % methods ( Access = private )

end % classdef