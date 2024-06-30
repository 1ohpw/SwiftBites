import SwiftUI
import SwiftData

struct CategoryForm: View {
    enum Mode: Hashable {
        case add
        case edit(Category)
    }
    
    var mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            _name = .init(initialValue: "")
            title = "Add Category"
        case .edit(let category):
            _name = .init(initialValue: category.name)
            title = "Edit \(category.name)"
        }
    }
    
    private let title: String
    @State private var name: String
    @State private var error: CategoryError?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
            }
            if case .edit(let category) = mode {
                Button(
                    role: .destructive,
                    action: {
                        delete(category: category)
                    },
                    label: {
                        Text("Delete Category")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                )
            }
        }
        .onAppear {
            isNameFocused = true
        }
        .onSubmit {
            save()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
                    .disabled(name.isEmpty)
            }
        }
        .alert(item: $error) { error in
            Alert(title: Text("Error"), message: Text(error.localizedDescription))
        }
    }
    
    // MARK: - Data
    
    private func delete(category: Category) {
        modelContext.delete(category)
        try? modelContext.save()
        dismiss()
    }
    
    private func save() {
        do {
            switch mode {
            case .add:
                if try Category.exists(withName: name, in: modelContext) {
                    throw CategoryError.categoryExists
                }
                
                let newCategory = Category(name: name)
                modelContext.insert(newCategory)
            case .edit(let category):
                if try Category.exists(withName: name, excluding: category.id, in: modelContext) {
                    throw CategoryError.categoryExists
                }
                
                category.name = name
            }
            try modelContext.save()
            dismiss()
        } catch let error as CategoryError {
            self.error = error
        }
        catch {
            self.error = .unknownError
        }
    }
}
