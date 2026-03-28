# Requirements Documentation

This folder is the single source of truth for product and technical requirements.

## File Structure

Use markdown files with stable, descriptive names.
Default to one evolving master file per feature area, for example:

- `product-overview.md`
- `vaccination-reminders.md`
- `patient-management.md`

Create a new file only for a genuinely new feature area.

## Recommended Section Template

Each requirement file should include these sections:

1. Context
2. Scope
3. Functional Requirements
4. Non-Functional Requirements
5. Acceptance Criteria
6. Open Questions
7. Change Log

## Authoring Rules

- Keep requirements implementation-agnostic unless constraints are required.
- Use clear, testable acceptance criteria.
- Update existing files when behavior changes; avoid duplicating the same requirement across multiple files.
- Preserve requirement IDs or headings when possible to keep traceability stable.
