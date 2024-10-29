//
//  AuthWrapper.swift
//  Weather
//
//  Created by Gohar Vardanyan on 28.10.24.
//

import FirebaseCore
import FirebaseAuth

struct AuthWrapper: AuthInterface  {
    
    var currentUser: UserInterface? {
        Auth.auth().currentUser
    }
    
    func createUser(withEmail email: String, password: String) async throws  {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn(withEmail email: String, password: String) async throws  {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
       try Auth.auth().signOut()
    }
    
    func addStateDidChangeListener(completion: @escaping (Auth, User?) -> Void) -> NSObjectProtocol {
        Auth.auth().addStateDidChangeListener { auth, user in
            completion(auth, user)
        }
    }
}
