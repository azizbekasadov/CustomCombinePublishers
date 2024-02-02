//
//  TodoItem.swift
//  CustomCombinePublishers
//
//  Created by Azizbek Asadov on 02/02/24.
//

import Foundation
import Combine

struct TodoItem: Identifiable {
    let id: String
    let text: String
    
    init(id: String = UUID().uuidString, text: String) {
        self.id = id
        self.text = text
    }
}

class TodoList {
    @Published private(set) var items: [TodoItem]
    
    init(items: [TodoItem]) {
        self.items = items
    }
    
    func addItem(named name: String) {
        items.append(.init(text: name))
    }
}


let list = TodoList(items: [])
let allItemsSubsciption = list.$items.sink { items in
    print(items.description)
}

let firstItemSubscription = list.$items
    .compactMap(\.first)
    .sink { item in
        print(item.text)
    }

