//
//  Message.swift
//  ChatRoom
//
//  Created by Chingiz on 11.04.24.
//

import Foundation

struct Message: Codable {
    let text: String
    let photoURL: String
    let uid: String
    let createdAt: Date
}
