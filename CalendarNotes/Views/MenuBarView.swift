import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    let notes: [Note]
    @State private var showCalendar: Bool = false
    @State private var isSearching: Bool = false
    @State private var refreshID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
            HStack {
                if !isSearching {
                    Text(appState.selectedDate.formatted(date: .long, time: .omitted))
                        .font(.headline)
                }
                Spacer()
                
                Button(action: { 
                    showCalendar.toggle()
                    isSearching = false
                }) {
                    Image(systemName: "calendar")
                }
                .help("Toggle Calendar")
                
                Button(action: { 
                    isSearching.toggle()
                    showCalendar = false
                }) {
                    Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                }
                .help("Search")
            }
            .padding()

            Divider()

            // Calendar (shown when toggled)
            if showCalendar {
                CalendarView(selectedDate: $appState.selectedDate, notes: notes, refreshID: refreshID)
                    .padding()
                Divider()
            }

            // Main content area
            if isSearching {
                SearchView(isSearching: $isSearching)
            } else {
                NoteEditorView(selectedDate: appState.selectedDate)
                    .frame(height: 300)
            }

            Divider()

            // Footer
            HStack {
                Button("Open Main Window") { 
                    openWindow(id: "main") 
                }
                .buttonStyle(.link)
                
                Spacer()
                
                Button("Quit") { 
                    NSApplication.shared.terminate(nil) 
                }
                .buttonStyle(.link)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 350)
        .onReceive(NotificationCenter.default.publisher(for: .notesDidChange)) { _ in
            refreshID = UUID()
        }
        .id(refreshID)
    }
}
