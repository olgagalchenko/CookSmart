//
//  IngredientListView.swift
//  cake
//
//  Created by Vova Galchenko on 11/25/23.
//  Copyright © 2023 Olga Galchenko. All rights reserved.
//

import SwiftUI

struct IngredientListView: View {
  @StateObject private var ingredientsStore: IngredientsStore
  @State private var searchText: String = ""
  @State private var isShowingResetAlert = false
  private var ingredientGroupsToPresent: [any IngredientGroup] {
    let relevantGroups = if searchText.isEmpty {
      ingredientsStore.ingredientGroups
    } else {
      ingredientsStore.ingredientGroups.compactMap { group in
        group.filter(searchString: searchText)
      }
    }
    return relevantGroups.filter { !$0.ingredients.isEmpty }
  }

  weak var delegate: IngredientListViewDelegate?

  init(
    ingredientsStore: @escaping @autoclosure () -> IngredientsStore = IngredientsStore.shared,
    delegate: IngredientListViewDelegate? = nil
  ) {
    _ingredientsStore = StateObject(wrappedValue: ingredientsStore())
    self.delegate = delegate
  }

  var body: some View {
    NavigationView {
      List {
        ForEach(ingredientGroupsToPresent, id: \.id) { group in
          // I actually think in this case it's more readable to keep this code inline,
          // than to extract it into IngredientGroupSection, because of the strong ties
          // it has back to this struct, but the compiler crashes when the section code
          // is here inline :(
          IngredientGroupSection(group: group, delegate: delegate)
        }
      }
      .listStyle(PlainListStyle())
      // O&A Question: There's apparently no way to customize the appearance of the search bar... what do you suggest?
      .searchable(text: $searchText, prompt: "ingredient name")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(
            action: {
              self.delegate?.ingredientListViewSelected(ingredientAtFlattenedIndex: 0)
            },
            label: {
              Image(systemName: "xmark")
                .foregroundStyle(CSColor.accent.asSwiftUIColor())
            }
          )
        }
        ToolbarItem(placement: .principal) {
          Text("Ingredients").csTextStyle(.heading)
        }
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink(
            destination: EditIngredientViewWithToolbar(),
            label: {
              Image(systemName: "plus")
                .foregroundStyle(CSColor.accent.asSwiftUIColor())
            }
          )
        }
        ToolbarItem(placement: .bottomBar) {
          Button(action: {
            isShowingResetAlert = true
          }, label: {
            Text("Reset to Defaults").csTextStyle(.plainButton)
          })
        }
      }
      .alert("Are you sure?", isPresented: $isShowingResetAlert) {
        Button("Reset", role: .destructive) {
          isShowingResetAlert = false
          // O&A Question: Why does this not trigger a nice animation?
          ingredientsStore.resetToDefault()
        }
      } message: {
        Text("Resetting to defaults will remove all your added and edited ingredients")
      }
    }
  }
}

struct IngredientGroupSection: View {
  let group: any IngredientGroup
  weak var delegate: IngredientListViewDelegate?

  var body: some View {
    Section(header: Text(group.name).csTextStyle(.subheading)) {
      ForEach(group.ingredients) { ingredient in
        IngredientListViewCell(
          ingredient: ingredient,
          delegate: delegate
        )
      }.onDelete { indexSet in
        // O&A Question: the animation is not great when an ingredient is removed that's both in recents
        // and in one of the groups. Is there a smoother way to do this?
        let groupIngrs = group.ingredients
        IngredientsStore.shared.delete(ingredientsWithIds: indexSet.map { groupIngrs[$0].id })
      }
    }
  }
}

struct IngredientListViewCell: View {
  var ingredient: Ingredient!
  weak var delegate: IngredientListViewDelegate?

  var body: some View {
    HStack {
      HStack {
        Text(ingredient.name).csTextStyle(.coreContent)
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        self.delegate?.ingredientListViewSelected(
          ingredientAtFlattenedIndex: UInt(IngredientsStore.shared.flattenedForIngredient(withId: ingredient.id))
        )
      }
      Image(systemName: "info.circle")
        .foregroundStyle(CSColor.accent.asSwiftUIColor())
        // O&A Question: Do you guys know of a less hacky way to accomplish something seemingly so basic.
        // Even with this, the tap hit box for editing ingredients is still not perfect :(
        // Also, it turns out that for some reason long-tapping anywhere in the cell triggers this action :(
        .overlay(
          NavigationLink(
            destination: EditIngredientViewWithToolbar(ingredient: ingredient),
            label: { EmptyView() }
          )
          .opacity(0)
        )
    }
  }
}

