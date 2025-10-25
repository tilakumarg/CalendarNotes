import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.modelContext) private var modelContext
    var body: some View {

        Form {
            Section(header: Text("Appearance")) {
                ColorPicker("Background Color", selection: $themeManager.backgroundColor)
                ColorPicker("Font Color", selection: $themeManager.fontColor)
            }
            
            HStack {
                Spacer()
                Button("Save Colors") {
                    themeManager.saveColors()
                }
            }

            Section(header: Text("Data Management")) {
                Button("Export All Notes...") {
                    let manager = ImportExportManager(modelContext: modelContext)
                    manager.exportNotes()
                }
                Button("Import Notes...") {
                    let manager = ImportExportManager(modelContext: modelContext)
                    manager.importNotes()
                }
            }
        }
        .padding()
        .frame(width: 350)
        .onAppear {
            themeManager.loadColors()
        }
    }
}
