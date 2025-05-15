classdef NotifiesEvent < matlab.unittest.internal.constraints...
        .NegatableConstraint & handle
    %NOTIFIESEVENT Custom constraint for testing whether an event is
    %notified by a handle object under a given operation.

    % Copyright 2025 The MathWorks, Inc.

    properties ( SetAccess = immutable )
        % Source of the event.
        EventSource(:, 1) handle {mustBeScalarOrEmpty} = gobjects( 0, 1 )
        % Name of the event.
        EventName(1, 1) string = ""
    end % properties ( SetAccess = immutable )

    properties ( Access = private )
        % Indicator for the test passing.
        TestPassed(1, :) logical = logical.empty( 1, 0 )
        % Evaluated function.
        EvaluatedFunction(1, :) function_handle = ...
            function_handle.empty( 1, 0 )
    end % properties ( Access = private )

    methods

        function obj = NotifiesEvent( eventSource, eventName )

            obj.EventSource = eventSource;
            obj.EventName = eventName;

        end % constructor

        function tf = satisfiedBy( obj, fcnToCall )

            tf = obj.evaluateConstraint( fcnToCall );

        end % satisfiedBy

        function diagnostic = getDiagnosticFor( obj, fcn )

            diagnostic = obj.getGenericDiagnosticFor( fcn, false );

        end % getDiagnosticFor

    end % methods

    methods ( Access = protected )

        function diagnostic = getNegativeDiagnosticFor( obj, fcn )

            diagnostic = obj.getGenericDiagnosticFor( fcn, true );

        end % getNegativeDiagnosticFor

        function diagnostic = getGenericDiagnosticFor( obj, fcn, isNegated )

            obj.evaluateConstraint( fcn );

            if isNegated
                posStr = " not ";
                negStr = " ";
            else
                posStr = " ";
                negStr = " not ";
            end % if

            fcnName = func2str( fcn );

            if obj.TestPassed
                str = "Event " + obj.EventName + " was" + ...
                    posStr + "notified by " + fcnName;
            elseif ~obj.TestPassed
                str = "Event " + obj.EventName + " was" + ...
                    negStr + "notified by " + fcnName;
            else
                str = "The test has not been run yet";
            end % if

            diagnostic = matlab.unittest.diagnostics...
                .StringDiagnostic( str );

        end % getGenericDiagnosticFor

        function tf = evaluateConstraint( obj, fcnToCall )

            % If function has already been evaluated with this function
            % handle, don't re-evaluate.
            if ~isempty( obj.EvaluatedFunction ) && ...
                    isequal( obj.EvaluatedFunction, fcnToCall )
                tf = obj.TestPassed;
                return
            end % if

            % Default state is to assume a failure.
            tf = false;

            % Add a listener to the event source for the desired event
            listener( obj.EventSource, obj.EventName, @onEventFired );

            % Run the function
            fcnToCall();

            % Store the result
            obj.TestPassed = tf;
            obj.EvaluatedFunction = fcnToCall;

            function onEventFired( ~, ~ )

                tf = true;

            end % onEventFired

        end % evaluateConstraint

    end % methods ( Access = protected )

end % classdef