# Product Overview Requirements

## Context

- Define the baseline product requirements for the vaccination manager.

## Scope

- In scope: patient data handling, vaccination records, reminder workflows, localization, and reporting behavior.
- Out of scope: external billing and insurance claim processing.

## Functional Requirements

- FR-001: The system shall allow creation and management of patient profiles.
- FR-002: The system shall allow recording and viewing vaccination events.
- FR-003: The system shall support reminder workflows for upcoming or overdue vaccinations.
- FR-004: The system shall allow local creation, editing, switching, and persistence of user profiles with a username and profile picture.

## Non-Functional Requirements

- NFR-001: The app shall provide responsive UI behavior for common user actions.
- NFR-002: The app shall support localization through configured locales.
- NFR-003: User profile data shall persist locally in a SQLite database and remain available across app restarts.

## Acceptance Criteria

- AC-001: A user can create a patient profile with required fields and retrieve it later.
- AC-002: A user can add a vaccination event and see it in the patient history.
- AC-003: Reminder-related views present upcoming and overdue vaccination states correctly.
- AC-004: When no user profile exists, the app opens on a welcome flow that lets the user create the first profile.
- AC-005: A user can create and edit a profile with a username and optional profile picture.
- AC-006: A user can switch the active profile without deleting or recreating existing profiles.

## Open Questions

- Which minimum data fields are mandatory for patient creation?
- What reminder lead times must be configurable?

## Change Log

- 2026-03-21: Initial baseline requirements file created.
- 2026-03-21: Added user management, startup fallback, and SQLite persistence requirements.
