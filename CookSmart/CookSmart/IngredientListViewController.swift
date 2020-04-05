//
//  IngredientListViewController.swift
//  cake
//
//  Created by Alex King on 3/28/20.
//  Copyright © 2020 Olga Galchenko. All rights reserved.
//

import Foundation
import SwiftUI

class IngredientListViewController: UIHostingController<IngredientListView> {
  init() {
    super.init(rootView: IngredientListView())
  }

  @objc
  dynamic required init?(coder _: NSCoder) {
    assertionFailure("init(coder:) has not been implemented")
    return nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    CSIngredients.sharedInstance()?.refreshRecents()
  }
}

struct IngredientListView: View {
  @State private var searchText: String = ""

  var body: some View {
    NavigationView {
      List {
        SearchBar(text: $searchText)
        ForEach(CSIngredients.sharedInstance()!.ingredientList) { group in
          Section(header: Text(group.name)) {
            ForEach(group.ingredients) { ingredient in
              IngredientListCell(ingredientName: ingredient.name)
            }
          }
        }
      }
      .listStyle(GroupedListStyle())
      .navigationBarTitle("Ingredients")
      .navigationBarItems(leading:
        Button(action: {
          print("Pressed")
        }, label: {
          Image(systemName: "xmark")
            .foregroundColor(SwiftUI.Color(Color.cakeRed))
            .font(Font.system(size: 20, weight: .medium, design: .default))
        }),
                          trailing:
        NavigationLink(destination: CSEditIngredientVCRepresentable(),
                       label: { Image(systemName: "plus")
                         .foregroundColor(SwiftUI.Color(Color.cakeRed))
                         .font(Font.system(size: 20, weight: .medium, design: .default))
                       }))
    }
  }
}

struct IngredientListCell: View {
  private let ingredientName: String

  init(ingredientName: String = "Sugar") {
    self.ingredientName = ingredientName
  }

  var body: some View {
    ZStack {
      NavigationLink(destination: CSEditIngredientVCRepresentable()) {
        EmptyView()
      }.buttonStyle(PlainButtonStyle())
      HStack {
        Text(ingredientName)
        Spacer()
        Button(action: {
          print("Edit Tapped")
        }, label: {
          Image(systemName: "pencil.circle")
            .foregroundColor(SwiftUI.Color(Color.cakeRed))
            .font(Font.system(size: 22, weight: .regular, design: .default))
          }).buttonStyle(BorderlessButtonStyle())
      }
    }
  }
}

private struct SearchBar: UIViewRepresentable {
  @Binding var text: String

  class Coordinator: NSObject, UISearchBarDelegate {
    @Binding var text: String

    init(text: Binding<String>) {
      _text = text
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
      text = searchText
    }
  }

  func makeCoordinator() -> SearchBar.Coordinator {
    Coordinator(text: $text)
  }

  func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
    let searchBar = UISearchBar(frame: .zero)
    searchBar.placeholder = "Search"
    searchBar.delegate = context.coordinator
    searchBar.searchBarStyle = .minimal
    return searchBar
  }

  func updateUIView(_ uiView: UISearchBar, context _: UIViewRepresentableContext<SearchBar>) {
    uiView.text = text
  }
}

struct IngredientListViewController_Previews: PreviewProvider {
  static var previews: some View {
    IngredientListView()
  }
}
