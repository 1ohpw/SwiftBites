import SwiftUI
import SwiftData

struct IngredientForm: View {
    enum Mode: Hashable {
        case add
        case edit(Ingredient)
    }
    
    var mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .add:
            _name = .init(initialValue: "")
            title = "Add Ingredient"
        case .edit(let ingredient):
            _name = .init(initialValue: ingredient.name)
            title = "Edit \(ingredient.name)"
        }
    }
    
    private let title: String
    @State private var name: String
    @State private var error: IngredientError?
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
            }
            if case .edit(let ingredient) = mode {
                Button(
                    role: .destructive,
                    action: {
                        delete(ingredient: ingredient)
                    },
                    label: {
                        Text("Delete Ingredient")
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
    
    private func delete(ingredient: Ingredient) {
        modelContext.delete(ingredient)
        try? modelContext.save()
        dismiss()
    }
    
    private func save() {
        do {
            switch mode {
            case .add:
                if try Ingredient.exists(withName: name, in: modelContext) {
                    throw IngredientError.ingredientExists
                }
                
                let newIngredient = Ingredient(name: name)
                modelContext.insert(newIngredient)
            case .edit(let ingredient):
                if try Ingredient.exists(withName: name, excluding: ingredient.id, in: modelContext) {
                    throw IngredientError.ingredientExists
                }
                ingredient.name = name
            }
            try modelContext.save()
            dismiss()
        } catch let error as IngredientError {
            self.error = error
        } catch {
            self.error = .unknownError
        }
    }
}
