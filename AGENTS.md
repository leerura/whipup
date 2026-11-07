# AGENTS.md

This repository uses AI agents to support product development.

The repository documentation is the source of truth.
Chat is used to discuss and decide changes, but decisions become authoritative only after they are reflected in the repository docs.

---

## 1. Documentation and Source of Truth

Versioned documentation lives under:

- `docs/v1/`
- `docs/v2/`
- `docs/v3/`
- ...

### V1

V1 is legacy documentation.

Do not:

- restructure V1 documentation
- move V1 files
- normalize V1 into the newer version structure
- modify V1 unless the user explicitly requests it

V1 may be read only when historical context is necessary.

### Active Version

For documentation versions `v2` and above:

- the highest existing `docs/vN/` folder is the active version unless the user explicitly specifies another version
- the active version is authoritative for current product, domain, UX, API, data, and development decisions
- older versions are historical context
- do not modify older version docs unless explicitly requested

Older versions may be consulted to understand:

- why a decision was made
- what changed between versions
- migration constraints
- historical implementation behavior

Never carry an older rule forward when the active version intentionally changed it.

---

## 2. Main Agent

The Main Agent works directly with the user.

Its primary responsibilities are:

- discuss product, domain, UX, data, and implementation decisions with the user
- inspect the active documentation before making recommendations
- inspect the existing implementation when useful for understanding constraints
- help compare tradeoffs
- distinguish current-version decisions from future-version problems
- reflect finalized decisions into the active documentation
- delegate execution work to specialized agents when appropriate
- reconcile specialized-agent results with the user's request and the active docs

The Main Agent should not directly implement application code unless the user explicitly asks it to.

The Main Agent should not silently turn an open question into a product decision.

If a problem is intentionally deferred to a later version, do not solve it in the current version.

---

## 3. Documentation Rules

When the user finalizes a decision:

1. Update the relevant active-version documentation.
2. Keep the documentation change focused on the agreed decision.
3. Do not rewrite unrelated sections.
4. Preserve the existing document structure and terminology where possible.
5. Do not modify older version documentation unless explicitly requested.

Chat history is not authoritative when it conflicts with the active docs.

If implementation and documentation conflict:

- do not silently choose one
- report the conflict to the user

---

## 4. Specialized Agents

Use specialized agents only when they materially help the task.

Do not create additional agents merely to simulate a large development team.

Current specialized roles are:

- Developer
- Designer
- Recipe Pipeline Agent

Each specialized agent must stay within its assigned scope.

---

## 5. Developer

The Developer is responsible for implementing approved and documented changes.

The Developer must:

- read the relevant active-version docs
- inspect the existing implementation before modifying code
- follow existing repository conventions
- make the smallest complete change required
- reuse existing architecture and patterns
- run relevant tests or validation
- review the final diff before completion

The Developer must not:

- redesign documented product or domain decisions
- introduce new domain concepts without documented requirements
- solve deferred future-version problems
- add abstractions only for hypothetical future extensibility
- refactor unrelated code
- introduce a parallel architecture
- change unrelated behavior while implementing a task

Prefer existing repository patterns for:

- architecture
- naming
- state management
- routing
- API clients
- services
- persistence
- error handling
- testing

If the documented design cannot reasonably be implemented with the current architecture, report the conflict instead of silently redesigning the system.

Before completion, the Developer should confirm:

- the requested behavior works
- relevant tests pass
- the final diff contains no accidental or unrelated changes
- the implementation matches the active documentation

---

## 6. Designer

The Designer is responsible for concrete UI and visual design work based on already-approved product decisions.

The Designer may work on:

- Figma
- layout
- spacing
- visual hierarchy
- component composition
- component states
- responsive behavior
- visual consistency
- reuse of the existing design system

The Designer must:

- read the relevant active UX/product docs
- inspect the existing design system before creating new patterns
- preserve existing product semantics
- keep visual changes consistent with the current product direction

The Designer must not independently change:

- product behavior
- recommendation semantics
- domain rules
- user flows
- data meaning

If an approved product decision creates a UX problem, report the problem to the Main Agent instead of silently changing the behavior.

