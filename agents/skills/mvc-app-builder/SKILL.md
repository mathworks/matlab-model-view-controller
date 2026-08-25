---
name: mvc-app-builder
description: >
  Build, refactor, and extend MATLAB apps using the Model-View-Controller
  pattern for maintainable applications. Use when a user wants
  to build a medium to large MATLAB app, create a GUI, make an interactive tool. Also when the user describes the organization around a shared handle model, semantic model events,
  package-based app structure such as `+AppName`, `ComponentContainer` UI
  classes, a shared abstract `Component` superclass, and a separate
  launcher or composition root that wires many focused views and
  controllers around a shared model.
---

# MVC App Builder

Build MATLAB apps with a concrete MVC structure.

Prefer the patterns used by strong MATLAB MVC examples:

- a package folder such as `+wordScramble` or `+quickdraw`
- one shared handle `Model`
- many focused `View` and `Controller` classes
- a shared abstract `Component` base class when several UI classes listen to the same model
- semantic model events such as `WordChosen`, `PredictionMade`, or `RefreshPushed`
- a top-level `Launcher`, `runApp`, or `LaunchApp` file that assembles the application

## When to Use This Skill

Use this skill when:
- User wants to build a medium to large MATLAB app, GUI, or interactive tool.
- User mentions that the app needs to respect the MVC design pattern.
- User mentions that the app needs to be maintainable and contain different classes.
- User mentions: MVC, Model View Controller, View, Model, Controller, classes, launcher

## When Not to Use

- User mentions wanting to create an app in App Designer
- The request is purely about MATLAB computation with no UI component

## Objective

Separate the application into:

- `Model`: domain state, domain methods, validation, and event broadcasts
- `Views`: multiple UI components that reveal different slices of model state
- `Controllers`: multiple UI components that collect user input and invoke model methods
- `Launcher` or composition root: top-level assembly that creates the figure, model, many views/controllers, and app-level wiring

Use MATLAB patterns that align with the reference apps:

- Handle classes for the model and other long-lived app objects
- `matlab.ui.componentcontainer.ComponentContainer` for reusable views and controllers
- MATLAB package folders for nontrivial apps
- Semantic events on the model rather than direct model-to-view references
- A shared `Component` superclass when multiple UI classes need the same model reference and listener setup
- Composition from many specialized UI components rather than one monolithic view/controller pair

## Critical Rules

- Keep business logic and application state in the model, not in UI callbacks.
- You should be able to use the app and all its functionalities programmatically just using the Model class.
- Keep the model free of UI objects, layout code, and figure logic.
- Use semantic model events that describe domain actions or state transitions.
- Let views and controllers hold references to the model; do not let the model reference them.
- Use a shared abstract `Component` superclass when multiple UI classes repeat the same listener wiring.
- Keep app assembly in a separate `Launcher`, `runApp`, or similar entry point.
- Use MATLAB package folders for nontrivial apps unless the user explicitly wants a single-file prototype.
- Validate constructor inputs and public method inputs with `arguments` blocks.

## Workflow

```text
User request arrives
        |
        v
Identify the app's domain state, user actions, and visible surfaces
        |
        v
Choose the package and composition-root structure
        |
        v
Define the Model API and semantic events
        |
        v
Decide whether a shared abstract Component base class is warranted
        |
        v
Implement many focused View and Controller components around the shared Model
        |
        v
Assemble the app in Launcher/runApp/LaunchApp
        |
        v
Verify callback -> model -> notify -> listener -> UI flow
```

## Discovery Guidance

Clarify these points before building or refactoring:

- What state must persist for the whole app session?
- What user actions mutate that state?
- What visual surfaces need to update when that state changes?
- Should the app be a package-based app such as `+AppName`?
- Does the app need a separate launcher/composition root?
- Are there repeated model listeners across many components that justify a shared `Component` base class?
- Does the app need supporting assets or helper classes such as `Theme`, icons, sounds, or helper utilities?

If the user already provided enough structure, proceed directly.

## MVC Responsibilities

### Model

The model is the single source of truth for application state.

The model should:

- Store domain state in properties
- Expose public methods that mutate state in controlled ways
- Broadcast semantic events after meaningful state changes
- Avoid any dependency on graphics objects or layout containers
- Remain usable and testable without creating UI

Prefer patterns such as:

- `classdef Model < handle`
- `properties (SetAccess = private)` for protected state
- `events` or `events (NotifyAccess = private)` for event definitions
- public methods such as `startRound`, `reset`, `submitWord`, `selectCategory`, `predictCategory`

Do not reduce the model to raw data storage only. In the reference apps, the model owns real workflow logic.

### Shared Component Base Class

When several views and controllers all need the same model reference and the same listener setup, create an abstract `Component` superclass.

The component base should usually:

- derive from `matlab.ui.componentcontainer.ComponentContainer`
- store the shared `Model`
- create listener properties in the constructor
- provide abstract protected callbacks such as `onWordChosen`, `onPredictionMade`, `refresh`, or `enter`

Use this pattern only when it removes genuine repetition. Do not create a base class for a single component.

### View

Views reveal model state and respond to model events.

The views should:

- create and own the graphics objects it presents
- refresh its UI from current model state inside listener callbacks
- keep formatting and display details local to the component
- avoid owning domain logic

Views can be lightweight display components such as:

- score headers
- category labels
- result tables
- plot or image displays
- message or status panels
- instruction panels
- timers, clocks, and progress displays

