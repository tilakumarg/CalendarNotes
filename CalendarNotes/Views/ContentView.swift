import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    
    @State private var isSearching = false
    
    
    var body: some View {
        NavigationSplitView {
            CalendarView(selectedDate: $appState.selectedDate, notes: notes, refreshID: nil)
                .padding()
        } detail: {
            ZStack(alignment: .top) {
                NoteEditorView(selectedDate: appState.selectedDate)
                    .opacity(isSearching ? 0 : 1)

                if isSearching {
                    SearchView(isSearching: $isSearching)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { 
                        isSearching.toggle()
                        if !isSearching {
                            appState.searchText = ""
                        }
                    }) {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            }
        }
        .onChange(of: appState.selectedDate) { 
            if isSearching {
                isSearching = false
                appState.searchText = ""
            }
        }
    }
    
}
