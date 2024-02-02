//
//  FeedOutput.swift
//  CustomCombinePublishers
//
//  Created by Azizbek Asadov on 02/02/24.
//

import Foundation
import UIKit
import Combine

struct Feed<Output>: Publisher {
    typealias Failure = Never
    
    var provider: ()->Output?
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        let subscription = Subscription(feed: self, target: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension Feed {
    class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == Output {
        private let feed: Feed
        private var target: Target?
        
        init(feed: Feed, target: Target? = nil) {
            self.feed = feed
            self.target = target
        }
        
        func request(_ demand: Subscribers.Demand) {
            var demand = demand
            
            while let target = target, demand > 0 {
                if let value = feed.provider() {
                    demand -= 1
                    demand += target.receive(value)
                } else {
                    target.receive(completion: .finished)
                    break
                }
            }
        }
        
        func cancel() {
            target = nil
        }
    }
}

//let imageFeed = Feed { imageProvider.provideNextImage() }


