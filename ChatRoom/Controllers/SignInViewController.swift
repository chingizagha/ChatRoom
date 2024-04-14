//
//  SignInViewController.swift
//  ChatRoom
//
//  Created by Chingiz on 11.04.24.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SignInViewController: UIViewController {
    
    let googleButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButton()
        configureGoogleSignIn()
    }
    
    private func configureButton() {
        view.addSubview(googleButton)
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.addTarget(self, action: #selector(didTapGoogleSignIn), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureGoogleSignIn() {
        let clientID = "871186967527-67acsng0f5nbh7g3q6d9c493qg8lumr1.apps.googleusercontent.com"
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    @objc
    private func didTapGoogleSignIn() {
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else {
                // ...
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            AuthManager.shared.signIn(cred: credential)
            
            
        }
    }
    
    
}

