import SwiftUI

@main
struct SwiftBitesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Category.self, Recipe.self, RecipeIngredient.self, Ingredient.self])
    }
}
