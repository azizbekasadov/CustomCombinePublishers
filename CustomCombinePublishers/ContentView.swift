//
//  ContentView.swift
//  CustomCombinePublishers
//
//  Created by Azizbek Asadov on 02/02/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    let canvas = CanvasView()
    
    lazy var subscription = canvas.tapPublisher
        .removeDuplicates()
        .sink { point in
            print(point)
        }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


class CanvasView: UIView {
    var tapPublisher: AnyPublisher<CGPoint, Never> {
        tapSubject.eraseToAnyPublisher()
    }
    
    private let tapSubject = PassthroughSubject<CGPoint, Never>()
    
    @objc
    private func handle(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        tapSubject.send(location)
    }
}

// PassthroughSubject simply passes any values that were sent to it along to its observers without storing those values

// CurrentValueSubject - stores a copy of the latest value that was sent to it, which can then later be retrieved

