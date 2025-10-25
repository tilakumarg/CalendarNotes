# CalendarNotes

A lightweight macOS notes app that attaches rich-text notes to calendar dates. This document explains how to download the source, build the app, and run it on a Mac without modifying the source code.

## Quick summary
- Download the source (git clone or ZIP). 
- Open the Xcode project and run (recommended).
- Or build from the command line with `xcodebuild` and open the generated .app.
- No source modifications required to build and run locally.

---

## Prerequisites
- macOS 14 (Sonoma) or later recommended.
- Xcode 15 or later.
- A Mac (Apple Silicon or Intel) with sufficient disk space.

Note: If you will run the app from Xcode, Xcode may prompt to "Sign to Run Locally" using your Apple ID (one-time setup). This does not require changing source files; it's a local signing step so the debugger can launch the app on your machine.

---

## Download the source
Option A — clone the repository (recommended):

```bash
git clone https://github.com/<your-username>/CalendarNotes.git
cd CalendarNotes
```

Replace the URL above with the HTTPS or SSH URL of the repository you published to GitHub.

Option B — download ZIP:
- On the GitHub repository page click "Code" → "Download ZIP", then unzip and open the folder.

---

## Build & run (Recommended: using Xcode)
1. Open the project:
   - Double-click `CalendarNotes.xcodeproj` in the project root (or open via Xcode: File → Open...).
2. In Xcode, select the project scheme named `CalendarNotes` and the run destination "My Mac".
3. If Xcode prompts about signing, follow the "Sign to Run Locally" prompts (one-time) or manually enable automatic signing:
   - Select the project in the Project navigator → select the app target → Signing & Capabilities → check **Automatically manage signing** and pick your **Team** (your Apple ID can be used as a Personal Team).
   - Xcode will handle development signing for local runs; no source changes are required.
4. Build and run:
   - Build: Product → Build (Cmd+B)
   - Run: Product → Run (Cmd+R)

The app will launch on your Mac. Use Xcode's console for logs and the debugger while running.

---

## Build & run (Command-line)
You can build the app with `xcodebuild`. This is useful if you prefer the Terminal or want to produce the .app and run it directly.

1. From the project root directory:

```bash
# build a Debug product
xcodebuild -project CalendarNotes.xcodeproj -scheme CalendarNotes -configuration Debug
```

2. After a successful build, the app bundle will be in the build products directory. Typical path:

```
./build/Debug/CalendarNotes.app
```

3. Launch the app:

```bash
open ./build/Debug/CalendarNotes.app
```

If Gatekeeper blocks the app (because it's not notarized/unsigned from the web), you can right-click the app in Finder and choose "Open" → then confirm.

---

## Run the built app without modifying the source
- The instructions above do not require changing any source files. You may need to approve local signing in Xcode (`Sign to Run Locally`) — this only updates local signing metadata, not the source.
- If you prefer not to sign at all, you can run the built `.app` by opening it from Finder and approving it in System Settings → Privacy & Security → Open Anyway, or right-click → Open.

---

## Using the app (brief)
- Create a new note: Cmd+N or use the New Note UI.
- Select any date in the calendar to view or add notes for that date.
- Use the search field to filter notes by text/date.
- Use the menu-bar extra for quick access to today's or recent notes.
- Import/Export is available from the Settings or via the Import/Export manager if present in the UI.

---

## Troubleshooting
- Xcode signing errors: enable **Automatically manage signing** in the target's Signing & Capabilities and select your Team (Apple ID) to allow the app to run locally.
- SwiftData / ModelContainer errors: If the app fails because of persistent store or schema mismatch (rare when using the provided source), try removing the app container or its app data on your Mac to force a fresh store:

```bash
# Replace bundle-id with the actual bundle id if known, or search for the container folder
rm -rf ~/Library/Containers/com.example.CalendarNotes
```

- Clean build: In Xcode: Product → Clean Build Folder (hold Option to reveal) or from Terminal remove `DerivedData` and rebuild.

- Gatekeeper when opening an unsigned build: Right-click the app in Finder → Open → Allow the app to run when prompted, or go to System Settings → Privacy & Security → Open Anyway.

---

## Notes for maintainers / advanced users
- The app uses SwiftData and a named configuration `CalendarNotesDB-v4`. If you change the model schema, consider migration strategies or increment the DB name to avoid runtime incompatibilities.
- `Note.content` uses external storage for large rich-text blobs — no changes needed to build or run.

---

If you want, I can also:
- Add a small script (`scripts/build-and-run.sh`) to automate the command-line build and launch steps.
- Add a short contributors' guide showing how to sign builds for distribution.
