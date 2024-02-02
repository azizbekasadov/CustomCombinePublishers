//
//  MPublished.swift
//  CustomCombinePublishers
//
//  Created by Azizbek Asadov on 02/02/24.
//

import Foundation
import Collections

@propertyWrapper
struct MPublished<Value> {
    
    var projectedValue: Published { self }
    var wrappedValue: Value {
        didSet {
            valueDidChange()
        }
    }
    
    private var observations = MutableReference(
        value: List<(Value) -> Void>()
    )
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

private extension Published {
    func valueDidChange() {
        for closure in observations.value {
            closure(wrappedValue)
        }
    }
}

extension Published {
    func observer(with closure: @escaping (Value) -> Void) -> Cancellable {
        closure(wrappedValue)
        
        let node = observations.value.append(closure)
        return Cancellable { [weak observations] in
            observations?.value.remove(node)
            
        }
    }
}

class MCancellable {
    private var closure: (()->Void)?
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    deinit {
        cancel()
    }
    
    func cancel() {
        closure?()
        closure = nil
    }
}
