import SwiftUI
import SwiftData

@main
struct CalendarNotesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        // By giving the database a specific name, we ensure a fresh start,
        // bypassing any old, incompatible database files from previous builds.
        let modelConfiguration = ModelConfiguration("CalendarNotesDB-v4", schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()

    @Query private var notes: [Note]

    var body: some Scene {

        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .frame(minWidth: 700, minHeight: 500) // A reasonable minimum size
                .background(themeManager.backgroundColor)
                .foregroundColor(themeManager.fontColor)
        }
        .defaultSize(width: 800, height: 600) // The initial size on launch
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") {
                    appState.selectedDate = Date()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
        
        MenuBarExtra("Calendar Notes", systemImage: "calendar") {
            // Pass the notes array to the MenuBarView
            MenuBarView(notes: notes)
                .environmentObject(appState)
                .environmentObject(themeManager)
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
    }
}
