# Repository Guidelines

## Scope
* This file defines default contributor guidance that applies across repositories unless a repo-local `AGENTS.md` overrides it. 
* Prefer local project conventions when they conflict with this document.

## Communication Style
* Be direct and thorough. No sycophancy; never praise questions, validate premises, or open with agreement. If I'm wrong, lead with that.
* Hold your positions: don't capitulate to pushback without new evidence. Generate your own estimates before considering mine. State confidence levels explicitly (high/moderate/low/unknown).
* No disclaimers, no ethics commentary unless asked, no "it's important to consider" hedging. Negative conclusions are fine; deliver them clearly.
* Tone: precise, not diplomatic. Answers can be pointed and argumentative.
* Verify your own claims. If you don't know, say so; don't fabricate.
* Prefer long, detailed answers with full reasoning shown.

## Start With Context
* Inspect the repository before editing. Read the README, build or package entry points, test configuration, and recent history before making changes. 
* Avoid assumptions about architecture, tooling, or naming.

## Code Changes
* Keep edits minimal, targeted, and reversible. 
* Match the existing style of the repository, use ASCII unless the file already requires Unicode, and add brief comments only where logic is not obvious. 
* Do not rewrite unrelated code while addressing a focused task.

## Validation
* Run the smallest meaningful verification for the change, then escalate to broader checks if needed. 
* Prefer project-native commands such as test suites, linters, type checks, or build tasks. 
* If validation cannot be run, state that clearly.

## Git Hygiene
* Do not revert user changes you did not make. Avoid destructive commands such as `git reset --hard` unless explicitly requested. 
* Keep commit messages short, imperative, and specific to the behavioral change.

## Collaboration
* Communicate assumptions, constraints, and risks directly. 
* When a task is unclear, resolve it from local context first; ask only when a missing answer would create real risk. 
* Summaries should emphasize what changed, what was verified, and any remaining gaps.

## MATLAB Build, Test, and Development Commands
* Always open the MATLAB project before running code or tests, using the `openProject` function. Never use `addpath` when writing code or tests.
* Run build commands from the repository root:

```matlab
buildtool check
buildtool test
```
* `buildtoool check` enforces Code Analyzer and project checks. Run this for any non-trival review or change set.
* Run targeted tests with `runtests` for edits, for example `runtests("tests/backend/tWorkspace.m")`.
* Use `checkcode("path/to/file.m")` or MATLAB Code Analyzer during local iteration.
* Expect impacted-test execution to remain enabled in the build unless there is an explicit reason to change build policy.

## MATLAB Coding Style and Naming Conventions
* Use MATLAB style with 4-space indentation and one class/function per file.
* Always follow the prevailing spacing and commenting styles in the current project; do not mix styles.
* Do not exceed 75 characters per line of code, including any spaces and comments.
* Always add newly created files to the MATLAB project using the project APIs; do not bypass the project APIs.
* Always remove deleted files from the MATLAB project using the project APIs; do not bypass the project APIs.
* Follow the repo-level naming rules from `resources/codeAnalyzerConfigurations.json` if these exist.
* Classes and properties use `UpperCamelCase`.
* Use a trailing underscore only for a private backing property that pairs with a public property of the same base name.
* Functions/methods/local functions/nested functions use `lowerCamelCase` or `lowercase`.
* Prefer verb phrases for actions such as `appendLayers`, `renameCycle`, and `updateMemoryChart`.
* Name logical-valued properties as adjectives such as `Loaded` or `Connected`. Do not prefix them with `Is`.
* Name logical-returning methods and functions with `is*` or `has*`.
* Refer to instance objects as `obj` in production classes and `testCase` in tests. Do not use `this`.
* Refer to name-value structures as `namedArgs`.
* Test classes and methods start with `t` (for example, `tChannelSettings`, `tConstructorAcceptsNameValuePairs`).

## MATLAB Source Code Authoring Rules

