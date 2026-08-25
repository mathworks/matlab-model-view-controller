# MATLAB MVC Guide

Structure MATLAB apps using the Model-View-Controller pattern. This guide provides the architectural layer: class design, model events, many focused view/controller components, and separation of responsibilities for maintainable applications.

## Critical Rules

- MUST separate Model, Views, and Controllers into distinct classes
- MUST keep application state and business logic in the Model
- MUST keep rendering and graphics refresh logic in Views
- MUST keep user interaction handling and callback orchestration in Controllers
- MUST implement MVC classes as handle classes
- MUST use model events and view listeners for state-driven UI refresh
- MUST clean up all listeners in class destructors (`delete` method)
- NEVER put UI component creation in the Model
- NEVER put business logic or data transformation in Views
- NEVER let the Model reference Views or Controllers
- ALWAYS use `arguments` blocks to validate constructor inputs and public methods

## Architecture Overview

```text
+AppName/
+-- +Models/
|   +-- AppModel.m                 % Data, state, business logic, events
+-- +Views/
|   +-- HeaderView.m               % Status, title, or summary display
|   +-- ResultsView.m              % Tables, plots, or images
|   +-- ImageView.m                % Specialized image display component
+-- +Controllers/
|   +-- ToolstripController.m      % Top-level commands or ribbon actions
|   +-- InputController.m          % Local buttons, fields, or action clusters
|   +-- CanvasController.m         % Direct-manipulation interactions
+-- +Components/
|   +-- Component.m                % Optional shared model/listener base class
+-- Launcher.m                     % Entry point and app assembly
```

Event flow:
1. User interacts with a control owned by a Controller
2. That Controller callback invokes a Model method
3. Model updates state
4. Model broadcasts an event with `notify(...)`
5. Relevant View listener callbacks refresh their parts of the UI from Model state

```text
User -> Controller -> Model -> notify(EventName) -> Views
```

Object references:

- Each Controller that needs domain access holds a reference to the Model
- Each View that needs state for refresh holds a reference to the Model
- Model holds no references to Views or Controllers

This keeps the Model independent and testable while allowing many small Views and Controllers to respond to a shared source of truth.

## Model

The Model owns app data, state transitions, validation, and domain operations. It extends `handle` so the app operates on one live state object.

```matlab
classdef AppModel < handle
    properties (SetAccess = private)
        Data double = []
        IsDirty logical = false
        Status string = "Ready"
    end

    events (NotifyAccess = private)
        DataChanged
        StateChanged
    end

    methods
        function loadData(obj, newData)
            arguments
                obj
                newData double
            end

            obj.Data = newData(:);
            obj.IsDirty = true;
            obj.Status = "Loaded";
            notify(obj, "DataChanged");
            notify(obj, "StateChanged");
        end

        function reset(obj)
            obj.Data = [];
            obj.IsDirty = false;
            obj.Status = "Reset";
            notify(obj, "DataChanged");
            notify(obj, "StateChanged");
        end
    end
end
```

### Model Design Guidelines

- Expose methods for state changes instead of allowing uncontrolled property mutation
- Broadcast events immediately after relevant state changes
- Use constrained property access to protect invariants
- Keep the Model free of `uifigure`, axes, buttons, layouts, or callback handles
- Make Model methods usable and testable without any UI present

## Shared Component Base Class

When several view/controller classes all need the same model property and listener creation pattern, factor that repeated code into an abstract `Component` superclass.

Typical responsibilities:

- derive from `matlab.ui.componentcontainer.ComponentContainer`
- store the shared `Model`
- create relevant listener properties in the constructor
- define abstract protected listener callbacks for subclasses to implement

Use this pattern only when several components genuinely share the same listener scaffolding.

## Views

Views render Model state and refresh in response to Model events. Each view manages its own graphics objects and listeners, but does not own business logic.