struct EditIngredientViewWithToolbar: View {
  @State var ingredient: Ingredient?
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  init(ingredient: Ingredient? = nil) {
    _ingredient = State(initialValue: ingredient)
  }

  var body: some View {
    EditIngredientView(ingredient: $ingredient)
      .ignoresSafeArea()
      .navigationBarBackButtonHidden()
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(
            action: {
              self.presentationMode.wrappedValue.dismiss()
            },
            label: {
              Text("Cancel").csTextStyle(.plainButton)
            }
          )
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(
            action: {
              if let existingIngredient = ingredient {
                IngredientsStore.shared.upsert(existingIngredient)
              }
              self.presentationMode.wrappedValue.dismiss()
            },
            label: {
              Text("Done").csTextStyle(.actionButton)
            }
          )
        }
      }
  }
}

struct EditIngredientView: UIViewControllerRepresentable {

  @Binding var ingredient: Ingredient?

  class Coordinator: NSObject, EditIngredientViewControllerDelegate {
    @Binding var ingredient: Ingredient?

    init(ingredientBinding: Binding<Ingredient?>) {
      _ingredient = ingredientBinding
    }

    func editViewControllerDidGenerate(ingredient: Ingredient) {
      if self.ingredient != ingredient {
        self.ingredient = ingredient
      }
    }
  }

  func makeUIViewController(context: Context) -> some UIViewController {
    EditIngredientViewController(ingredient: ingredient, delegate: context.coordinator)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(ingredientBinding: $ingredient)
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

// This is to be removed when we no longer need to create this in ObjC
@objc class IngredientListViewControllerFactory: NSObject {
  @objc static func create(delegate: IngredientListViewDelegate) -> UIViewController {
    UIHostingController(rootView: IngredientListView(delegate: delegate))
  }
}

@objc protocol IngredientListViewDelegate {
  @objc(ingredientListViewSelectedIngredientAtFlattenedIndex:) func ingredientListViewSelected(
    ingredientAtFlattenedIndex flattenedIndex: UInt
  )
}

#Preview {
  IngredientListView(ingredientsStore: IngredientsStore(testData: [
    StoredIngredientGroup(name: "Flour", ingredients: [
      Ingredient(
        name: "All-Purpose Flour",
        density: Density(inGramsPerCup: 125),
        lastAccessDate: Date(timeIntervalSince1970: TimeInterval(1_701_047_250))
      ),
      Ingredient(name: "Almond Flour", density: Density(inGramsPerCup: 95.67959999999)),
      Ingredient(name: "Barley Flour", density: Density(inGramsPerCup: 113.398)),
      Ingredient(name: "Bread Flour", density: Density(inGramsPerCup: 120.485)),
    ]),
    StoredIngredientGroup(name: "Sugars", ingredients: [
      Ingredient(name: "Brown Sugar, light/dark", density: Density(inGramsPerCup: 198)),
      Ingredient(name: "Powdered Sugar", density: Density(inGramsPerCup: 113)),
    ]),
    StoredIngredientGroup(name: "Oil and Shortening", ingredients: [
      Ingredient(
        name: "Butter",
        density: Density(inGramsPerCup: 227),
        lastAccessDate: Date(timeIntervalSince1970: TimeInterval(1_701_047_255))
      ),
      Ingredient(name: "Canola Oil", density: Density(inGramsPerCup: 219.5)),
      Ingredient(name: "Coconut Oil", density: Density(inGramsPerCup: 216)),
      Ingredient(name: "Lard", density: Density(inGramsPerCup: 205)),
      Ingredient(name: "Peanut Oil", density: Density(inGramsPerCup: 222)),
      Ingredient(
        name: "Olive Oil",
        density: Density(inGramsPerCup: 219.5),
        lastAccessDate: Date(timeIntervalSince1970: TimeInterval(1_701_047_244))
      ),
      Ingredient(name: "Vegetable Shortening", density: Density(inGramsPerCup: 190)),
    ]),
  ]))
}