* Use `arguments ( Input )` and `arguments ( Output )` blocks for validation instead of manual parsing where practical.
* Use `namedArgs.?ClassName` in constructors and methods when the class already follows that pattern.
* Prefer string scalars with `"` for user-facing text and modern APIs. Do not use character arrays unless unavoidable.
* Keep access control as narrow as possible. Make UI handles and listeners private unless tests need controlled access.
* Do not create ordinary class methods where the instance object is unused; instead, create local functions or private static methods, with a preference for local functions. This does not apply to unimplemented callbacks.
* Separate public API, protected lifecycle, and private callbacks/helpers instead of mixing responsibilities in one methods block.
* Use stable, namespaced error identifiers such as `Workspace:renameLayer:InvalidLayerIndex`.
* Write error and alert messages that state what failed and why.
* Restore temporary path or state changes with `onCleanup` when mutating global process state.
* Do not bypass project checks by removing assertions, weakening validation, or suppressing analyzer findings without a strong local reason.
* Do not leave unused code files, or unused properties or methods.
* Use `listener` to create listener objects; do not use `addlistener`.
* Prefer name, value syntax over name=value, e.g., `"LineWidth", 2` and not `LineWidth=2`.
* Always add size, type, and attribute validation for class properties and methods/functions that accept external inputs.

## MATLAB Frontend and UI Rules

* Keep UI construction inside `setup` for component-style classes unless the surrounding class already uses a different lifecycle.
* Use the constructor for listener wiring and superclass construction, not for large blocks of widget creation.
* Keep event handlers and button callbacks private and name them with the `onThingEvent` pattern already used in the project.
* Guard UI operations that require a figure ancestor, as in `ancestor( obj, "figure" )`, before opening dialogs or alerts.
* If the Test Framework Extensions toolbox is installed, expose test-only UI handles through `GetAccess = ?Testable` rather than widening the public API; otherwise, use `GetAccess = ?matlab.unittest.TestCase`.
* Keep `update` methods cheap and side-effect aware. Use them to refresh state, not to rebuild the whole object graph unless the class already follows that pattern.

## MATLAB Testing Guidelines
* Always add newly created test files to the MATLAB project, and ensure the testing folder structure mirrors that of the code.
* Name new test files `t<Subject>.m` and keep test methods behavior-focused. 
* Label new test files with the "Test" label using the project APIs; do not bypass the project APIs.
* Before opening a merge request, run `buildtool test` and confirm coverage artifacts are produced cleanly.
* Use `matlab.unittest.TestCase` for standard unit tests and `Testable` for UI tests that depend on `matlab.uitest.TestCase`.
* Store reusable fixtures in private test properties with explicit type and size validation when the surrounding tests do so.
* Add `TestClassSetup` checks for warning-free construction when constructor cleanliness is part of the contract.
* Use `TestMethodSetup` to rebuild state between tests instead of relying on cross-test mutation.
* Write assertion messages that explain the expected behavior, not just that something failed.
* When production code exposes internal state only for tests, prefer the established `?Testable` pattern over adding public getters just to satisfy tests.
* If the Test Framework Extensions toolbox is installed, do not convert data types when using `verifyEqual`; instead, use the `IsEquivalentText` for text comparison.
* If the Test Framework Extensions toolbox is installed, do not transpose arrays when using `verifyEqual`; instead, use the `IsEqualVector` constraint for vector comparison.

## MATLAB Code Review Checklist

* Confirm naming follows the project rules, especially class names, test names, logical properties, and `namedArgs`.
* Confirm argument validation is explicit and modern.
* Confirm access modifiers are no wider than needed.
* Confirm stateful cleanup is present for path, listener, file, or environment mutations.
* Confirm user-facing errors and alerts are specific and actionable.
* Confirm a matching test exists in `tests` for new behavior or a convincing reason is documented when tests are not practical.
* Confirm no new analyzer issues or dead files are introduced.
* Confirm release-critical files preserve packaging, test, and CI behavior.