```matlab
classdef ResultsView < matlab.ui.componentcontainer.ComponentContainer
    properties (Access = private)
        Model (1,1) AppName.Models.AppModel
        Grid matlab.ui.container.GridLayout
        Axes matlab.ui.control.UIAxes
        Line matlab.graphics.chart.primitive.Line
        StatusLabel matlab.ui.control.Label
        Listeners (:,1) event.listener = event.listener.empty
    end

    methods
        function obj = ResultsView(model, namedArgs)
            arguments
                model (1,1) AppName.Models.AppModel
                namedArgs.?AppName.Views.ResultsView
            end

            obj.Model = model;
            obj.Listeners = [
                addlistener(model, "DataChanged", @(~,~) obj.onDataChanged())
                addlistener(model, "StateChanged", @(~,~) obj.onStateChanged())
            ];

            set(obj, namedArgs);
        end

        function delete(obj)
            delete(obj.Listeners);
        end
    end

    methods (Access = protected)
        function setup(obj)
            obj.Grid = uigridlayout(obj, [2 1]);
            obj.Axes = uiaxes(obj.Grid);
            obj.StatusLabel = uilabel(obj.Grid, Text="Ready");
            obj.Line = plot(obj.Axes, NaN, NaN);
        end

        function update(obj)
        end
    end

    methods (Access = private)
        function onDataChanged(obj)
            data = obj.Model.Data;
            set(obj.Line, XData=1:numel(data), YData=data);
        end

        function onStateChanged(obj)
            obj.StatusLabel.Text = obj.Model.Status;
        end
    end
end
```

### View Design Guidelines

- Split the UI into multiple focused views rather than one giant view class
- Create and own graphics objects in each View
- Store listeners as properties so they remain alive
- Refresh the UI by reading current Model state inside listener callbacks
- Use `setup` for object creation and `update` only for public-property-driven refresh
- Keep formatting and visual presentation here, not state transitions

Typical views include:

- headers and status bands
- results displays
- image or plot panels
- category or instruction displays
- timers, clocks, and progress indicators

## Controllers

Controllers provide controls and callbacks that translate user actions into Model operations.

```matlab
classdef ToolstripController < matlab.ui.componentcontainer.ComponentContainer
    properties (Access = private)
        Model (1,1) AppName.Models.AppModel
        Grid matlab.ui.container.GridLayout
        LoadButton matlab.ui.control.Button
        ResetButton matlab.ui.control.Button
    end

    methods
        function obj = ToolstripController(model, namedArgs)
            arguments
                model (1,1) AppName.Models.AppModel
                namedArgs.?AppName.Controllers.ToolstripController
            end

            obj.Model = model;
            set(obj, namedArgs);
        end
    end

    methods (Access = protected)
        function setup(obj)
            obj.Grid = uigridlayout(obj, [1 2]);
            obj.LoadButton = uibutton(obj.Grid, Text="Load", ...
                ButtonPushedFcn=@(~,~) obj.onLoadButtonPushed());
            obj.ResetButton = uibutton(obj.Grid, Text="Reset", ...
                ButtonPushedFcn=@(~,~) obj.onResetButtonPushed());
        end

        function update(obj)
        end
    end

    methods (Access = private)
        function onLoadButtonPushed(obj)
            newData = rand(20, 1);
            obj.Model.loadData(newData);
        end

        function onResetButtonPushed(obj)
            obj.Model.reset();
        end
    end
end
```

### Controller Design Guidelines

- Split interaction logic into multiple focused controllers rather than one giant controller
- Keep callbacks thin: validate inputs, invoke Model methods, handle light control flow
- Do not store domain state in UI control values alone
- Do not redraw plots or mutate view graphics directly from controller callbacks
- Group related controls into reusable controller components

Typical controllers include:

- toolstrip or toolbar controllers
- button clusters for a local action area
- keyboard-style controllers
- canvas or direct-manipulation controllers
- dialog or submission controllers

## Entry Point

The entry point creates the figure, instantiates the Model, then assembles many Views and Controllers into the top-level layout.

