//
//  MockAuth.swift
//  Weather
//
//  Created by Gohar Vardanyan on 29.10.24.
//

@testable import Weather
import FirebaseAuth

final class MockAuth: AuthInterface {
    var user: MockUser?
                    
    var currentUser: UserInterface? {
        user
    }
    
    func createUser(withEmail email: String, password: String) async throws {
        guard user != nil else {
            throw AuthenticationError.signin
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        guard user != nil else {
            throw AuthenticationError.signin
        }
    }
    
    func signOut() throws {}
    
    func addStateDidChangeListener(completion: @escaping (Auth, User?) -> Void) -> NSObjectProtocol {
        return NSString(string: "")
    }

}
