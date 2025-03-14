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
    var signOutError: AppError?
    var signedOut = false
    var signedInSucceed = false

                    
    var authenticatedUser: UserInterface? {
        user
    }
    
    func createUser(withEmail email: String, password: String) async throws {
        guard user != nil else {
            throw AuthenticationError.signin
        }
        signedInSucceed = true
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        guard user != nil else {
            throw AuthenticationError.signin
        }
        signedInSucceed = true
    }
    
    func signOut() throws {
        if let signOutError {
            throw signOutError
        }
        signedOut = true
    }
    
    func addStateDidChangeListener(completion: @escaping (AuthInterface, UserInterface?) -> Void) -> NSObjectProtocol {
            completion(self, user)
        return NSString(string: "")
    }

}