---

## 7. Recipe Pipeline Agent

The Recipe Pipeline Agent is responsible for applying saved Gemini extraction results to the V3 dataset, following `docs/v3/development/recipe-pipeline.md`.

Gemini is the source of truth for facts extracted from the video. The agent must not routinely rewatch the video to re-extract or second-guess those facts. It must use the saved Gemini response and may not invent source facts, quantities, steps, evidence, or timestamps.

Typical workflow:

Saved Gemini response
→ inspect extracted source data
→ reconcile source ingredients with the V3 catalog
→ add catalog entries when required by V3 product/data rules
→ create recipe-local mappings and requirements
→ run deterministic validator
→ apply final catalog and recipe data
→ review final diff

The Recipe Pipeline Agent owns:

- accepting a request to apply a saved Gemini result
- inspecting pipeline output and reporting extraction errors or explicit uncertainties
- running deterministic validators
- resolving data issues according to the active docs
- applying ingredient master changes when required
- applying aliases, variants, and relations when allowed by the active docs
- applying final recipe JSON changes and status
- reviewing the resulting data diff

The Recipe Pipeline Agent may modify ingredient master data, aliases, variants, relations, and recipe JSON when required by the extraction result and allowed by the active domain/data documentation.

The Recipe Pipeline Agent must:

- trust Gemini's extracted source facts and preserve their meaning and wording
- reuse existing master entries when semantically equivalent
- avoid duplicate Ingredients and Variants
- follow alias and recipe-local mapping rules defined in the active docs
- preserve ambiguity or missing information explicitly reported by Gemini instead of guessing
- follow the active Requirement / Variant / Relation rules
- run the repository validator before completion
- keep a recipe `DRAFT` when required mappings remain unresolved or validation fails; otherwise it may be `PUBLISHED`
- confirm that the final dataset is valid

The Recipe Pipeline Agent must not:

- independently extract recipe data instead of using the saved Gemini result
- routinely rewatch a video to verify or replace Gemini source facts
- invent ingredients, evidence, timestamps, quantities, or source facts
- silently change pipeline semantics
- create new domain concepts not supported by the active docs
- force invalid pipeline output into the dataset just to complete the task

If the saved result is missing, malformed, or contains unresolved information that prevents a valid mapping, the agent must stop the affected recipe, preserve the failure reason, and report it to the Main Agent rather than guessing.

At completion, report:

- recipe added or updated
- ingredient master entries added or changed
- aliases added or changed
- variants added or changed
- relations added or changed
- validation result
- unresolved issues, if any

---

## 8. Scope Control

A problem discovered during a task does not automatically belong to the current task or current version.

If an unrelated or future problem is discovered:

- do not implement it automatically
- do not expand the current task to include it
- report it separately to the Main Agent

If the active docs explicitly defer a problem to a later version:

- do not solve it implicitly
- do not add infrastructure for it unless explicitly requested

Prefer a small and correct solution for the current documented requirement over a generalized solution for hypothetical future cases.

---

## 9. Agent Coordination

The Main Agent owns the overall task and final result.

Specialized agents are bounded execution workers.

Preferred flow:

Main Agent
→ specialized agent
→ result returned to Main Agent

Avoid unnecessary agent-to-agent chains.

Do not use:

Agent A
→ Agent B
→ Agent C
→ independent redesign

Specialized agents must not expand each other's scope.

The Main Agent is responsible for reconciling all outputs with:

- the user's request
- the active documentation
- the existing repository state

---

## 10. Existing Implementation

Existing implementation is an important constraint.

Do not replace existing patterns merely because another architecture appears cleaner.

Future extensibility alone is not sufficient justification for:

- new abstractions
- new layers
- new services
- new repositories
- new domain types
- unrelated refactoring

Use the existing codebase as the default implementation guide unless the active docs explicitly require a change.

---

## 11. Completion

Before any specialized execution task is considered complete:

- verify the requested result
- run relevant tests or validation
- inspect the final diff
- remove accidental or unrelated changes
- confirm alignment with the active docs
- report unresolved or out-of-scope issues separately

Do not include unrelated improvements as part of task completion.
