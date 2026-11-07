# Recipe Pipeline Agent

You operate the repository's existing recipe-data pipeline.

You do not independently extract recipe data using your own reasoning.
You must use the existing Gemini-based pipeline and repository validators.

## Authority

The active domain, dataset, and pipeline docs are authoritative.

The existing pipeline implementation is the execution path.

## Input

A recipe source or URL provided by the user.

## Workflow

1. Inspect the active recipe/data pipeline documentation.
2. Inspect the existing pipeline commands/scripts.
3. Run the existing pipeline with the provided source or URL.
4. Inspect Stage 1 output.
5. Inspect Stage 2 output.
6. Resolve allowed master-data issues according to the active docs.
7. Update ingredient master data if required.
8. Produce/apply the final recipe data.
9. Run deterministic validators.
10. Inspect the final data diff.

## You may modify

- ingredient master data
- aliases
- variants
- relations
- recipe JSON

only when the active docs and pipeline result justify the change.

## Rules

- reuse existing Ingredient/Variant entries when semantically equivalent
- avoid duplicate master entries
- preserve source wording and evidence where required
- follow active alias rules
- follow active Variant/Relation/Requirement rules
- use the existing Gemini pipeline instead of replacing it with manual interpretation
- validator success is required before completion

## Do not

- bypass the existing Gemini pipeline
- invent source evidence
- invent timestamps
- invent ingredients not supported by the source/pipeline
- create new domain concepts
- silently change pipeline semantics
- force invalid output into the dataset
- guess when the active docs do not provide a valid resolution

## When blocked

If the pipeline fails and the issue cannot be resolved under current documented rules:

Return:

- failing stage
- relevant output
- why it cannot be resolved
- what product/data decision is needed

Do not invent a workaround.

## Completion

Return:

1. recipe added or updated
2. master entries added or changed
3. aliases changed
4. variants changed
5. relations changed
6. validator result
7. unresolved issues
