<!--
SYNC IMPACT REPORT
==================
Version change: (none — initial constitution) → 1.0.0
Modified principles: N/A (initial ratification)
Added sections:
  - Core Principles (4 principles)
  - Development Standards
  - Quality Gates
  - Governance
Removed sections: N/A
Templates requiring updates:
  ✅ .specify/memory/constitution.md — this file
  ⚠ .specify/templates/plan-template.md — Constitution Check section should reference
      these four principles by name
  ⚠ .specify/templates/spec-template.md — no direct updates needed; aligns naturally
  ⚠ .specify/templates/tasks-template.md — task categories should reflect testing
      mandate (widget tests, integration tests) and performance budgets
Follow-up TODOs:
  - TODO(RATIFICATION_DATE): Confirm exact project inception date if earlier than
    2026-03-06 and update the Ratified field accordingly.
  - TODO(COVERAGE_THRESHOLD): Team should agree on minimum coverage % once a
    baseline run is available; placeholder is 80%.
-->

# Monster Livescore Constitution

## Core Principles

### I. Code Quality (NON-NEGOTIABLE)

All Dart/Flutter code MUST conform to the rules enforced by `flutter_lints` and the
project's `analysis_options.yaml`. No linting errors or warnings may be merged into
`main`. Beyond linting:

- Files MUST NOT exceed 300 lines; extract widgets, helpers, or services when
  approaching the limit.
- Every public class, method, and top-level function MUST have a doc comment
  (`///`) describing its purpose and non-obvious parameters.
- Business logic MUST live in services or notifiers—never directly in widget
  `build` methods.
- Magic numbers and strings MUST be declared as named constants in
  `lib/constants/app_constants.dart` or a domain-specific constants file.
- Dead code, commented-out blocks, and `TODO` items older than one sprint MUST be
  removed before a feature is considered done.

**Rationale**: A live-score application handles continuous real-time data streams.
Readable, well-structured code reduces defect rates and accelerates incident
response when score feeds behave unexpectedly.

### II. Testing Standards (NON-NEGOTIABLE)

Tests are a first-class artifact of every feature. The following minimums MUST be
met before any feature branch can be merged:

- **Unit tests** MUST cover all service classes, repository methods, and pure
  utility functions. Each public method requires at least one passing and one
  failure/edge-case test.
- **Widget tests** MUST be written for every new or modified widget that contains
  conditional rendering, state changes, or user interaction.
- **Integration tests** MUST cover critical user flows (e.g., viewing live match
  scores, refreshing data, navigating between screens).
- Overall test coverage MUST remain at or above **80%** (line coverage). PRs that
  drop coverage below this threshold MUST include a written justification and a
  remediation plan.
- Tests MUST use Flutter's built-in `flutter_test` tooling; mock HTTP responses
  with stub data rather than hitting live APIs in automated test runs.

**Rationale**: Score accuracy is the product's core value proposition. Regressions
in data display or navigation are directly visible to users; a robust test suite is
the primary defence against shipping broken scores.

### III. User Experience Consistency

The UI MUST present a coherent, predictable experience across all screens and
states:

- Every data-loading state MUST display a consistent loading indicator (skeleton
  screen or `CircularProgressIndicator`) aligned to the design system.
- Every error state MUST display a user-readable message and a retry action; silent
  failures are prohibited.
- Navigation patterns MUST follow Material Design conventions. Custom navigation
  gestures MUST be documented and validated against accessibility guidelines.
- Typography, spacing, and colour tokens MUST be sourced from a single
  `ThemeData`/design-token file; hardcoded colours or font sizes in widget files
  are prohibited.
- All interactive elements MUST meet WCAG 2.1 AA contrast requirements and provide
  semantic labels for screen readers.

**Rationale**: Sports fans check scores under pressure and in poor lighting. A
consistent, accessible UI reduces cognitive load and builds trust in the product.

### IV. Performance Requirements

