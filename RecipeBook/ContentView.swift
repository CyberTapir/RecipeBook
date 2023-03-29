import SwiftUI
struct RecipeView: View {
    let recipe: Recipe
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
                HStack{
                    Text("Serves: " + String(recipe.serves))
                        .font(.body)
                    Text(String(recipe.timeToCook) + " minutes")
                        .font(.body)
                }
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
    @State private var cookTime = ""
    @State private var servesHowMany = ""
    
    @State private var ingredients = [String]()
    @State private var instructions = [String]()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Name", text: $name)
                    TextField("Time to Cook", text: $cookTime)
                        .keyboardType(.numberPad)
                    TextField("Serves", text: $servesHowMany)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(0..<ingredients.count, id: \.self) { index in
                        TextField("Ingredient \(index + 1)", text: $ingredients[index])
                    }
                    Button(action: {
                        ingredients.append("")
                    }, label: {
                        Label("Add Ingredient", systemImage: "plus.circle")
                    })
                    .disabled(ingredients.count >= 10)
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(0..<instructions.count, id: \.self) { index in
                        TextField("Step \(index + 1)", text: $instructions[index])
                    }
                    Button(action: {
                        instructions.append("")
                    }, label: {
                        Label("Add Step", systemImage: "plus.circle")
                    })
                    .disabled(instructions.count >= 20)
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
                            let recipe = Recipe(
                                name: name,
                                ingredients: ingredients.filter { !$0.isEmpty },
                                instructions: instructions.filter { !$0.isEmpty },
                                serves: Int(servesHowMany) ?? 0,
                                timeToCook: Int(cookTime) ?? 0
                            )
                            recipes.append(recipe)
                            presentationMode.wrappedValue.dismiss()
                        }
                        .disabled(name.isEmpty || ingredients.isEmpty || instructions.isEmpty)
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
    private func deleteRecipe(at offsets: IndexSet){
        recipes.remove(atOffsets: offsets)
        
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(recipes, id: \.name) { recipe in
                    NavigationLink(destination: RecipeView(recipe: recipe)) {
                        Text(recipe.name)
                    }
                    //.onDelete(perform: deleteRecipe)
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
