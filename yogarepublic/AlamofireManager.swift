//
//  AlamofireManager.swift
//  yogarepublic
//
//  Created by kiler on 10/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import Foundation
import Alamofire
import CalendarKit


class AlamofireManager: NSObject {


     static let sharedInstance  = AlamofireManager()

// With Alamofire
func fetchAllRooms(completion: @escaping (Array<Event>, Array<Event>) -> Void) {
    var eventList1 : [Event] = []
    var eventList2 : [Event] = []
    let headers: HTTPHeaders = [
        "api-access-token": "bih/AiXX0k2mqZGz44y+Ag==",
        "Accept": "application/json"
    ]
    
    
  guard let url = URL(string: "https://api-frontend2.efitness.com.pl/api/clubs/324/schedules/classes?dateFrom=2020-02-01&dateTo=2020-02-28") else {
    completion(eventList1, eventList2)
    return
  }
  Alamofire.request(url,
                    method: .get, headers: headers)
  .validate()
  .responseJSON { response in
    guard response.result.isSuccess else {
      print("Error while fetching remote rooms: \(response.result.error)")
      completion(eventList1, eventList2)
      return
    }

    guard let value = response.result.value as? [String: Any],
      let events = value["results"] as? [[String: Any]] else {
        print("Malformed data received from fetchAllRooms service")
        completion(eventList1, eventList2)
        return
    }

    
    events.forEach { (item) in
        let event : Event = Event()
        var roomName = "puste"
        
    
        if let room = (item["roomName"] as? String)
        {
//        print("PJ roomName nil: \(item["roomName"]), \(item["startDate"])")
          roomName = room
        }
        else
        {
//         print("PJ roomName jest: \(item["roomName"]), \(item["startDate"])")
                     roomName = "sala nieznana"
        }
        
 
        
        event.text = "\(item["name"] as! String) - \(item["instructorName"] as! String)\n\(roomName)"
        let startDate = getDate(date: item["startDate"] as! String)
        let endDate = getDate(date: item["endDate"] as! String)
        event.startDate = startDate!
        event.endDate = endDate!
        let color = (item["backgroundColor"] as! String).replacingOccurrences(of: "#", with: "#ff")
//        print("PJ kolor: \(color)")
        event.backgroundColor = UIColor(hex: color)!
        
        if (roomName == "Mała Sala") {
            eventList1.append(event)
        } else {
            eventList2.append(event)
        }
        
        
    }
    
//    let rooms = rows.flatMap { roomDict in return RemoteRoom(jsonData: roomDict) }
    completion(eventList1, eventList2)
  }
}

    

    
    
}
