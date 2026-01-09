function varargout = launchMVCApp( f )
%LAUNCHMVCAPP Launch the small MVC application.

% Copyright 2021-2025 The MathWorks, Inc.

arguments ( Input )
    f(1, 1) matlab.ui.Figure = uifigure()
end % arguments ( Input )

% Output check.
nargoutchk( 0, 1 )

% Rename the figure.
f.Name = "Small MVC App";

% Respond to theme changes.
f.ThemeChangedFcn = @onThemeChanged;

% Create the layout.
g = uigridlayout( ...
    "Parent", f, ...
    "RowHeight", {"1x", 40}, ...
    "ColumnWidth", "1x" );

% Create the model.
m = Model;

% Create the view.
View( m, "Parent", g );

% Create the controller.
Controller( m, "Parent", g );

% Create toolbar to reset the model.
tb = uitoolbar( "Parent", f );
iconLight = fullfile( "icons", "refresh_light.png" );
iconDark = fullfile( "icons", "refresh_dark.png" );
resetButton = uipushtool( ...
    "Parent", tb, ...    
    "Tooltip", "Reset the data", ...
    "ClickedCallback", @onReset );
onThemeChanged()

    function onReset( ~, ~ )
        %ONRESET Callback function for the toolbar reset button.

        % Reset the model.
        reset( m )

    end % onReset  

    function onThemeChanged( ~, ~ )
        %ONTHEMECHANGED Update the toolbar button icon when the figure
        %theme changes.

        switch f.Theme.Name
            case "Light Theme"
                resetButton.Icon = iconLight;
            case "Dark Theme"
                resetButton.Icon = iconDark;
        end % switch/case

    end % onThemeChanged

% Return the figure handle if requested.
if nargout == 1
    varargout{1} = f;
end % if

end % launchMVCApp