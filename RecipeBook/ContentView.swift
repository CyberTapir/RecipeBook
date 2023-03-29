import SwiftUI

struct RecipeView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text("Serves: " + String(recipe.serves))
                    .font(.body)
                Text(String(recipe.timeToCook) + " minutes")
                    .font(.body)
                Text("Ingredients:")
                    .fontWeight(.bold)
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("- \(ingredient)")
                }
                Text("Instructions:")
                    .fontWeight(.bold)
                ForEach(recipe.instructions, id: \.self) { step in
                    Text("- \(step)")
                }
            }
            .padding()
        }
    }
}
struct AddRecipeView: View {
    @Binding var recipes: [Recipe]
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var ingredients = ""
    @State private var instructions = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Name", text: $name)
                    TextField("Ingredients", text: $ingredients)
                    TextField("Instructions", text: $instructions)
                }
            }
            .navigationBarTitle("New Recipe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        Button("Save") {
                            let newRecipe = Recipe(name: name, ingredients: ingredients.components(separatedBy: ","), instructions: instructions.components(separatedBy: ","), serves: 5, timeToCook: 4)
                            recipes.append(newRecipe)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @State var recipes = [
        Recipe(name: "Spaghetti Bolognese", ingredients: ["500g spaghetti", "400g canned tomatoes", "1 onion", "2 garlic cloves", "500g minced beef"], instructions: ["Cook the spaghetti according to the package instructions", "Chop the onion and garlic and fry in a pan", "Add the minced beef and cook until browned", "Add the canned tomatoes and simmer for 10 minutes", "Serve the bolognese sauce over the spaghetti"], serves: 5, timeToCook: 45),
        Recipe(name: "Chicken Curry", ingredients: ["1 onion", "2 garlic cloves", "500g chicken breast", "1 can of coconut milk", "2 tbsp curry powder"], instructions: ["Chop the onion and garlic and fry in a pan", "Cut the chicken into small pieces and add to the pan", "Add the curry powder and fry for a few minutes", "Add the coconut milk and simmer for 15-20 minutes", "Serve with rice"], serves: 5, timeToCook: 45),
    ]
    @State var isPresentingNewRecipe = false
    @State var newRecipeTitle = ""
    var body: some View {
        NavigationView {
                    List {
                        ForEach(recipes, id: \.name) { recipe in
                            NavigationLink(destination: RecipeView(recipe: recipe)) {
                                Text(recipe.name)
                            }
                        }
                    }
                    .navigationTitle("Recipes")
                    .navigationBarItems(trailing:
                        Menu {
                            Button(action: {
                                // Handle adding a new recipe here
                                self.isPresentingNewRecipe = true
                            }) {
                                Label("New Recipe", systemImage: "plus")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    )
                    .sheet(isPresented: $isPresentingNewRecipe) {
                        AddRecipeView(recipes: $recipes)
                        
                    }
                }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
