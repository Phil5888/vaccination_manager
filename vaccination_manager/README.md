# Vaccination Manager

A comprehensive vaccination tracking application built with Flutter, designed to help users manage their vaccination records, track vaccination schedules, and receive reminders for upcoming vaccinations.

## Features

### Core Functionality

- **Multi-user Support**: Create and manage multiple user profiles with individual vaccination records
- **Vaccination Tracking**: Record vaccination shots, dates, and expiration dates
- **Calendar Integration**: Sync vaccinations to device calendar for easy reference
- **Smart Reminders**: Configurable notification lead times (3 days to 3 months) for upcoming vaccinations
- **Vaccination Status**: Track vaccination status (planned, recorded, due soon, overdue, up-to-date)
- **Filtering**: Filter vaccinations by status (all, overdue, due soon, up-to-date)

### User Experience

- **Multi-language Support**: English and German with automatic system language detection and English fallback
- **Dark/Light Theme**: User-customizable theme preference with reactive UI updates
- **Responsive Layout**: Mobile, tablet, and desktop layouts with adaptive navigation
- **Consistent Styling**: App-wide form components with standardized input styling
- **Persistent Settings**: All user preferences saved locally via SharedPreferences

## App Screens

### 1. Welcome Screen

**First Launch Experience**

- Welcoming introduction to the app
- "Create New User" button to start
- Shown only when no users exist in the app

### 2. Dashboard Screen

**Main Landing Page**

- **User Preview Card**: Shows active user profile with quick user switch button
- **Settings Preview**: Displays current language and theme settings
- **Vaccination Summary Widget**:
    - Shows next due vaccination (if any)
    - Next shot date and series name
    - Quick access to record vaccination
    - "No vaccinations" state when none exist
- **Quick Navigation**: Access to Users and Vaccinations tabs

### 3. Vaccinations Screen

**Vaccination Management Hub**

- **Filter Controls**: Chips to filter by status
    - All (default)
    - Overdue (past due date)
    - Due Soon (within lead time)
    - Up-to-Date (current)
- **Vaccination Series List**:
    - Expandable series cards (collapsed by default)
    - Compact summary showing next due vaccination
    - Series name and overall status indicator
    - Quick record and edit buttons
- **Add Vaccination Button**: Create new vaccination series (+)
- **Empty State**: "No vaccinations" message when list is empty

### 4. Vaccination Entry Form

**Create/Edit Vaccination Series**

- **Vaccination Name**: Text input field (required)
- **Vaccination Mode Selection**:
    - Choice chips: "One-shot" or "Multi-shot"
    - Dynamically adjusts shot entry UI based on selection
- **Shot Dates Section**:
    - Per-shot date fields with calendar picker icon
    - Each shot labeled (Shot 1, Shot 2, etc.)
    - Planned/Recorded status indicator per shot
    - Add shot button (appears in multi-shot mode)
    - Remove shot button (multi-shot mode with length > 1)
- **Expiration Date**: Calendar picker with helper text
    - "Future date hint" explaining planned vs. recorded
    - Validation ensures expiration is after latest shot
- **Form Validation**:
    - All required fields checked
    - Duplicate shot dates prevented
    - Error messages displayed inline
- **Submit/Cancel Buttons** with loading state during save

### 5. User Management Screen

**User Profile List**

- List of all user profiles
- User avatar for each profile
- Username display
- Quick actions per user:
    - Edit button
    - Delete button
    - Make active/switch user
- Add new user button (+)
- Shows user count (e.g., "3 users")

### 6. User Profile Form

**Create/Edit User Profile**

- **Username**: Text input field (required)
    - Validation ensures non-empty
- **Profile Picture**:
    - Large circular preview of current/new picture
    - "Choose Picture" button (or "Change Picture" if existing)
    - "Remove Picture" button (if picture exists)
    - File picker for image selection (PNG, JPG, WebP)
- **Form Actions**: Save and Cancel buttons with loading state

### 7. User Switcher Sheet

**Quick User Switch**

- Modal bottom sheet showing all users
- Current active user highlighted
- Tap any user to switch
- Automatically navigates to dashboard after switch
- Cancel to close sheet

