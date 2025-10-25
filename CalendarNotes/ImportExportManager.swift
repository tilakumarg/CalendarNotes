import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@MainActor
class ImportExportManager {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // A simple, Codable struct for transferring note data.
    private struct NoteTransferObject: Codable {
        let date: Date
        let content: Data
    }

    // MARK: - Export

    func exportNotes() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "CalendarNotes_Backup_\(Date().formatted(.iso8601)).json"

        guard savePanel.runModal() == .OK, let url = savePanel.url else {
            print("Save panel was cancelled or failed.")
            return
        }

        do {
            // Fetch all notes from the database
            let allNotes = try modelContext.fetch(FetchDescriptor<Note>())
            
            // Convert them to the transferable format
            let transferableNotes = allNotes.map { NoteTransferObject(date: $0.date, content: $0.content) }
            
            // Encode to JSON data
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(transferableNotes)
            
            // Write to the selected file URL
            try data.write(to: url)
            print("Successfully exported \(transferableNotes.count) notes to \(url.path)")

        } catch {
            print("Failed to export notes: \(error)")
        }
    }

    // MARK: - Import

    func importNotes() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false

        guard openPanel.runModal() == .OK, let url = openPanel.url else {
            print("Open panel was cancelled or failed.")
            return
        }

        do {
            // Read the file's data
            let data = try Data(contentsOf: url)
            
            // Decode the JSON into transferable objects
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importedNotes = try decoder.decode([NoteTransferObject].self, from: data)
            
            // Insert new notes into the database
            for noteData in importedNotes {
                // This simple import adds all notes. A more complex app might check for duplicates.
                let newNote = Note(content: noteData.content, date: noteData.date)
                modelContext.insert(newNote)
            }
            
            try modelContext.save()
            print("Successfully imported \(importedNotes.count) notes.")

        } catch {
            print("Failed to import notes: \(error)")
        }
    }
}
