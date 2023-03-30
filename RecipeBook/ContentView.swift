import SwiftUI

struct RecipeView: View {
    let recipe: Recipe
    @Binding var recipes: [Recipe]
    @State private var isPresentingEditRecipe = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(recipe.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        isPresentingEditRecipe = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                    }
                    .sheet(isPresented: $isPresentingEditRecipe) {
                        AddRecipeView(recipe: recipe, recipes: $recipes)
                    }
                }
                
                HStack{
                    Text("Serves " + String(recipe.serves) + ",")
                        .font(.body)
                    Text(String(recipe.timeToCook) + " minutes cooking time")
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
        .sheet(isPresented: $isPresentingEditRecipe) {
            AddRecipeView(recipes: $recipes)
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
    
    init(recipe: Recipe? = nil, recipes: Binding<[Recipe]>) {
        self._recipes = recipes
        
        if let recipe = recipe {
            self._name = State(initialValue: recipe.name)
            self._cookTime = State(initialValue: String(recipe.timeToCook))
            self._servesHowMany = State(initialValue: String(recipe.serves))
            self._ingredients = State(initialValue: recipe.ingredients)
            self._instructions = State(initialValue: recipe.instructions)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Name", text: $name)
                    TextField("Cook Time (in minutes)", text: $cookTime)
                        .keyboardType(.numberPad)
                    TextField("Serves", text: $servesHowMany)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(0..<ingredients.count, id: \.self) { index in
                        HStack {
                            TextField("Ingredient \(index+1)", text: $ingredients[index])
                            Button(action: {
                                ingredients.remove(at: index)
                            }) {
                                Label("Remove", systemImage: "minus")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: {
                        ingredients.append("")
                    }) {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(0..<instructions.count, id: \.self) { index in
                        TextField("Step \(index+1)", text: $instructions[index])
                    }
                    Button(action: {
                        instructions.append("")
                    }) {
                        Label("Add Step", systemImage: "plus")
                    }
                }
                
                Section {
                    Button(action: {
                        let recipe = Recipe(
                            name: name,
                            ingredients: ingredients,
                            instructions: instructions,
                            serves: Int(servesHowMany) ?? 0,
                            timeToCook: Int(cookTime) ?? 0
                        )
                        if let index = recipes.firstIndex(where: { $0.name == name }) {
                            recipes[index] = recipe
                        } else {
                            recipes.append(recipe)
                        }
                        saveRecipes()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(recipes != nil ? "Update Recipe" : "Save Recipe")
                    }

                    Spacer()
                    Button(action: {
                        if let index = recipes.firstIndex(where: { $0.name == name }) {
                            recipes.remove(at: index)
                            saveRecipes()
                            presentationMode.wrappedValue.dismiss()
                            //presentationMode.self.dismiss()
                        }
                    }){
                        Text("Delete recipe")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Recipe")
        }
    }
    
    private func saveRecipes() {
        if let data = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(data, forKey: "recipes")
        }
    }
}

struct ContentView: View {
    @State var recipes = [
        Recipe(name: "Spaghetti Bolognese", ingredients: ["500g spaghetti", "400g canned tomatoes", "1 onion", "2 garlic cloves", "500g minced beef"], instructions: ["Cook the spaghetti according to the package instructions", "Chop the onion and garlic and fry in a pan", "Add the minced beef and cook until browned", "Add the canned tomatoes and simmer for 10 minutes", "Serve the bolognese sauce over the spaghetti"], serves: 5, timeToCook: 45),
        Recipe(name: "Chicken Curry", ingredients: ["1 onion", "2 garlic cloves", "500g chicken breast", "1 can of coconut milk", "2 tbsp curry powder"], instructions: ["Chop the onion and garlic and fry in a pan", "Cut the chicken into small pieces and add to the pan", "Add the curry powder and fry for a few minutes", "Add the coconut milk and simmer for 15-20 minutes", "Serve with rice"], serves: 5, timeToCook: 45),
    ]
    //@Binding var recipes: [Recipe]
    @State var isPresentingNewRecipe = false
    @State var newRecipeTitle = ""
    
    private func deleteRecipe(at offsets: IndexSet){
        recipes.remove(atOffsets: offsets)
    }
    
    private func loadRecipes() {
        if let data = UserDefaults.standard.data(forKey: "recipes"),
           let storedRecipes = try? JSONDecoder().decode([Recipe].self, from: data) {
            recipes = storedRecipes
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recipes) { recipe in
                    RecipeView(recipe: recipe, recipes: $recipes)
                }
                .onDelete(perform: deleteRecipe)
            }
            .navigationBarTitle("Recipes")
            .navigationBarItems(
                trailing: Button(action: {
                    isPresentingNewRecipe = true
                    //AddRecipeView(name: name, ingredients: $recipes.ingredients, instructions: $recipes.instructions, serves: $recipes.serves, timeToCook: $recipes.timeToCook)
                }) {
                    Image(systemName: "plus.circle.fill")
                }
            )
            .sheet(isPresented: $isPresentingNewRecipe) {
                AddRecipeView(recipes: $recipes)
            }
            .onAppear(perform: loadRecipes)
        }
    }
    
    private func saveRecipes() {
        if let data = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(data, forKey: "recipes")
        }
    }
}
