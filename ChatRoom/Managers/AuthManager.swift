//
//  AuthManager.swift
//  ChatRoom
//
//  Created by Chingiz on 11.04.24.
//

import UIKit
import FirebaseAuth

class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {}
    
    func signIn(cred: AuthCredential) {
        Auth.auth().signIn(with: cred) { result, error in
            guard let user = result?.user, error == nil else {
                return
            }
            
            
            let targetVC = UINavigationController(rootViewController: ChatRoomViewController(currentUser: user))
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc: targetVC)
        }
    }
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
    
}
