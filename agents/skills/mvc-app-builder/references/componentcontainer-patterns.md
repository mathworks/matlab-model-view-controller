# ComponentContainer Patterns

Use `matlab.ui.componentcontainer.ComponentContainer` as the default base for reusable MATLAB MVC view and controller classes.

## When to Use

Use `ComponentContainer` when the class:

- owns a reusable portion of the UI
- needs a parent assigned by a launcher or higher-level layout
- should encapsulate its own `setup` and UI lifecycle
- needs to be instantiated multiple times or composed with sibling components

Do not use it for the Model. The Model should remain a plain handle class with no UI dependency.

## Core Pattern

Typical MVC component classes should:

1. derive from `matlab.ui.componentcontainer.ComponentContainer`
2. accept the shared Model as the first constructor input
3. call the superclass constructor with `Parent=[]`
4. store the Model in an immutable or private property
5. create and store listeners in the constructor if needed
6. create graphics objects in `setup`
7. leave `update` empty unless public component properties drive UI changes

## Constructor Pattern

```matlab
classdef ResultsView < matlab.ui.componentcontainer.ComponentContainer
    properties (Access = private)
        Model (1,1) AppName.Model
        Listeners (:,1) event.listener = event.listener.empty
    end

    methods
        function obj = ResultsView(model, namedArgs)
            arguments
                model (1,1) AppName.Model
                namedArgs.?AppName.ResultsView
            end

            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                Parent=[], Units="normalized", Position=[0 0 1 1])

            obj.Model = model;
            obj.Listeners = [
                addlistener(model, "DataChanged", @(~,~) obj.onDataChanged())
            ];

            set(obj, namedArgs)
        end

        function delete(obj)
            delete(obj.Listeners)
        end
    end
end
```

## Setup and Update Pattern

Use `setup` to create the layout and graphics objects owned by the component.

```matlab
methods (Access = protected)
    function setup(obj)
        grid = uigridlayout(obj, [2 1]);
        uilabel(grid, Text="Results");
        uiaxes(grid);
    end

    function update(obj)
    end
end
```

Use `update` only when public component properties affect the UI. Do not move normal model-driven refresh logic into `update`.

## Shared Abstract Component Base Class

When several views and controllers need the same model property and the same listener wiring, create an abstract `Component` superclass.

Typical responsibilities:

- store the shared `Model`
- create common listeners in the constructor
- define abstract protected callbacks for subclasses

Pattern:

```matlab
classdef (Abstract) Component < matlab.ui.componentcontainer.ComponentContainer
    properties (GetAccess = protected, SetAccess = immutable)
        Model (1,1) AppName.Model
        DataChangedListener (:,1) event.listener {mustBeScalarOrEmpty}
    end

    methods
        function obj = Component(model)
            arguments
                model (1,1) AppName.Model
            end

            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                Parent=[], Units="normalized", Position=[0 0 1 1])

            obj.Model = model;
            obj.DataChangedListener = listener(model, ...
                "DataChanged", @obj.onDataChanged);
        end
    end

    methods (Abstract, Access = protected)
        onDataChanged(obj, ~, ~)
    end
end
```

Use this pattern only when multiple component classes genuinely share the same event subscriptions.

## View Patterns

Use `ComponentContainer` views to:

- render plots, tables, labels, images, or status displays
- listen to semantic model events
- refresh their own graphics from current model state

Views should:

- own only their own graphics objects
- keep listener callbacks short
- pull data from the model inside the callback

## Controller Patterns

Use `ComponentContainer` controllers to:

- own buttons, dropdowns, state buttons, keyboard controls, canvases, or toolstrips
- translate user actions into model method calls
- update controller-owned controls when model state changes

Controllers should:

- keep callbacks thin
- avoid redrawing view-owned graphics
- avoid storing domain state outside the model

## Layout Patterns

Prefer:

- `uigridlayout` for structural layout
- nested components for screen regions
- one component per responsibility-focused UI area

Avoid:

- large monolithic UI classes
- hard-coded figure-wide layout logic inside leaf components
- direct parent-child dependencies between sibling components

## Launcher Integration

The launcher or entry point should:

- create the figure
- create the shared model
- instantiate components with `Parent=...`
- place components into the top-level layout

Pattern:

```matlab
function app = runApp()
    fig = uifigure(Name="My App");
    grid = uigridlayout(fig, [3 1]);

    model = AppName.Model();
    headerView = AppName.HeaderView(model, Parent=grid);
    resultsView = AppName.ResultsView(model, Parent=grid);
    toolbarController = AppName.ToolbarController(model, Parent=grid);

    app.figure = fig;
    app.model = model;
    app.headerView = headerView;
    app.resultsView = resultsView;
    app.toolbarController = toolbarController;
end
```

## Quality Checks

- Component classes do not contain domain logic.
- The Model is not a `ComponentContainer`.
- Listener handles are stored and cleaned up.
- `setup` creates owned graphics only.
- `update` is used only for public-property-driven UI sync.
- Shared listener wiring is factored only when repetition is real.
