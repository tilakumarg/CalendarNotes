import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @AppStorage("theme_background") private var backgroundColorData: Data = Data()
    @AppStorage("theme_font") private var fontColorData: Data = Data()

    @Published var backgroundColor: Color = .clear
    @Published var fontColor: Color = .primary

    init() {
        loadColors()
    }

    func loadColors() {
        if let bgColor = color(from: backgroundColorData) {
            backgroundColor = bgColor
        } else {
            // Default color if nothing is saved
            backgroundColor = Color(.windowBackgroundColor)
        }

        if let fgColor = color(from: fontColorData) {
            fontColor = fgColor
        } else {
            // Default color if nothing is saved
            fontColor = .primary
        }
    }

    func saveColors() {
        backgroundColorData = data(from: backgroundColor) ?? Data()
        fontColorData = data(from: fontColor) ?? Data()
        
        // Republish changes
        loadColors()
    }
    
    // MARK: - Private Helpers
    
    private func data(from color: Color) -> Data? {
        let nsColor = NSColor(color)
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false)
        } catch {
            print("Error converting color to data: \(error)")
            return nil
        }
    }

    private func color(from data: Data) -> Color? {
        do {
            guard let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else { return nil }
            return Color(nsColor)
        } catch {
            // This can happen if data is empty or invalid, which is fine on first launch
            return nil
        }
    }
}
