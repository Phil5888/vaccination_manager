# Requirements-First Workflow

Before any implementation, review, architecture change, localization update, or test work:

1. Identify applicable requirement file(s) in docs/requirements.
2. Map the task to explicit requirement IDs and acceptance criteria.
3. If no requirement exists, ask to update requirements first or route through the Requirements Engineer agent.

## Execution Rules

- Do not start code changes without referencing requirement IDs from docs/requirements.
- Keep implementation and review outputs traceable to requirement IDs where possible.
- If requested behavior conflicts with existing requirements, call out the conflict and request a requirement update.
- When requirements are updated, also update docs/requirements/traceability-matrix.md.

## Reporting Rules

For implementation, review, testing, localization, and architecture tasks include:

- Requirement source file(s)
- Requirement ID(s)
- Acceptance criteria covered
- Any gaps, assumptions, or requirement ambiguities
