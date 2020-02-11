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
                print("PJ Document data: \(dataDescription)")
                let cardNumber = document.data()!["cardNumber"] as! String
                completion(cardNumber)
            } else {
                print("PJ user does not exist: \(error?.localizedDescription)")
                completion("-1")
            }
            
            
//            if let err = err {
//                print("PJ Error getting documents: \(err)")
//            } else {
//                var itemList: [Item] = []
//                for document in querySnapshot!.documents {
//
//                    let itemName = document.data()["itemName"] as! String
//                    let itemPrice = document.data()["itemPrice"] as! Int
//                    let itemDescription = document.data()["itemDescription"] as! String
//                    let itemLocation = document.data()["itemLocation"] as! GeoPoint
//                    let itemImages = document.data()["itemImages"] as! Array<String>
//                    let category = document.data()["category"] as! String
//
//                    let tempItem = Item(itemName: itemName, itemPrice: itemPrice,
//                                        itemDescription: itemDescription, itemImages: itemImages,
//                                        itemLocation: itemLocation, category: category)
////                    print("PJ \(document.documentID) => \(document.data())")
//                    itemList.append(tempItem)
//                }
//
//
//                completion(itemList)
//
//
//            }
        }
        
    }

    
    
    
}
