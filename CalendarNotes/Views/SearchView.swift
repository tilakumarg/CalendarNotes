import SwiftUI
import SwiftData

struct SearchView: View {
    @EnvironmentObject var appState: AppState
    @Query private var notes: [Note]
    @Binding var isSearching: Bool
    
    var filteredNotes: [Note] {
        if appState.searchText.isEmpty {
            return []
        } else {
            return notes.filter { note in
                if let attributedString = try? NSAttributedString(data: note.content, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil) {
                    return attributedString.string.localizedCaseInsensitiveContains(appState.searchText)
                }
                return false
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search notes...", text: $appState.searchText)
                .textFieldStyle(PlainTextFieldStyle())

            // Show results only if there is search text
            if !appState.searchText.isEmpty {
                List(filteredNotes) { note in
                    VStack(alignment: .leading) {
                        Text(notePreview(from: note.content))
                            .lineLimit(2)
                        Text(note.date.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        // Set the selected date
                        appState.selectedDate = note.date
                        // Clear the search text
                        appState.searchText = ""
                        // Dismiss the search view
                        isSearching = false
                    }
                }
            }
        }
    }
    
    private func notePreview(from data: Data) -> String {
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil) {
            let text = attributedString.string
            return String(text.prefix(100)) + (text.count > 100 ? "..." : "")
        }
        return ""
    }
}
