import SwiftUI

// MARK: - Note Model
struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
}

// MARK: - ViewModel for Notes
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    
    init() {
        loadNotes()
    }
    
    private let notesKey = "savedNotes"
    
    func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    func loadNotes() {
        if let savedData = UserDefaults.standard.data(forKey: notesKey),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedData) {
            notes = decodedNotes
        }
    }
    
    func addNote(title: String, content: String) {
        let newNote = Note(title: title, content: content)
        notes.append(newNote)
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

// MARK: - ViewModel for Settings
class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
}

// MARK: - Home View
struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        VStack(alignment: .leading) {
                            Text(note.title)
                                .font(.headline)
                                .lineLimit(1)
                            Text(note.content)
                                .font(.subheadline)
                                .lineLimit(2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteNote)
            }
            .navigationTitle("Notes")
            .navigationBarItems (
                leading: NavigationLink(destination: SettingsView(settingsViewModel: settingsViewModel)) {
                    Image(systemName: "gearshape.fill")
                },
                trailing: NavigationLink(destination: NewNoteView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            )
        }
        .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
    }
}

// MARK: - New Note View
import SwiftUI
import SwiftUI

struct NewNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: NotesViewModel
    @State private var title = ""
    @State private var content = ""
    @State private var animateGradient = false
    @State private var shadowColorIndex = 0
    @State private var currentImage = "brain.fill"
    
    
    
    let images: [String] = ["brain.fill", "star.fill", "heart.fill", "bolt.fill","moon.fill","star.fill", "cloud.fill"]
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
                .font(.headline)
            TextEditor(text: $content)
                .frame(height: 200)
            
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal)
        }
        .navigationTitle("New Note")
        .navigationBarItems(
            leading: Button("Home") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                if !title.isEmpty {
                    viewModel.addNote(title: title, content: content)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
    
    
}

#Preview {
    NewNoteView(viewModel: NotesViewModel())
}




// MARK: - Note Detail View
struct NoteDetailView: View {
    let note: Note
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(note.title)
                    .font(.largeTitle)
                    .bold()
                Divider()
                Text(note.content)
                    .font(.body)
                    .padding(.top, 5)
            }
            .padding()
        }
        .navigationTitle("Note")
        .navigationBarItems(
            leading: Button("Home") {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}

// MARK: - Settings View with Update Button
struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var updateMessage: String = ""
    @State private var isUpdating = false
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $settingsViewModel.isDarkMode)
            }
            Section(header: Text("Links")) {
                Link(destination: URL(string: "https://www.tiktok.com/@icantdecidemyusernameaa")!) {
                    Text(Image(systemName: "star")) + Text(" My Tiktok")
                }
                Link(destination: URL(string: 
                                        "https://watermelon2.bio.link")!) {
                    Text(Image(systemName: "macwindow")) + Text(" My Website")
                }
            }
            
            Section(header: Text("App Updates")) {
                Button(action: {
                    checkForUpdates()
                }) {
                    Text("Check for Updates")
                }
                .disabled(isUpdating)  // Disable button during update
                
                if !updateMessage.isEmpty {
                    Text(updateMessage)
                        .foregroundColor(updateMessage.contains("No updates") ? .green : .blue)
                }
            }
            
            Section(header: Text("About")) {
                Text("Watermelon Notes Beta 1.0")
            }
        }
        .navigationTitle("Settings")
        .navigationBarItems(
            leading: Button("Home") {
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
    
    // Simulate an update check
    func checkForUpdates() {
        isUpdating = true
        updateMessage = "Checking for updates..."
        
        // Simulate a delay for update check
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let hasUpdate = Bool.random() // Randomize update availability
            
            if hasUpdate {
                updateMessage = "An update is available! Updating now..."
                
                // Simulate the update process
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    updateMessage = "Update completed successfully!"
                    isUpdating = false
                }
            } else {
                updateMessage = "No updates, have a great day  :)"
                isUpdating = false
            }
        }
    }
}

// MARK: - Main App Entry




