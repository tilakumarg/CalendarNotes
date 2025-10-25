import SwiftUI
import SwiftData
import Combine

struct NoteEditorView: View {
    let selectedDate: Date
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @State private var noteText: NSAttributedString = NSAttributedString()
    @State private var debouncer = PassthroughSubject<Void, Never>()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text(selectedDate.formatted(date: .long, time: .omitted))
                .font(.title2)
                .padding(.horizontal)
                .padding(.top, 12)
            
            // Toolbar
            HStack {
                Button(action: { toggleTrait(NSFontTraitMask(rawValue: UInt(NSFontBoldTrait))) }) { Image(systemName: "bold") }
                Button(action: { toggleTrait(NSFontTraitMask(rawValue: UInt(NSFontItalicTrait))) }) { Image(systemName: "italic") }
                Button(action: { toggleUnderline() }) { Image(systemName: "underline") }
                
                Spacer()
                
                Button(action: attachFile) { Image(systemName: "paperclip") }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            
            // Editor
            RichTextEditor(text: $noteText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { loadNote(for: selectedDate) }
        .onDisappear(perform: saveNote)
        .onChange(of: selectedDate) { oldValue, newValue in
            // Explicitly save the old text to the OLD date
            saveNote(for: oldValue)
            // Then load the note for the NEW date
            loadNote(for: newValue)
        }
        .onChange(of: noteText) { debouncer.send() }
        .onReceive(debouncer.debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)) { _ in
            saveNote()
        }
    }

    private func loadNote(for date: Date) {
        if let note = notes.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            do {
                noteText = try NSAttributedString(data: note.content, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
            } catch {
                print("Failed to load note content: \(error)")
                noteText = NSAttributedString()
            }
        } else {
            noteText = NSAttributedString()
        }
    }
    
    private func toggleTrait(_ trait: NSFontTraitMask) {
        let newText = NSMutableAttributedString(attributedString: noteText)
        let fullRange = NSRange(location: 0, length: newText.length)
        let fontManager = NSFontManager.shared

        // Iterate over each font attribute in the string
        newText.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            // Ensure there's a font to modify
            guard let currentFont = value as? NSFont else { return }

            let currentTraits = fontManager.traits(of: currentFont)
            let newFont: NSFont

            // Toggle the trait: add it if it doesn't exist, remove it if it does
            if currentTraits.contains(trait) {
                newFont = fontManager.convert(currentFont, toNotHaveTrait: trait)
            } else {
                newFont = fontManager.convert(currentFont, toHaveTrait: trait)
            }
            
            newText.addAttribute(.font, value: newFont, range: range)
        }
        noteText = newText
    }

    private func toggleUnderline() {
        let newText = NSMutableAttributedString(attributedString: noteText)
        let fullRange = NSRange(location: 0, length: newText.length)

        // To correctly toggle, we need to see if the first character is underlined.
        // This is still a simplification but safer than the previous implementation.
        let isUnderlined = (newText.attribute(.underlineStyle, at: 0, effectiveRange: nil) as? Int) == NSUnderlineStyle.single.rawValue

        newText.enumerateAttribute(.font, in: fullRange, options: []) { _, range, _ in
            if isUnderlined {
                newText.removeAttribute(.underlineStyle, range: range)
            } else {
                newText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
        }
        noteText = newText
    }
    
    private func attachFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK,
           let url = panel.url,
           let image = NSImage(contentsOf: url) {
            
            let attachment = NSTextAttachment()
            attachment.image = image
            
            let newText = NSMutableAttributedString(attributedString: noteText)
            newText.append(NSAttributedString(attachment: attachment))
            noteText = newText
        }
    }

    private func saveNote(for date: Date) {
        let calendar = Calendar.current
        let isNoteEmpty = noteText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        do {
            var changed = false
            if let existingNote = notes.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                if isNoteEmpty {
                    modelContext.delete(existingNote)
                    changed = true
                } else {
                    let data = try noteText.data(from: NSRange(location: 0, length: noteText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
                    if existingNote.content != data {
                        existingNote.content = data
                        changed = true
                    }
                }
            } else if !isNoteEmpty {
                let data = try noteText.data(from: NSRange(location: 0, length: noteText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
                let newNote = Note(content: data, date: calendar.startOfDay(for: date))
                modelContext.insert(newNote)
                changed = true
            }
            
            if changed {
                try modelContext.save()
                // Post a notification that notes have changed
                NotificationCenter.default.post(name: .notesDidChange, object: nil)
            }
        } catch {
            print("Failed to save note: \(error)")
        }
    }

    // Overload for debouncer and onDisappear
    private func saveNote() {
        saveNote(for: selectedDate)
    }
}
