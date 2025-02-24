//
//  Reducer.swift
//  Weather
//
//  Created by Gohar Vardanyan on 10.02.25.
//

import SwiftUI
import Combine

protocol ReducerState: ObservableObject {}
protocol Action { }

protocol Reducer: ObservableObject {
    associatedtype State: ReducerState
    
    var cancelables: [AnyCancellable] { get set }
    var state: State { get }
    
    func send(_ action: Action)
    func observableReducer()
}

extension Reducer {
    func observableReducer()  {
         state.objectWillChange
            .receive(on: RunLoop.main)
            .sink { _ in
                (self.objectWillChange as? ObservableObjectPublisher)?.send()
            }
            .store(in: &cancelables)
    }
}
