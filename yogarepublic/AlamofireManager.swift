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
    
    let end = Calendar.current.date(byAdding: .day, value: 31, to: Date())!.string(format: "yyyy-MM-dd")
    let start = Calendar.current.date(byAdding: .day, value: -7, to: Date())!.string(format: "yyyy-MM-dd")
    
//    print("PJ \(start) i end: \(end)")
    
  guard let url = URL(string: "https://api-frontend2.efitness.com.pl/api/clubs/324/schedules/classes?dateFrom=\(start)&dateTo=\(end)") else {
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
        
        
         

        let startDate = getDate(date: item["startDate"] as! String)
        let endDate = getDate(date: item["endDate"] as! String)
               
               

        let startHour = Calendar.current.component(.hour, from: startDate!)
        let startMinute = Calendar.current.component(.minute, from: startDate!)

        let endHour = Calendar.current.component(.hour, from: endDate!)
        let endMinute = Calendar.current.component(.minute, from: endDate!)

        var endMinuteString = ""
        
        if (endMinute > 0 && endMinute < 10) {
            endMinuteString = "0\(endMinute)"
        } else if (endMinute == 0){
            endMinuteString = "00"
        } else {
            endMinuteString = "\(endMinute)"
        }
        
        var startMinuteString = ""
        
        if (startMinute > 0 && startMinute < 10) {
            startMinuteString = "0\(startMinute)"
        } else if (startMinute == 0){
            startMinuteString = "00"
        } else {
            startMinuteString = "\(startMinute)"
        }
        
        let times = "\(startHour):\(startMinuteString) - \(endHour):\(endMinuteString)"
        
        event.text = "\(item["name"] as! String) - \(item["instructorName"] as! String)\n\(roomName)\n\(times)"
        
        event.startDate = startDate!
        event.endDate = endDate!
        let color = (item["backgroundColor"] as! String).replacingOccurrences(of: "#", with: "#ff")
        event.backgroundColor = UIColor(hex: color)!
        if (roomName == "Mała Sala") {
            eventList1.append(event)
        } else {
            eventList2.append(event)
//            print(event.text)
        }
    }
    completion(eventList1, eventList2)
  }
}

    /*
     
         Fuel.get("https://api-frontend2.efitness.com.pl/api/clubs/324/members")
             .header("Accept" to "application/json")
             .header("api-access-token" to token)
             .header("member-token" to "bearer $memberToken")
             .also { println(it) }
             .responseString { _, response, result ->


                 val (data, error) = result

     //            Log.e(TAG, "pobrany member - ${error}")
     //            Log.e(TAG, "response - ${JSONArray(data)}")

                 var obj = JSONObject(data)

                 val firstName = obj.getString("firstName")
                 val lastName = obj.getString("lastName")

     //            Log.e(TAG, obj.toString())
     //            Log.e(TAG, firstName + " " + lastName)

                 callback(firstName + " " + lastName)

             }
     
     
     */
    
    
    
    
    func getMemberInfo(token: String, completion: @escaping (String) -> Void) {
        let headers: HTTPHeaders = [
              "api-access-token": "bih/AiXX0k2mqZGz44y+Ag==",
              "Accept": "application/json",
              "member-token" : "bearer \(token)"
          ]
          

          
        guard let url = URL(string: "https://api-frontend2.efitness.com.pl/api/clubs/324/members") else {
          completion("-1: zly adres api")
          return
        }
        
        
        Alamofire.request(url,
                          method: .get, headers: headers)
          .validate()
          .responseJSON { response in
            guard response.result.isSuccess else {
              print("Error while fetching remote rooms: \(response.result.error)")
              completion("-1: blad z serwera")
              return
            }

            
//            print("PJ personal: \(response.result.value)")
            
            guard let value = response.result.value as? [String: Any],
            
                let firstName = value["firstName"] as? String,
                let lastName = value["lastName"] as? String
                
            
            else {
                print("Malformed data received from fetchAllRooms service")
                completion("-1: blad odczytu danych")
                return
            }
            
         
            completion("\(firstName) \(lastName)")
            
           }

    }
    
    
    func efitnessLogin(email: String, password: String, completion: @escaping (String) -> Void) {
        let headers: HTTPHeaders = [
              "api-access-token": "bih/AiXX0k2mqZGz44y+Ag==",
              "Accept": "application/json",
              "Content-type": "application/json"
          ]
          

          
        guard let url = URL(string: "https://api-frontend2.efitness.com.pl/api/clubs/324/token/member") else {
          completion("-1: zly adres api")
          return
        }
        
        let params : Parameters = ["login" : email, "password" : password]

        
        Alamofire.request(url,
                          method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
          .validate()
          .responseJSON { response in
            guard response.result.isSuccess else {
              print("Error while fetching remote rooms: \(response.result.error)")
              completion("-1: blad z serwera")
              return
            }

            
            guard let value = response.result.value as? [String: Any],
            
                let accessToken = value["accessToken"] as? String else {
                print("Malformed data received from fetchAllRooms service")
                completion("-1: blad odczytu danych")
                return
            }
            
         
            completion(accessToken)
            
           }

    }
    
    
    
    
    

    
    
}


extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
