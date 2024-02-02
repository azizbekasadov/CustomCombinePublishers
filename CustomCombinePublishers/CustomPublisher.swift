//
//  CustomPublisher.swift
//  CustomCombinePublishers
//
//  Created by Azizbek Asadov on 02/02/24.
//

import Foundation
import UIKit
import Combine

extension UIControl {
    struct EventPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Never
        
        fileprivate var control: UIControl
        fileprivate var event: Event
        
        // Cobine will call this method on our publisher whenever a new object started observing it. Within this method, we'll need to create a subscription instance and attach it to the new subscriber
        func receive<S>(
            subscriber: S
        ) where S : Subscriber, Never == S.Failure, Void == S.Input {
            let subscription = EventSubscription<S>()
            subscription.target = subscriber
            
            subscriber.receive(subscription: subscription)
            
            control.addTarget(
                subscription,
                action: #selector(subscription.trigger),
                for: event
            )
        }
    }
    
    class EventSubscription<Target: Subscriber>: Subscription where Target.Input == Void {
        var target: Target?
        
        func request(_ demand: Subscribers.Demand) {
            print(demand.description)
        }
        
        func cancel() {
            target = nil
        }
        
        @objc
        final func trigger() {
            target?.receive(())
        }
    }
    
    func publisher(for event: Event) -> EventPublisher {
        EventPublisher(control: self, event: event)
    }
}


class TestView: UIView {
    let button = UIButton()
    
    init() {
        super.init(frame: .zero)
        
        button.publisher(for: .touchUpInside).sink { _ in
            print("button pressed")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIButton {
    var tapPublisher: EventPublisher {
        publisher(for: .touchUpInside)
    }
}

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        publisher(for: .editingChanged)
            .map { self.text ?? "" }
            .eraseToAnyPublisher()
    }
}

struct ShippingInfo {
    let name: String
    let street: String
    let city: String
    
    init() {
        name = ""
        street = ""
        city = ""
    }
    
    init(name: String, street: String, city: String) {
        self.name = name
        self.street = street
        self.city = city
    }
}

final class ShippingInfoVC: UIViewController {
    @Published private(set) var shippingInfo = ShippingInfo()
    
    private lazy var nameTextField = UITextField()
    private lazy var addressTextField = UITextField()
    private lazy var cityTextField = UITextField()
    
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        
        // When using combineLatest, no combined value will be emitted before
        // each of the participating publishers has sent at least one value
        nameTextField.textPublisher.combineLatest(
            addressTextField.textPublisher,
            cityTextField.textPublisher
        )
        .map(ShippingInfo.init)
        .assign(to: &$shippingInfo)
    }
}