### 8. Settings Screen

**App Configuration**

- **Language Selector**:
    - Dropdown with supported languages
    - Flag emojis (🇩🇪 Deutsch, 🇺🇸 English)
    - Changes take effect immediately
- **Theme Toggle**:
    - "Dark Mode" switch
    - Real-time app theme updates
    - Preference persisted across sessions
- **Reminders Card**:
    - Quick access link to reminder settings
    - Shows description "Configure notification lead times"
- **Active User Section**:
    - Displays current user info
    - User avatar and name
    - "Switch User" button to open user switcher

### 9. Reminder Settings Screen

**Notification Configuration**

- **Notification Lead Time Dropdown**:
    - 3 days
    - 1 week
    - 2 weeks
    - 1 month
    - 2 months
    - 3 months
    - Selected option persisted in settings
- **Sync Reminders Section**:
    - Descriptive text explaining functionality
    - "Sync Reminders Now" button
    - Loading indicator during sync
    - Success/error feedback messages
- **Calendar Sync Details**:
    - Creates/updates calendar entries for vaccinations
    - Schedules push notifications with configured lead time
    - Shows counts of created, updated, and removed entries

### 10. Edit User Screen

**User Profile Management**

- Shows username field for editing
- Same profile picture management as creation form
- Save changes or cancel

## Architecture

### Clean Architecture Layers

**Domain Layer** (`lib/domain/`):

- Pure Dart entities (no Flutter dependencies)
- Repository interfaces for data access
- Use case classes for business logic

**Data Layer** (`lib/data/`):

- SQLite persistence via sqflite for users and vaccinations
- SharedPreferences for app settings
- Models (DB DTOs) with conversion methods
- Repository implementations

**Presentation Layer** (`lib/presentation/`):

- Riverpod providers for reactive state management
- ViewModels extending AsyncNotifier for async operations
- Screens (ConsumerWidget/ConsumerStatefulWidget)
- Reusable form components and UI widgets
- Navigation routing

**Core** (`lib/core/`):

- AppDatabase singleton (SQLite configuration)
- App theme and design system (AppTheme, AppSpacing, AppRadii)
- Localization utilities
- Route definitions
- Constants and configurations

### State Management

- **Riverpod**: Provider-based reactive state management
- **AsyncNotifier**: For async operations (loading/error/data states)
- **ProviderScope**: Root provider configuration
- **Reactive Updates**: MaterialApp watches settings provider for theme/language changes

### Data Persistence

- **SQLite**: User profiles and vaccination records (via AppDatabase)
- **SharedPreferences**: App settings (language, theme, reminder lead time)
- **Device Calendar**: Synced vaccination reminders (via package:device_calendar)
- **Local Notifications**: Push reminders for upcoming vaccinations

### Localization

- **Flutter i18n**: ARB-based translation system
- **Supported Locales**: English (en), German (de)
- **Generated Classes**: Type-safe localization via AppLocalizations
- **System Detection**: Automatic locale detection with English fallback
- **User Override**: Settings allow manual language selection

## Testing

The app includes comprehensive widget test coverage:

- **Widget Tests**: UI component and screen interaction tests
- **Mobile Navigation Tests**: Responsive layout validation (mobile/wide screens)
- **Form Tests**: User profile and vaccination entry form submission and validation
- **Vaccination Screen Tests**: Filtering, status display, and vaccination management
- **Test Coverage**: 92 tests, all passing

Run tests:

```bash
cd src
flutter test
```

Run specific test file:

```bash
flutter test test/path/to/test_file.dart
```

## UI/UX Highlights

### Design System

- **Color Scheme**: Material 3 with purple seed color
- **Typography**: Material 3 standardized text styles
- **Spacing**: Consistent padding/margins via AppSpacing constants
- **Radii**: Rounded corners via AppRadii (lg, md, sm for different components)
- **Components**: Standardized form inputs, buttons, and cards

### Form Styling

- **Labeled Fields**: External labels with consistent spacing
- **Input Fields**: Outlined style with rounded corners
- **Validation**: Real-time error display
- **Helper Text**: Context-specific hints below fields
- **Loading States**: Spinners in buttons during submission

