import Foundation
import SwiftData

@Model
class Note: Identifiable {
    var id: UUID
    @Attribute(.externalStorage) var content: Data
    var date: Date
    
    init(content: Data, date: Date) {
        self.id = UUID()
        self.content = content
        self.date = date
    }
}
