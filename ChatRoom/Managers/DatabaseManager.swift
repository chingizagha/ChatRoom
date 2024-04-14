//
//  DatabaseManager.swift
//  ChatRoom
//
//  Created by Chingiz on 11.04.24.
//

import Foundation
import FirebaseFirestore
import Combine

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    
    var updatedMessagesPublisher = PassthroughSubject<[Message], Error>()
    
    func fetchAllMessages() async throws -> [Message] {
        let snapshot = try await database.collection("messages").order(by: "createdAt", descending: true).limit(to: 25).getDocuments()
        let docs = snapshot.documents
        var messages = [Message]()
        
        for doc in docs {
            let data = doc.data()
            let text = data["text"] as? String ?? ""
            let photoURL = data["photoURL"] as? String ?? ""
            let uid = data["uid"] as? String ?? ""
            let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
            let message = Message(text: text, photoURL: photoURL, uid: uid, createdAt: createdAt.dateValue())
            messages.append(message)
        }
        listenToChanges()
        return messages.reversed()
    }
    
    func sendMessageToDatabase(message: Message) {
        let messageData = [
            "text": message.text,
            "photoURL": message.photoURL,
            "uid": message.uid,
            "createdAt": Timestamp(date: message.createdAt)
        ] as [String : Any]
        database.collection("messages").addDocument(data: messageData)
    }
    
    func listenToChanges() {
        database.collection("messages").order(by: "createdAt", descending: true).limit(to: 25).addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents, error == nil else {
                return
            }
            
            var messages = [Message]()
            
            for doc in documents {
                let data = doc.data()
                let text = data["text"] as? String ?? ""
                let photoURL = data["photoURL"] as? String ?? ""
                let uid = data["uid"] as? String ?? ""
                let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
                let message = Message(text: text, photoURL: photoURL, uid: uid, createdAt: createdAt.dateValue())
                messages.append(message)
            }
            
            self?.updatedMessagesPublisher.send(messages.reversed())
        }
    }
    
}
