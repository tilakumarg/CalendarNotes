import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var searchText: String = ""
}
