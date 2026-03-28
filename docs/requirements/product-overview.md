# Product Overview Requirements

## Context

- Define the baseline product requirements for the vaccination manager.

## Scope

- In scope: patient data handling, vaccination records, reminder workflows, localization, and reporting behavior.
- Out of scope: external billing and insurance claim processing.

## Functional Requirements

- FR-001: The system shall allow creation and management of patient profiles.
- FR-002: The system shall allow each user profile to record and view vaccination records.
- FR-003: The system shall support reminder workflows for upcoming or overdue vaccinations.
- FR-004: The system shall allow local creation, editing, switching, and persistence of user profiles with a username and profile picture.
- FR-005: The system shall allow a user to save and edit vaccination entries containing a vaccination name, vaccination date, and next vaccination required date.
- FR-006: The system shall support one-shot and multi-shot vaccination workflows with explicit mode selection, multiple shot dates per vaccination series, and a shared expiration date.
- FR-007: The system shall allow deleting individual vaccination shots from a user's vaccination history.

## Non-Functional Requirements

- NFR-001: The app shall provide responsive UI behavior for common user actions.
- NFR-002: The app shall support localization through configured locales.
- NFR-003: User profile data shall persist locally in a SQLite database and remain available across app restarts.
- NFR-004: Vaccination records shall persist locally per user profile and remain available across app restarts.

## Acceptance Criteria

- AC-001: A user can create a patient profile with required fields and retrieve it later.
- AC-002: A user can add a vaccination entry to the active user profile and see it later in that profile's vaccination history.
- AC-003: Reminder-related views present upcoming and overdue vaccination states correctly.
- AC-004: When no user profile exists, the app opens on a welcome flow that lets the user create the first profile.
- AC-005: A user can create and edit a profile with a username and optional profile picture.
- AC-006: A user can switch the active profile without deleting or recreating existing profiles.
- AC-007: A user can save a vaccination entry with vaccination name, vaccination date, and next vaccination required date.
- AC-008: A user can save multiple entries with the same vaccination name under one profile without overwriting earlier shots.
- AC-009: When switching user profiles, each profile shows only its own vaccination records.
- AC-010: Vaccination records remain available after closing and reopening the app.
- AC-011: A user can filter vaccination series by reminder status (all, overdue, due soon, up to date) and delete an individual shot with confirmation.
- AC-012: A user can enter future planned shot dates in multi-shot mode, and these planned dates drive due-soon reminder status.
- AC-013: When switching from multi-shot mode to one-shot mode and data would be removed, the app shows a warning confirmation before applying the change.

## Open Questions

- Which minimum data fields are mandatory for patient creation?
- What reminder lead times must be configurable?

## Change Log

- 2026-03-21: Initial baseline requirements file created.
- 2026-03-21: Added user management, startup fallback, and SQLite persistence requirements.
- 2026-03-21: Added per-user vaccination record requirements and persistence expectations.
- 2026-03-22: Added vaccination shot deletion and reminder filter acceptance behavior.
- 2026-03-22: Clarified one-shot and multi-shot vaccination workflow requirements, planned future shots, and lossy mode-switch warning.
