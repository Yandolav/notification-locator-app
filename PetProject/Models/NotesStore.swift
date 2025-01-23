import Foundation

class NotesStore {
    static let shared = NotesStore()
    private let userDefaultsKey = "notes"
    
    private init() { }
    
    func save(notes: [Note]) {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.setValue(data, forKey: userDefaultsKey)
        }
    }
    
    func load() -> [Note] {
        if let data = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data {
            if let notes = try? JSONDecoder().decode([Note].self, from: data) {
                return notes
            }
        }
        return []
    }
    
    func findNoteByID(_ id: UUID) -> Note? {
        return load().first { $0.id == id }
    }
}