### Responsive Design

- **Mobile**: Full-width layouts with bottom navigation
- **Tablet/Desktop**: Side-by-side layouts with navigation rail
- **Adaptive Cards**: Different arrangements based on screen size
- **Touch-Friendly**: Adequate spacing and tap targets

## Development

### Prerequisites

- Flutter SDK (latest stable)
- Xcode (macOS/iOS)
- Android Studio (Android)
- CocoaPods (macOS/iOS)

### Setup

```bash
cd src
flutter pub get
flutter run
```

### Running on Different Platforms

```bash
# iOS simulator
flutter run -d "iPhone 15 Pro Max"

# Android emulator
flutter run -d emulator-5554

# Web
flutter run -d web-server

# macOS
flutter run -d macos
```

### Lint & Analysis

```bash
cd src
flutter analyze
```

### Project Structure

```
vaccination_manager/
├── README.md
└── src/
    ├── pubspec.yaml                 # Dependencies and configuration
    ├── analysis_options.yaml        # Lint rules
    ├── lib/
    │   ├── main.dart                # App entry point
    │   ├── app.dart                 # MaterialApp (theme, locale, routes)
    │   ├── domain/                  # Business logic
    │   │   ├── entities/            # Data objects
    │   │   ├── repositories/        # Repository interfaces
    │   │   └── usecases/            # Use case classes
    │   ├── data/                    # Data access layer
    │   │   ├── models/              # SQLite DTOs
    │   │   └── repositories/        # Repository implementations
    │   ├── presentation/            # UI layer
    │   │   ├── screens/             # Screen widgets
    │   │   ├── widgets/             # Reusable widgets
    │   │   ├── viewmodels/          # State management
    │   │   ├── providers/           # Riverpod providers
    │   │   └── navigation/          # Routing
    │   ├── core/                    # Shared infrastructure
    │   │   ├── database/            # AppDatabase
    │   │   ├── constants/           # Theme, spacing, routes
    │   │   └── utils/               # Helper functions
    │   └── l10n/                    # Localization
    │       ├── app_en.arb           # English translations
    │       ├── app_de.arb           # German translations
    │       └── app_localizations*.dart
    └── test/
        ├── presentation/            # Widget tests
        └── helpers/                 # Test utilities
```

## Dependencies

Key Flutter packages used:

- **flutter_riverpod**: State management
- **sqflite**: SQLite database
- **shared_preferences**: User preferences
- **flutter_localizations**: Localization framework
- **device_calendar**: Calendar integration
- **flutter_local_notifications**: Local notifications
- **timezone**: Notification timing
- **file_selector**: Image picking for profile pictures

## Known Limitations

- Calendar sync depends on device calendar app availability
- Notifications require app to be installed (not working in dev builds on simulator)
- Localization limited to English and German

## Features Delivered

- ✅ Multi-user vaccination tracking with SQLite persistence
- ✅ User-customizable language (English/German) with system fallback
- ✅ User-customizable theme (dark/light) with reactive UI updates
- ✅ Vaccination series management (one-shot and multi-shot)
- ✅ Vaccination status tracking (planned, recorded, due soon, overdue)
- ✅ Vaccination filtering by status
- ✅ Calendar integration for vaccination events
- ✅ Configurable reminder lead times
- ✅ Device calendar sync
- ✅ Push notifications for reminders
- ✅ Responsive mobile and tablet UI
- ✅ Clean architecture implementation
- ✅ Comprehensive widget test coverage (92 tests)
- ✅ Localization support (EN/DE)

## Future Improvements

- **Enhanced Calendar Entries**: More detailed information per calendar event with custom lead-time configuration per vaccination
- **Vaccination History**: Detailed history tracking with notes and dosage information
- **Export Functionality**: Export vaccination records as PDF or printable format
- **Backup & Sync**: Cloud backup and cross-device sync capabilities
- **Doctor Integration**: Connection to healthcare providers for record verification
- **QR Code Certificates**: Generate and share vaccination proof with QR codes
- **Analytics Dashboard**: Vaccination completion statistics and trends analysis
- **Catalog of Vaccinations**: Get from STIKO