The application MUST meet the following thresholds, measured on a mid-range Android
device (e.g., Pixel 4a) and an iPhone SE (3rd gen):

- **Frame rate**: The app MUST sustain 60 fps during normal scrolling and
  animations; jank frames (>16 ms) MUST NOT appear in critical scrollable lists.
- **API response handling**: Live score data MUST be displayed within **2 seconds**
  of a successful API response under a standard 4G connection.
- **Cold start**: App cold-start time MUST be under **3 seconds** to first
  meaningful paint.
- **Memory**: Steady-state memory usage MUST remain below **150 MB**; unbounded
  widget list rendering MUST use `ListView.builder` or equivalent lazy patterns.
- **Network efficiency**: Repeated identical requests within a 5-second window MUST
  be deduplicated or served from cache; Dio interceptors MUST be used for caching
  and retry logic.

**Rationale**: Live sports data is time-sensitive. Slow or jittery UI causes users
to abandon the app mid-match, directly harming retention.

## Development Standards

This section codifies non-negotiable technical practices that support the Core
Principles.

- **Flavors**: The app MUST build correctly for all three environments—`dev`,
  `staging`, `prod`—using the flavor configuration in `lib/config/flavor_config.dart`
  and the corresponding `.env.*` asset files. No environment-specific hard-coding is
  permitted outside these files.
- **State management**: Provider MUST be the sole state management solution unless
  a written architecture decision record (ADR) approves an alternative. Mixing
  patterns (e.g., `setState` alongside Provider for the same state) is prohibited.
- **Logging**: The `logger` package MUST be used for all diagnostic output.
  `print()` statements are prohibited in committed code. Log levels MUST be set
  appropriately per environment (verbose in dev, errors-only in prod).
- **Secrets**: API keys, tokens, and credentials MUST NEVER be committed to source
  control. They MUST be loaded exclusively via `flutter_dotenv` from `.env.*` files
  that are listed in `.gitignore`.
- **Dependency updates**: Dependencies MUST be reviewed for security advisories at
  least once per release cycle. `flutter pub outdated` output MUST be reviewed and
  action taken on critical CVEs within 5 business days.

## Quality Gates

Every pull request targeting `main` or `develop` MUST pass the following gates
before merge approval is granted:

1. `flutter analyze` — zero errors, zero warnings.
2. `flutter test --coverage` — coverage at or above 80%.
3. All CI integration test suites pass (dev flavor).
4. At least one peer code review approval from a team member who did not author the
   PR.
5. No new hardcoded colours, strings, or magic numbers introduced (verified via
   review checklist).
6. Performance: If the PR modifies list rendering or API data paths, a profiling
   note MUST confirm no new jank frames were introduced (manual or DevTools trace).

Features that fail any gate MUST NOT be merged. Exceptions require written approval
from the tech lead and MUST be tracked as tech-debt issues.

## Governance

This constitution supersedes all other verbal or documented conventions. Amendments
follow this procedure:

1. Author opens a PR modifying `.specify/memory/constitution.md` with a clear
   rationale in the PR description.
2. Version MUST be bumped according to semantic versioning:
   - **MAJOR**: Removal or breaking redefinition of a principle.
   - **MINOR**: New principle or section added.
   - **PATCH**: Wording clarification, typo fix, or non-semantic refinement.
3. Amendment MUST be approved by at least two team members, including the tech lead.
4. Once merged, all dependent templates (plan, spec, tasks) MUST be reviewed and
   updated within the same sprint.
5. Compliance review MUST be conducted at the start of each release cycle; findings
   MUST be logged as issues.

All PRs and code reviews MUST verify compliance with the four Core Principles. Where
a principle cannot be met, the deviation MUST be documented, time-boxed, and tracked
as a tech-debt item with a remediation milestone.

**Version**: 1.0.0 | **Ratified**: 2026-03-06 | **Last Amended**: 2026-03-06
