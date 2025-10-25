# CalendarNotes

A lightweight macOS notes app that attaches rich-text notes to calendar dates. Built with SwiftUI and SwiftData, CalendarNotes provides a calendar-first workflow, a rich text editor, search, import/export tools, and a menu-bar companion for quick access.

## Features
- Date-based notes: create and view notes attached to calendar dates.
- Rich text editing (content stored via SwiftData external storage).
- Persistent storage using SwiftData (`ModelContainer` configured as `CalendarNotesDB-v4`).
- Search across notes by text and date.
- Menu bar extra for quick access to recent or today's notes.
- Import/Export utilities for backup and restore.
- Theme support via `ThemeManager` (customizable background and font colors).
- Settings pane for preferences and import/export.

## Tech stack
- Swift / SwiftUI
- SwiftData (model persistence with `@Model`)
- macOS app (uses `MenuBarExtra`)
- Xcode project included (`CalendarNotes.xcodeproj`)

## Requirements
- Xcode 15 or later (recommended)
- macOS 14 (Sonoma) or later for MenuBarExtra and SwiftData APIs
- Swift toolchain that ships with the supported Xcode

## Project structure (high level)
- `CalendarNotesApp.swift` — app entry; creates `ModelContainer` with configuration name `CalendarNotesDB-v4`.
- `AppState.swift` — shared observable state (selected date, search text).
- `Models/Note.swift` — `@Model` note with `content: Data` (stored using external storage) and `date: Date`.
- `Views/` — `ContentView`, `CalendarView`, `NoteEditorView`, `MenuBarView`, etc.
- `ImportExportManager.swift` — import/export helpers.
- `ThemeManager.swift` — theming support.
- `SettingsView.swift` — settings UI.
- `Assets.xcassets/` — app icons and accent color.

## Build & run (local)
1. Open the project in Xcode:
   - Double-click `CalendarNotes.xcodeproj` (or open the workspace if present).
2. Select the macOS target and a My Mac run destination.
3. Build and run:

```bash
# Build (in Xcode use Cmd+B)
# Run (in Xcode use Cmd+R)
```

Alternatively, from the command line you can build the Xcode project:

```bash
xcodebuild -project CalendarNotes.xcodeproj -scheme CalendarNotes -configuration Debug
```

## Usage
- Create a new note via the app UI or the "New Note" command (Cmd+N).
- Select a date in the calendar to view or edit its notes.
- Use the search field to filter notes.
- Use the menu-bar extra for fast access to today's or recent notes.
- Import/Export is available in the Settings or via the app menu for backups.

## Data & migration notes
- The app configures a named SwiftData configuration `"CalendarNotesDB-v4"` in `CalendarNotesApp.swift`. This gives the app a fresh DB name when you intentionally change schema versions to avoid incompatibilities with older builds.
- If you change the model schema in future releases, consider incrementing the DB configuration name or providing a migration path to avoid runtime errors.

## Import / Export
- `ImportExportManager.swift` provides routines to export notes for backup and to import them back.
- Use the Settings pane to perform import/export tasks (or the app menu if exposed).

## Theming
- `ThemeManager` exposes `backgroundColor` and `fontColor` that are applied globally.
- Themes are applied in the main window and the menu-bar extra for a consistent look.

## Development notes
- The `Note` model uses `@Attribute(.externalStorage)` for `content`, so large rich-text blobs are stored outside the main store—this improves performance and storage management.
- The app registers a `CommandGroup(replacing: .newItem)` to map Cmd+N to creating a new note.
- The `MenuBarExtra` is declared in the app entry and uses `MenuBarView` with the `notes` query injected.

## Publishing to GitHub (example)
1. Create a new repository on GitHub (e.g., `CalendarNotes`).
2. From the project root (where `CalendarNotes.xcodeproj` resides):

```bash
git init
git add .
git commit -m "Initial commit — CalendarNotes"
# Replace <your-remote-url> with your GitHub repo URL (HTTPS or SSH)
git remote add origin <your-remote-url>
git branch -M main
git push -u origin main
```

(Optional) Tag a release:

```bash
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```
