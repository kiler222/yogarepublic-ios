//
//  TimetableViewController.swift
//  yogarepublic
//
//  Created by kiler on 10/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import UIKit
import CalendarKit
import DateToolsSwift


class TimetableViewController: DayViewController {

    var eventList : [Event] = []
    var data = [["Breakfast at Tiffany's",
     "New York, 5th avenue"],

    ["Workout",
     "Tufteparken"],

    ["Meeting with Alex",
     "Home",
     "Oslo, Tjuvholmen"],

    ["Beach Volleyball",
     "Ipanema Beach",
     "Rio De Janeiro"],

    ["WWDC",
     "Moscone West Convention Center",
     "747 Howard St"],

    ["Google I/O",
     "Shoreline Amphitheatre",
     "One Amphitheatre Parkway"],

    ["✈️️ to Svalbard ❄️️❄️️❄️️❤️️",
     "Oslo Gardermoen"],

    ["💻📲 Developing CalendarKit",
     "🌍 Worldwide"],

    ["Software Development Lecture",
     "Mikpoli MB310",
     "Craig Federighi"],

    ]
    
    
    var colors = [UIColor.blue,
                   UIColor.yellow,
                   UIColor.green,
                   UIColor.red]
    
    
//     var currentStyle = SelectedStyle.Light
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PJ uruchominy timetabeview controller: eventów = \(eventList.count)\n\(eventList[0].text)")
        print("PJ uruchominy timetabeview controller: start i end = \(eventList[0].startDate) i \(eventList[0].endDate)")
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        dayView.scrollTo(hour24: 6.0)
    }
    
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
      
        print("PJ data: \(date)")
        var date = date.add(TimeChunk.dateComponents(hours: Int(arc4random_uniform(10) + 5)))
      var events = [Event]()

        print("PJ data add: \(date)")
        
      for i in 0...4 {
        let event = Event()
        let duration = Int(arc4random_uniform(160) + 60)
        let datePeriod = TimePeriod(beginning: date,
                                    chunk: TimeChunk.dateComponents(minutes: duration))

        event.startDate = datePeriod.beginning!
        event.endDate = datePeriod.end!

        var info = data[Int(arc4random_uniform(UInt32(data.count)))]
      
        
        let timezone = TimeZone.ReferenceType.default
        info.append(datePeriod.beginning!.format(with: "dd.MM.YYYY", timeZone: timezone))
        info.append("\(datePeriod.beginning!.format(with: "HH:mm", timeZone: timezone)) - \(datePeriod.end!.format(with: "HH:mm", timeZone: timezone))")
        event.text = info.reduce("", {$0 + $1 + "\n"})
        event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
//        event.isAllDay = Int(arc4random_uniform(2)) % 2 == 0
        
        // Event styles are updated independently from CalendarStyle
        // hence the need to specify exact colors in case of Dark style
//        if currentStyle == .Dark {
//          event.textColor = textColorForEventInDarkTheme(baseColor: event.color)
//          event.backgroundColor = event.color.withAlphaComponent(0.6)
//        }
        
        events.append(event)

        let nextOffset = Int(arc4random_uniform(250) + 40)
        date = date.add(TimeChunk.dateComponents(minutes: nextOffset))
        event.userInfo = String(i)
      }

      return eventList //events
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
