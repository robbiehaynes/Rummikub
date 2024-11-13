//
//  GameRoom.swift
//  Rummikub
//
//  Created by Robert Haynes on 2024/11/12.
//

import Foundation
import FirebaseFirestore

class GameRoom : Codable {
    
    var gameCode: String
    var createdAt: Timestamp
    var players: [String]
    
    enum CodingKeys: String, CodingKey {
        case gameCode
        case createdAt
        case players
    }
    
    init(gameCode: String, createdAt: Timestamp = Timestamp(), players: [String] = [UIDevice.current.identifierForVendor!.uuidString]) {
        self.gameCode = gameCode
        self.createdAt = createdAt
        self.players = players
    }
    
    func save() async throws {
        let db = Firestore.firestore()
        
        try db.collection("gameRooms").document(gameCode).setData(from: self)
    }
    
    func join() async throws {
        let db = Firestore.firestore()
        
        // Locally
        await players.append(UIDevice.current.identifierForVendor!.uuidString)
        
        // Online
        try await db.collection("gameRooms").document(gameCode).updateData([
            "players": FieldValue.arrayUnion([UIDevice.current.identifierForVendor!.uuidString])
        ])
    }
    
    func leave() {
        let db = Firestore.firestore()
        
        players.removeAll { $0 == UIDevice.current.identifierForVendor!.uuidString }
        
        if players.isEmpty {
            db.collection("gameRooms").document(gameCode).delete { error in
                if let error = error {
                    print("Error deleting game room: \(error)")
                }
            }
        } else {
            db.collection("gameRooms").document(gameCode).updateData([
                "players": FieldValue.arrayRemove([UIDevice.current.identifierForVendor!.uuidString])
            ]) { error in
                if let error = error {
                    print("Error updating players in game room: \(error)")
                }
            }
        }
    }
    
    static func create() async throws -> GameRoom {
        let gameCode = try await generateUniqueGameCode()
        return GameRoom(gameCode: gameCode)
    }
    
    static func fetchGameRoom(withCode code: String) async throws -> GameRoom? {
        let db = Firestore.firestore()
        let docRef = db.collection("gameRooms").document(code)
        var gameRoom : GameRoom? = nil

        do {
            gameRoom = try await docRef.getDocument(as: GameRoom.self)
            print("gameRoom: \(gameRoom!)")
        } catch {
            print("Error decoding gameRoom: \(error)")
        }
        
        return gameRoom
    }
    
    private static func generateUniqueGameCode() async throws -> String {
        let db = Firestore.firestore()
        
        while true {
            let gameCode = String(format: "%06d", Int.random(in: 0...999_999))
            
            // Query Firestore for existing game code
            let doc = try await db.collection("gameRooms").document(gameCode).getDocument()
            
            // If no documents are found, the game code is unique
            if !doc.exists {
                return gameCode
            }
        }
    }
}
