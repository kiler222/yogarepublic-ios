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
    
    //TODO - chowac klawiature gdy user kliknie przycisk zalogu j zmiast entera naklawiaturze
    //TODO - dodac link do resetowania hasła
    
    @IBAction func button(_ sender: Any) {
        
        hideLogin()
        showHUD()
        
        if (emailField.text?.isEmpty ?? true || passwordField.text?.isEmpty ?? true) {
            let alertController = UIAlertController(title: NSLocalizedString("Ups!", comment: ""), message:
                   NSLocalizedString("Email and password cannot be empty.", comment: ""), preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))

               self.present(alertController, animated: true, completion: nil)
            showLogin()
            hideHUD()
            
        } else {
        
//            print("PJ email: \(emailField.text), pass: \(passwordField.text)")
            
            login = emailField.text ?? ""
            password = passwordField.text ?? ""
            
            AlamofireManager.sharedInstance.efitnessLogin(email: login, password: password) { (accessToken) in
                
                if (accessToken.starts(with: "-1")) {
                    let alertController = UIAlertController(title: NSLocalizedString("Incorrect email or password.", comment: ""), message:
                        NSLocalizedString("Try again", comment: ""), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    self.showLogin()
                    self.hideHUD()
                } else {
                    
//                    print("PJ token odczytany: \(accessToken)")
                    
                    AlamofireManager.sharedInstance.getMemberInfo(token: accessToken) { (userName) in
                        
                        if (userName.starts(with: "-1")) {
                            let alertController = UIAlertController(title:  NSLocalizedString("Error downloading data", comment: ""), message:
                            NSLocalizedString("Try again", comment: ""), preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: NSLocalizedString("Try again later", comment: ""), style: .default))
                            self.present(alertController, animated: true, completion: nil)
                            self.showLogin()
                            self.hideHUD()
                        } else {
                            
//                            print("PJ tutajjjjj")
                            Auth.auth().signInAnonymously() { (authResult, error) in
                              // ...
                                print("PJ error: \(error)")
                                if (error == nil){
                                    
                                    self.localLogin = self.login
                                    FirebaseManager.sharedInstance.checkIfExist(login: self.login) { (exist) in
                                        
                                        if (exist) {
                                            
                                            FirebaseManager.sharedInstance.updateLastLogin(login: self.login)
                                            
                                            FirebaseManager.sharedInstance.getCardNumber(login: self.login) { (cardNumber) in
                                                
                                                self.localCardNumber = cardNumber
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
                                                self.wasLogged = true
                                                UserDefaults.standard.set(true, forKey: "wasLogged")
                                                UserDefaults.standard.set(userName, forKey: "userName")
                                                UserDefaults.standard.set(cardNumber, forKey: "cardNumber")
                                                UserDefaults.standard.set(self.login, forKey: "login")
                                                
                                            }
                                            
                                        } else {
                                            //TODO - srpwdzaac was logged gdy jest user w firestore i gdy go nie ma
                                            self.logoutButton.isHidden = false
                                            self.userNameField.text = userName
                                            self.hideHUD()
                                            self.wasLogged = true
                                            UserDefaults.standard.set(true, forKey: "wasLogged")
                                            UserDefaults.standard.set(userName, forKey: "userName")
                                            UserDefaults.standard.set(self.login, forKey: "login")
                                            
                                        }
                                        
                                    }
                                
                                } else {
//                                     print("PJ error != nil")
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
    
        let alertController = UIAlertController(title: NSLocalizedString("Log out", comment: ""), message: NSLocalizedString("Are you sure you want to log out?", comment: ""), preferredStyle: .actionSheet)
                
        let action1 = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default) { (action:UIAlertAction) in
            print("You've pressed default")
        }


        let action3 = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive) { (action:UIAlertAction) in
            self.passwordField.text = ""
           self.emailField.text = ""
           self.userNameField.text = ""
           self.cardNumber.isHidden = true
           self.barcodeImage.isHidden = true
           self.showLogin()
           self.logoutButton.isHidden = true
            self.wasLogged = false //TODO usunac z userdefault
            UserDefaults.standard.set(false, forKey: "wasLogged")
            UserDefaults.standard.set("", forKey: "login")
            UserDefaults.standard.set("", forKey: "userName")
            UserDefaults.standard.set("", forKey: "cardNumber")
            
            
        print("You've pressed the destructive")
        }

        alertController.addAction(action1)
        
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
        
        
       
        
    }
    
    @IBAction func forgetPasswordButton(_ sender: Any) {
        
        let link = "https://yogarepublic-cms.efitness.com.pl/Login/SystemResetPassword?returnurl=https%3A%2F%2Fyogarepublic-cms.efitness.com.pl%2F"

            UIApplication.shared.open(URL(string: link)!)
        
    }
   
    
    @IBOutlet weak var forgetPasswordButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userNameField: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var barcodeImage: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    var wasLogged = false
    var localCardNumber = ""
    var localUserName = ""
    var localLogin = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PJ VC viewdidload")
        
        AlamofireManager.sharedInstance.fetchAllRooms(){ (list1, list2) in
            //TODO - dorobic konwersje eventlist do json i zapisywania potem w userdefaults.
            eventList1 = list1
            eventList2 = list2
        }

   
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("PJ touches Began")
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
      
        print("PJ VC viewdidappera")
        hideHUD()
        emailField.delegate = self
        passwordField.delegate = self
        
        
        forgetPasswordButton.setTitle(NSLocalizedString("Forgot password?", comment: ""), for: .normal)
        
//        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
//        view.addGestureRecognizer(tap)
        let defaults = UserDefaults.standard
        let checkWasLogged = defaults.bool(forKey: "wasLogged")
        
        print("PJ nigdy nie było checkwaslogged ustawione \(checkWasLogged)")
        
        

        if checkWasLogged {
        
            
            
            
            hideLogin()
            localLogin = defaults.string(forKey: "login") ?? ""
            localUserName = defaults.string(forKey: "userName") ?? ""
            
            print("PJ odczytany username z UD: \(localUserName)")
            localCardNumber = defaults.string(forKey: "cardNumber") ?? ""
            
            userNameField.text = localUserName
           
            logoutButton.isHidden = false
           
            if (localCardNumber == "") {
                cardNumber.isHidden = true
                barcodeImage.isHidden = true
                
                FirebaseManager.sharedInstance.checkIfExist(login: localLogin) { (exist) in
                               
                    if exist {
                        FirebaseManager.sharedInstance.getCardNumber(login: self.localLogin) { (cNumber) in
                            UserDefaults.standard.set(cNumber, forKey: "cardNumber")
                            self.cardNumber.text = cNumber
                            self.cardNumber.isHidden = false
                           let writer = ZXMultiFormatWriter()
                           do {
                               let result = try writer.encode(cNumber, format: kBarcodeFormatITF, width: 240, height: 100)
                               let zx = ZXImage(matrix: result)
                               let cg = zx?.cgimage
                               let img = UIImage(cgImage: cg!)
                               self.barcodeImage.image = img
                               self.barcodeImage.isHidden = false
                           } catch {
                               print("PJ \(error)")
                           }
                            
                        }
                    }
                }
                
                
            } else {
                cardNumber.text = localCardNumber
                cardNumber.isHidden = false
                let writer = ZXMultiFormatWriter()
                do {
                    let result = try writer.encode(localCardNumber, format: kBarcodeFormatITF, width: 240, height: 100)
                    let zx = ZXImage(matrix: result)
                    let cg = zx?.cgimage
                    let img = UIImage(cgImage: cg!)
                    self.barcodeImage.image = img
                    self.barcodeImage.isHidden = false
                } catch {
                    print("PJ \(error)")
                }
            }
            
            
            
            
        }
        
        
        
              

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
        forgetPasswordButton.isHidden = false
    }

    func hideLogin(){
        emailField.isHidden = true
        passwordField.isHidden = true
        button.isHidden = true
        forgetPasswordButton.isHidden = true 
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