Views may call an initial sync method in the constructor when the displayed state must be correct immediately after construction.

Do not force unrelated presentation into one large view class. Split the UI by responsibility and by area of the screen.

### Controller

Controllers collect user input and invoke model methods.

The controllers should:

- own buttons, fields, state buttons, dropdowns, canvas interactions, or keyboard controls
- translate UI actions into model method calls
- update controller-owned control state when model events require it
- avoid taking over view-owned presentation responsibilities
- stay focused on one interaction cluster such as a toolbar, keyboard, local action area, or canvas

In MATLAB MVC, controllers are often also event listeners because controller-owned controls may need to react to model events. That is acceptable when the controller is updating its own controls, not rendering somebody else's view.

Do not force all interactions into one controller class. Prefer several small controllers over one monolithic interaction class.

## MATLAB-Specific Design Rules

### Package Structure

For maintainable apps, prefer package-based organization:

```text
+AppName/
+-- Model.m
+-- Component.m
+-- Launcher.m
+-- Theme.m
+-- View1.m
+-- View2.m
+-- Controller1.m
+-- helpers...
```

Use a package when the app has multiple classes, helper utilities, or assets.

### ComponentContainer Pattern

Views and controllers should usually derive from `ComponentContainer` so they can be created as reusable UI building blocks.

Common constructor pattern:

- call the superclass constructor with `Parent=[]`
- store the model
- create listeners
- apply `namedArgs`

Common implementation pattern:

- `setup` creates UI objects and layouts
- `update` is empty unless the component exposes public properties that affect rendering

### Semantic Events

Prefer semantic event names over generic property-change events.

Good examples:

- `WordChosen`
- `RoundFinished`
- `GameReset`
- `CategorySelected`
- `PredictionMade`
- `RefreshPushed`

These event names encode app behavior clearly and make listeners easier to reason about.

### Composition Root

Keep the top-level app assembly separate from component classes.

Typical responsibilities of `Launcher`, `runApp`, or `LaunchWordle`:

- create the figure
- create the model
- create views and controllers
- parent components into layouts, tabs, or card panels
- add app-level listeners or menu wiring
- manage lifecycle concerns that are broader than one component

Do not bury whole-app composition inside an individual view or controller.

### Supporting Classes and Assets

For richer apps, supporting classes are part of the architecture:

- `Theme` for fonts, colors, and sizing tokens
- helper classes for sounds, timers, or utility functions
- icons, sounds, and other assets referenced by controllers or launcher code

Keep these concerns outside the model unless they are genuinely part of domain behavior.

## File Organization

Recommended responsibilities:

- `Model.m`: domain state, methods, events
- `Component.m`: shared model/listener scaffolding for UI components
- `*View.m`: multiple focused display-oriented components
- `*Controller.m`: multiple focused interaction-oriented components
- `Launcher.m` or `runApp.m`: app assembly and figure-level orchestration
- `Theme.m` and helpers: styling and support infrastructure

## Build Sequence

When implementing an MVC app, follow this order:

1. Choose the package name and top-level assembly pattern.
2. Define the model state, public methods, and semantic events.
3. Add a shared `Component` superclass if multiple UI classes need the same listener scaffolding.
4. Partition the UI into many focused view and controller components around the shared model.
5. Create the launcher or entry point that wires the app together.
6. Verify every important interaction as a flow from callback to model to event to UI update.
7. Add helper classes, themes, and assets only after the core event flow works.

## Refactoring Guidance

When refactoring an existing MATLAB app into MVC:

1. Identify all domain state currently mixed into app properties or callback code.
2. Move domain state and workflow methods into a model class.
3. Define semantic events for the state transitions that other components care about.
4. Split monolithic UI code into many focused view and controller components.
5. Introduce a shared `Component` base class only if listener wiring is repeating across several classes.
6. Move figure-level wiring and assembly into a launcher or entry-point file.
7. Preserve behavior first; refine architecture second.

Common code smells to fix:

- one large app class mixing state, rendering, and user interaction
- callbacks that compute domain logic and repaint the UI directly
- duplicated listener setup across many UI classes
- whole-app assembly hidden inside one component class
- generic events that do not reveal what actually happened

## Quality Checks

Before finishing, verify:

- The model contains domain logic but no UI dependencies.
- Events are semantic and match real app transitions.
- Views and controllers share one model instance.
- Repeated listener wiring has been factored sensibly, not over-engineered.
- The UI is decomposed into multiple responsibility-focused views and controllers.
- Controllers update controller-owned controls only.
- Views refresh from model state rather than stale cached values.
- The launcher or entry point owns app-level composition.
- Package structure, naming, and helper classes are consistent across the app.

## Output Expectations

When using this skill, produce:

- a recommended package and file layout
- a proposed event map between model and UI components
- MATLAB code organized into one model, a component base when needed, many focused views/controllers, and a launcher where appropriate
- concise reasoning for whether the app needs a shared `Component` base class
- refactoring guidance that preserves working behavior while improving structure

## References

Use bundled references when available:

- `references/mvc-guide.md` for detailed MVC class and event patterns
- `references/componentcontainer-patterns.md` for reusable UI component structure
- `assets/examples/` for packaged reference apps when the skill includes them

If packaged reference apps are bundled with the skill, inspect the closest example first and reuse its composition patterns before inventing a new structure.