```matlab
function app = runApp()
    fig = uifigure(Name="MVC App");
    grid = uigridlayout(fig, [2 1]);

    model = AppName.Models.AppModel();
    headerView = AppName.Views.HeaderView(model, Parent=grid);
    resultsView = AppName.Views.ResultsView(model, Parent=grid);
    toolstripController = AppName.Controllers.ToolstripController(model, Parent=grid);

    app.figure = fig;
    app.model = model;
    app.headerView = headerView;
    app.resultsView = resultsView;
    app.toolstripController = toolstripController;
end
```

**Usage:** `app = AppName.runApp();`

Return a struct to keep object references alive and make cleanup predictable.

## Refactoring Existing Apps into MVC

When refactoring a legacy MATLAB app:

1. Identify all persistent app state currently stored in app properties or UI values
2. Move domain state and domain methods into a Model class
3. Move plotting, labels, tables, and visual updates into several focused View classes
4. Move callback bodies into several focused Controller classes
5. Replace direct callback-to-plot updates with Model methods and events
6. Split large monolithic classes only after behavior is preserved

Typical migration targets:

- callback code that computes and redraws in one method
- app properties that mix data, graphics handles, and user workflow state
- duplicated button or drop-down callback logic
- view code reading control values instead of Model state

## Async Operations

For long-running Model operations, keep the UI responsive by running the heavy work outside the UI callback, then updating the Model on completion.

Pattern:

1. A Controller starts an asynchronous task
2. Completion callback writes results back into the Model
3. Model broadcasts events
4. affected Views refresh automatically

Do not mutate View graphics directly from background execution paths.

## Testing Strategy

MVC improves testability because the Model can be tested without UI, and Controller behavior can often be tested through Model side effects.

Test at these levels:

- Model unit tests for state transitions, validation, and event-triggering methods
- Integration tests for controller-to-model interactions
- UI smoke tests for View refresh and listener wiring

Focus most automated tests on the Model first.

## Composition Guidance

| Case | Recommended MVC Shape |
|------|------------------------|
| Small app | One Model, a few focused Views/Controllers |
| Multi-panel app | One shared Model, multiple focused Views and Controllers |
| Reusable area | Extract subview/subcontroller pair under `components/` |
| Complex domain | Keep one top-level app shell and split Model responsibilities carefully |

Use a shared base class only when several views or controllers truly repeat lifecycle or wiring code.

## Implementation Checklist

- [ ] Package folder structure defined clearly
- [ ] Model extends `handle`
- [ ] Model owns state and domain logic only
- [ ] Model defines custom events for meaningful state changes
- [ ] Views are split by UI responsibility, not collapsed into one class
- [ ] Controllers are split by interaction responsibility, not collapsed into one class
- [ ] Each View listens to Model events and refreshes its UI from Model state
- [ ] Views store and delete listeners correctly
- [ ] Controllers own controls and callback functions
- [ ] Controller callbacks invoke Model methods rather than editing graphics
- [ ] Entry point wires the Model, Views, and Controllers together cleanly
- [ ] Refactoring preserves behavior before deeper architecture cleanup

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| A View is not refreshing | No listener on Model event | Add `addlistener(model, "EventName", @cb)` and ensure the callback updates that View's UI |
| Listener never fires | Model never calls `notify(...)` | Broadcast the event after the state change |
| Invalid or deleted object error | Listener survives after component destruction | Delete listeners in `delete()` |
| Model state drifts from UI | A Controller writes directly to graphics instead of the Model | Move state changes into Model methods |
| Circular updates | A View callback or Controller triggers redundant state writes | Add guard logic or compare values before updating |
| Hard-to-test app | Business logic still lives in callback code | Move domain logic into Model methods and retest |

## References

Use this guide together with:

- `SKILL.md` for high-level routing and build guidance
- `references/componentcontainer-patterns.md` for reusable UI component structure
- `references/refactor-playbook.md` for migration steps from legacy MATLAB apps
