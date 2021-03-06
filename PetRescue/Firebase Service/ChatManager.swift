//
//  FirebaseChat.swift
//  PetRescue
//
//  Created by Flo on 10/06/2020.
//  Copyright © 2020 Flo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatManager {

    // MARK: - Properties, instances
    private var currentUserId = UserManager.currentUserId
    private let chatDatabase = Firestore.firestore().collection("Chats")
    private var docReference: DocumentReference?
    private var messages: [Message] = []
    var timeStamp = Timestamp()

    // MARK: - Methods
    /// Create new chat on Firestore if no chat already exists with both users
    func createNewChat(user2: String) {
        let users = [currentUserId, user2]
        let data: [String: Any] = ["users": users]
        chatDatabase.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat(user2: user2, callback: { msg in
                    self.messages = msg
                })
            }
        }
    }

    /// Load chat if chat exists with both users. Else call createNewChat. Returns an array of Message
    func loadChat(user2: String, callback: @escaping (_ msg: [Message]) -> Void) {
        let database = chatDatabase.whereField("users", arrayContains: currentUserId!)
        database.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                guard let queryCount = chatQuerySnap?.documents.count else { return }
                if queryCount >= 1 {
                    for doc in chatQuerySnap!.documents {
                        guard let chat = Chat(dictionary: doc.data()) else { return }
                        if chat.users.contains(user2) {
                            self.docReference = doc.reference
                             doc.reference.collection("thread")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                            if let error = error {
                                print("Error: \(error)")
                                return
                            } else {
                                self.messages.removeAll()
                                var retreiveMessages: [Message] = []
                                guard let documents = threadQuery?.documents else { return }
                                for message in documents {
                                    if let storedMessage = Message(dictionary: message.data()) {
                                        retreiveMessages.append(storedMessage)
                                    }
                                }
                                callback(retreiveMessages)
                            }
                            })
                            return
                        }
                    }
                } else {
                    self.createNewChat(user2: user2)
                }
            }
        }
    }

    /// Save messages on Firestore
    func save(_ message: Message) {
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName
        ]
        guard let docRef = docReference?.collection else { return }
        docRef("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
        })
    }

    /// Fetch chat users id
    func getChatUsers(callback: @escaping (_ currentUserDocuments: [Chat]?) -> Void) {
        guard let userId = currentUserId else { return }
        let database = chatDatabase.whereField("users", arrayContains: userId)
        database.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                guard let queryCount = chatQuerySnap?.documents.count else { return }
                if queryCount >= 1 {
                    guard let documents = chatQuerySnap?.documents else { return }
                    for doc in documents {
                        let chat = Chat(dictionary: doc.data())
                        var chatDocuments = [Chat]()
                        if let chat = chat {
                            chatDocuments.append(chat)
                        }
                        callback(chatDocuments)
                    }
                }
            }
        }
    }
}
