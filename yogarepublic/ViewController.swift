//
//  ViewController.swift
//  yogarepublic
//
//  Created by kiler on 10/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import UIKit
import CalendarKit
import RSBarcodes_Swift
import AVFoundation


var eventList1 : [Event] = []
var eventList2 : [Event] = []

class ViewController: UIViewController {

    @IBAction func button(_ sender: Any) {
        
//          if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemDetailsViewController") as? ItemDetailsViewController
                  
        
        let vc = TimetableViewController()
        
        present(vc, animated: true, completion: nil)
                    
        
        
    }
    
    
    
    @IBOutlet weak var barcodeImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        AlamofireManager.sharedInstance.fetchAllRooms(){ (list1, list2) in
            
            
            eventList1 = list1
            eventList2 = list2
            
        }
            
       
   
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let gen = RSUnifiedCodeGenerator.shared
                 gen.fillColor = UIColor.white
                 gen.strokeColor = UIColor.black
                    let code = "1234"
                 
                 if let image = gen.generateCode(code, machineReadableCodeObjectType: AVMetadataObject.ObjectType.itf14.rawValue) {
                     self.barcodeImage.layer.borderWidth = 1
                     
                     barcodeImage.image = image //RSAbstractCodeGenerator.resizeImage(image, targetSize: self.barcodeImage.bounds.size, contentMode: UIView.ContentMode.bottomRight)
                 } else {
                    print("PJ blad generowanie itf14")
                }
              
    }

    


}

public func getDate(date: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.locale = Locale.current
    return dateFormatter.date(from: date)
}


extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
