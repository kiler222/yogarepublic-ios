//
//  ViewController.swift
//  yogarepublic
//
//  Created by kiler on 10/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import UIKit
import CalendarKit
import FirebaseAuth
import AVFoundation
import ZXingObjC


var eventList1 : [Event] = []
var eventList2 : [Event] = []
var tempLogin = "pjobkiewicz@gmail.com"
class ViewController: UIViewController, UITextFieldDelegate {

    @IBAction func button(_ sender: Any) {
        
//          if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemDetailsViewController") as? ItemDetailsViewController
//        let vc = TimetableViewController()
//        present(vc, animated: true, completion: nil)
                    
        
//        print("PJ email: \(emailField.text), pass: \(passwordField.text)")
        
        
    }
    
    

    
    @IBAction func emailFieldDidEndOnExit(_ sender: Any) {
         print("PJ email did end on exti")
        passwordField.becomeFirstResponder()
    }
    
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        print("PJ password did end on exti")
        
    }
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var cardNumber: UILabel!
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//    }
//    
    override func viewDidAppear(_ animated: Bool) {
        var code = ""
        emailField.delegate = self
        passwordField.delegate = self
              
        Auth.auth().signInAnonymously() { (authResult, error) in
          // ...
            FirebaseManager.sharedInstance.getCardNumber(login: tempLogin) { (cardNumber) in
                code = cardNumber
                self.cardNumber.text = code
                let writer = ZXMultiFormatWriter()
                do {
                    let result = try writer.encode(code, format: kBarcodeFormatITF, width: 240, height: 100)
                    let zx = ZXImage(matrix: result)
                    let cg = zx?.cgimage
                    let img = UIImage(cgImage: cg!)
                    self.barcodeImage.image = img
                } catch {
                    print("PJ \(error)")
                }
            }
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
