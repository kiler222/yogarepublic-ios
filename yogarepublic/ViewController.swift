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
class ViewController: UIViewController, UITextFieldDelegate {

    var login = ""
    var password = ""
    
    @IBAction func button(_ sender: Any) {
        
        hideLogin()
        showHUD()
        
        if (emailField.text?.isEmpty ?? true || passwordField.text?.isEmpty ?? true) {
            let alertController = UIAlertController(title: "Ups!", message:
                   "Email and password cannot be empty.", preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: "OK", style: .default))

               self.present(alertController, animated: true, completion: nil)
            showLogin()
            hideHUD()
            
        } else {
        
            print("PJ email: \(emailField.text), pass: \(passwordField.text)")
            
            login = emailField.text ?? ""
            password = passwordField.text ?? ""
            
            AlamofireManager.sharedInstance.efitnessLogin(email: login, password: password) { (accessToken) in
                
                if (accessToken.starts(with: "-1")) {
                    let alertController = UIAlertController(title: "Incorrect email or password.", message:
                        "Try again", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    self.showLogin()
                    self.hideHUD()
                } else {
                    
                    print("PJ token odczytany: \(accessToken)")
                    
                    AlamofireManager.sharedInstance.getMemberInfo(token: accessToken) { (userName) in
                        
                        if (userName.starts(with: "-1")) {
                            let alertController = UIAlertController(title: "Error downloading data", message:
                            "Try again", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Try again later", style: .default))
                            self.present(alertController, animated: true, completion: nil)
                            self.showLogin()
                            self.hideHUD()
                        } else {
                            
                            print("PJ tutajjjjj")
                            Auth.auth().signInAnonymously() { (authResult, error) in
                              // ...
                                print("PJ error: \(error)")
                                if (error == nil){
                                    
                                    FirebaseManager.sharedInstance.checkIfExist(login: self.login) { (exist) in
                                        
                                        if (exist) {
                                            
                                            FirebaseManager.sharedInstance.updateLastLogin(login: self.login)
                                            
                                            FirebaseManager.sharedInstance.getCardNumber(login: self.login) { (cardNumber) in
                                                
                                                self.cardNumber.text = cardNumber
                                                self.cardNumber.isHidden = false
                                                let writer = ZXMultiFormatWriter()
                                                do {
                                                    let result = try writer.encode(cardNumber, format: kBarcodeFormatITF, width: 240, height: 100)
                                                    let zx = ZXImage(matrix: result)
                                                    let cg = zx?.cgimage
                                                    let img = UIImage(cgImage: cg!)
                                                    self.barcodeImage.image = img
                                                    self.barcodeImage.isHidden = false
                                                } catch {
                                                    print("PJ \(error)")
                                                }
                                                self.logoutButton.isHidden = false
                                                self.userNameField.text = userName
                                                self.hideHUD()
                                                
                                            }
                                            
                                        } else {
                                            
                                            self.logoutButton.isHidden = false
                                            self.userNameField.text = userName
                                            self.hideHUD()
                                            
                                        }
                                        
                                    }
                                
                                } else {
                                     print("PJ error != nil")
                                    self.showLogin()
                                    self.hideHUD()
                                    
                                }
                            }
                            
                            
                            
                            
                            
                            
                            
                        }
                        
                        
                        
                    }
                    
                    
                }
                
                
            }
        }
        
        
    }
    
    

    
    @IBAction func emailFieldDidEndOnExit(_ sender: Any) {
         print("PJ email did end on exti")
        passwordField.becomeFirstResponder()
    }
    
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        print("PJ password did end on exti")
        
        button(sender)
        
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
    
        let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
                
        let action1 = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
            print("You've pressed default")
        }


        let action3 = UIAlertAction(title: "Yes", style: .destructive) { (action:UIAlertAction) in
            self.passwordField.text = ""
           self.emailField.text = ""
           self.userNameField.text = ""
           self.cardNumber.isHidden = true
           self.barcodeImage.isHidden = true
           self.showLogin()
           self.logoutButton.isHidden = true
        print("You've pressed the destructive")
        }

        alertController.addAction(action1)
        
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
        
        
       
        
    }
    
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userNameField: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var barcodeImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    var wasLogged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PJ VC viewdidload")
        
        AlamofireManager.sharedInstance.fetchAllRooms(){ (list1, list2) in
            //TODO - dorobic konwersje eventlist do json i zapisywania potem w userdefaults.
            eventList1 = list1
            eventList2 = list2
        }
        
        
   
        
    }
    override func viewDidAppear(_ animated: Bool) {
      
        print("PJ VC viewdidappera")
        

        
        hideHUD()
        emailField.delegate = self
        passwordField.delegate = self
              

    }

    func showHUD(){
        progressIndicator.startAnimating()
        progressIndicator.isHidden = false
    }
    
    func hideHUD(){
        progressIndicator.stopAnimating()
        progressIndicator.isHidden = true
    }

    func showLogin(){
        emailField.isHidden = false
        passwordField.isHidden = false
        button.isHidden = false
    }

    func hideLogin(){
        emailField.isHidden = true
        passwordField.isHidden = true
        button.isHidden = true
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
