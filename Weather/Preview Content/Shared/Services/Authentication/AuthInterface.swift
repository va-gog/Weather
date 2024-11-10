//
//  AuthInterface.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import FirebaseAuth

protocol AuthInterface {
    var currentUser: UserInterface? { get }
    
    func createUser(withEmail email: String, password: String) async throws
    func signIn(withEmail email: String, password: String) async throws
    func signOut() throws
    func addStateDidChangeListener(completion: @escaping (AuthInterface, UserInterface?) -> Void) -> NSObjectProtocol
}

