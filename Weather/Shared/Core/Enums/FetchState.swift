//
//  FetchState.swift
//  Weather
//
//  Created by Gohar Vardanyan on 25.10.24.
//

enum FetchState {
    case failed(AppError)
    case succeed
    case none
}
