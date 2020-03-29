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
}

struct IngredientListView: View {
  @State private var searchText: String = ""

  var body: some View {
    NavigationView {
      VStack {
        SearchBar(text: $searchText)
        List {
          Text("test")
        }
      }
      .navigationBarTitle("Ingredients")
      .navigationBarItems(leading:
        Button(action: {
          print("Pressed")
        }, label: {
          Image(systemName: "xmark")
            .font(Font.system(size: 20, weight: .medium, design: .default))
        })
      )
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
    searchBar.delegate = context.coordinator
    searchBar.searchBarStyle = .minimal
    return searchBar
  }

  func updateUIView(_ uiView: UISearchBar, context _: UIViewRepresentableContext<SearchBar>) {
    uiView.text = text
  }
}

private struct IngredientListViewController_Previews: PreviewProvider {
  static var previews: some View {
    IngredientListView()
  }
}
