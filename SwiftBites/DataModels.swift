import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) let id: UUID
    var name: String
    @Relationship(inverse: \Recipe.category) var recipes: [Recipe] = []
    
    init(id: UUID = UUID(), name: String = "") {
        self.id = id
        self.name = name
    }
}

enum CategoryError: LocalizedError, Identifiable {
    case categoryExists
    case unknownError
    
    var id: Self { self }
    
    var errorDescription: String? {
        switch self {
        case .categoryExists:
            return "A category with this name already exists"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

extension Category {
    static func exists(withName name: String, excluding excludedID: UUID? = nil, in context: ModelContext) throws -> Bool {
        let nameDescriptor = FetchDescriptor<Category>(predicate: #Predicate<Category> { $0.name == name })
        let matchingCategories = try context.fetch(nameDescriptor)
        
        if let excludedID = excludedID {
            return matchingCategories.contains { $0.id != excludedID }
        } else {
            return !matchingCategories.isEmpty
        }
    }
}

@Model
final class Recipe {
    @Attribute(.unique) let id: UUID
    var name: String
    var summary: String
    var category: Category?
    var serving: Int
    var time: Int
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe) var ingredients: [RecipeIngredient] = []
    var instructions: String
    var imageData: Data?
    
    init(
        id: UUID = UUID(),
        name: String = "",
        summary: String = "",
        category: Category? = nil,
        serving: Int = 1,
        time: Int = 5,
        instructions: String = "",
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.serving = serving
        self.time = time
        self.instructions = instructions
        self.imageData = imageData
        setCategory(category)
    }
    
    func setCategory(_ category: Category?) {
        if let oldCategory = self.category {
            oldCategory.recipes.removeAll { $0.id == self.id }
        }
        self.category = category
        category?.recipes.append(self)
    }
}

enum RecipeError: LocalizedError, Identifiable {
    case recipeExists
    case unknownError
    
    var id: Self { self }
    
    var errorDescription: String? {
        switch self {
        case .recipeExists:
            return "A recipe with this name already exists"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

extension Recipe {
    static func exists(withName name: String, excluding excludedID: UUID? = nil, in context: ModelContext) throws -> Bool {
        let nameDescriptor = FetchDescriptor<Recipe>(predicate: #Predicate<Recipe> { $0.name == name })
        let matchingRecipes = try context.fetch(nameDescriptor)
        
        if let excludedID = excludedID {
            return matchingRecipes.contains { $0.id != excludedID }
        } else {
            return !matchingRecipes.isEmpty
        }
    }
}

@Model
final class RecipeIngredient {
    @Attribute(.unique) let id: UUID
    private(set) var ingredient: Ingredient?
    var quantity: String
    private(set) var recipe: Recipe?
    
    init(id: UUID = UUID(), ingredient: Ingredient, quantity: String = "", recipe: Recipe? = nil) {
        self.id = id
        self.quantity = quantity
        setRecipe(recipe)
        setIngredient(ingredient)
    }
    
    func setIngredient(_ ingredient: Ingredient?) {
        self.ingredient = ingredient
    }
    
    func setRecipe(_ recipe: Recipe?) {
        self.recipe = recipe
    }
}

@Model
final class Ingredient {
    @Attribute(.unique) let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String = "") {
        self.id = id
        self.name = name
    }
}

enum IngredientError: LocalizedError, Identifiable {
    case ingredientExists
    case unknownError
    
    var id: Self { self }
    
    var errorDescription: String? {
        switch self {
        case .ingredientExists:
            return "An ingredient with this name already exists"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

extension Ingredient {
    static func exists(withName name: String, excluding excludedID: UUID? = nil, in context: ModelContext) throws -> Bool {
        let nameDescriptor = FetchDescriptor<Ingredient>(predicate: #Predicate<Ingredient> { $0.name == name })
        let matchingIngredients = try context.fetch(nameDescriptor)
        
        if let excludedID = excludedID {
            return matchingIngredients.contains { $0.id != excludedID }
        } else {
            return !matchingIngredients.isEmpty
        }
    }
}
