//
//  FirebaseManager.swift
//  yogarepublic
//
//  Created by kiler on 11/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import Foundation
import FirebaseFirestore


class FirebaseManager: NSObject {

    public var token : String?
    static let sharedInstance  = FirebaseManager()
    var db: Firestore!

    func getCardNumber(login: String, completion: @escaping (String) -> Void){
//        print("PJ get Items")
        db = Firestore.firestore()
        
        db.collection("users").document(login).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("PJ getCardNumber data: \(dataDescription)")
                let cardNumber = document.data()!["a"] as! String
                completion(cardNumber)
            } else {
                print("PJ user does not exist: \(error?.localizedDescription)")
                completion("-1")
            }
            
        }
        
    }

    func checkIfExist(login: String, completion: @escaping (Bool) -> Void){
        db = Firestore.firestore()
        db.collection("users").document(login).getDocument { (document, error) in
            
            if (document!.exists) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func updateLastLogin(login: String){
        db = Firestore.firestore()
        db.collection("users").document(login).updateData(["ll": Timestamp()]) { err in
            if let err = err {
                print("PJ Error updating lastlogin document: \(err)")
            } else {
                print("PJ Lastlogin successfully updated")
            }
        }

    }
    
}
