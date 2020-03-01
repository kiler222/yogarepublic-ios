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
//import Keys

var eventList1 : [Event] = []
var eventList2 : [Event] = []
class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    
    var login = ""
    var password = ""
    
    var recievedMemberships: Array<Membership>!
    
    //TODO - chowac klawiature gdy user kliknie przycisk zalogu j zmiast entera naklawiaturze
   
    
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
            view.endEditing(true)
            login = emailField.text ?? ""
            password = passwordField.text ?? ""
            
            AlamofireManager.sharedInstance.efitnessLogin(email: login, password: password) { (accessToken, id, refreshToken) in
                
                
                if (accessToken.starts(with: "-1")) {
                    let alertController = UIAlertController(title: NSLocalizedString("Incorrect email or password.", comment: ""), message:
                        NSLocalizedString("Try again", comment: ""), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                    self.showLogin()
                    self.hideHUD()
                } else {
                    
                    print("PJ  odczytany userID: \(id)")
                    print("PJ refreshToken: \(refreshToken)")
                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    
                    
                    AlamofireManager.sharedInstance.getMemberships(token: accessToken) { (memberships) in

                        if memberships[0].name.hasPrefix("-1") {
                            print("PJ error odczytaywania membership: \(memberships[0].name)")
                        } else {
           
                            self.recievedMemberships = memberships.sorted(by: {$0.expirationDate > $1.expirationDate})
                            self.tableView.isHidden = false
                            self.tableView.reloadData()

                        }
                       
                    }
                    
                    AlamofireManager.sharedInstance.getMemberInfo(token: accessToken) { (userName) in
                        
                        if (userName.starts(with: "-1")) {
                            let alertController = UIAlertController(title:  NSLocalizedString("Error downloading data", comment: ""), message:
                            NSLocalizedString("Try again", comment: ""), preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: NSLocalizedString("Try again later", comment: ""), style: .default))
                            self.present(alertController, animated: true, completion: nil)
                            self.showLogin()
                            self.hideHUD()
                        } else {
                            

                            Auth.auth().signInAnonymously() { (authResult, error) in

                                if (error == nil){
                                    
                                    self.localLogin = self.login
                                    FirebaseManager.sharedInstance.checkIfExist(login: id) { (exist) in
                                        
                                        if (exist) {
                                            
                                            FirebaseManager.sharedInstance.updateLastLogin(login: id)
                                            
                                            FirebaseManager.sharedInstance.getCardNumber(login: id) { (cardNumber) in
                                                
                                                
                                               
                                                let writer = ZXMultiFormatWriter()
                                                
                                                var verifiedCardNumber = ""

                                                if (cardNumber == "-1") {
                                                    verifiedCardNumber = "0000"
                                                    
                                                } else {
                                                    verifiedCardNumber = cardNumber
                                                }
                                                
                                                do {
                                        
                                                    let result = try writer.encode(verifiedCardNumber, format: kBarcodeFormatITF, width: 240, height: 100)
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
                                                self.localCardNumber = verifiedCardNumber
                                                self.cardNumber.text = verifiedCardNumber
                                                self.cardNumber.isHidden = false
                                                UserDefaults.standard.set(true, forKey: "wasLogged")
                                                UserDefaults.standard.set(userName, forKey: "userName")
                                                UserDefaults.standard.set(verifiedCardNumber, forKey: "cardNumber")
                                                UserDefaults.standard.set(self.login, forKey: "login")
                                                UserDefaults.standard.set(self.password, forKey: "password")
                                                
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
                                            UserDefaults.standard.set(self.password, forKey: "password")
                                            
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
            self.tableView.isHidden = true
            self.wasLogged = false
            UserDefaults.standard.set(false, forKey: "wasLogged")
            UserDefaults.standard.set("", forKey: "login")
            UserDefaults.standard.set("", forKey: "password")
            UserDefaults.standard.set("", forKey: "userName")
            UserDefaults.standard.set("", forKey: "cardNumber")
            UserDefaults.standard.set("", forKey: "accessToken")
            UserDefaults.standard.set("", forKey: "refreshToken")
            
            
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
    
    var testSorted: Array<Membership>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PJ VC viewdidload")
        
        AlamofireManager.sharedInstance.fetchAllRooms(){ (list1, list2) in
            //TODO - dorobic konwersje eventlist do json i zapisywania potem w userdefaults.
            eventList1 = list1
            eventList2 = list2
        }

//        recievedMemberships = [Membership(name: "VIP zniżka 100% 1", expirationDate: Date(timeIntervalSince1970: 1432578526), isValid: true),
//        Membership(name: "Open for my Love / umowa na 6 miesięcy (bezpłatna) 2", expirationDate: Date(timeIntervalSince1970: 1590133726), isValid: true),
//        Membership(name: "VIP zniżka 100% 3", expirationDate: Date(timeIntervalSince1970: 1332578526), isValid: false),
//        Membership(name: "Open for my Love / umowa na 6 miesięcy (bezpłatna) 4", expirationDate: Date(timeIntervalSince1970: 1597133726), isValid: false),
//        Membership(name: "VIP zniżka 100% 5", expirationDate: Date(timeIntervalSince1970: 1332278526), isValid: false),
//        Membership(name: "Open for my Love / umowa na 6 miesięcy (bezpłatna) 6", expirationDate: Date(timeIntervalSince1970: 1599133726), isValid: true)]
        
        
        
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
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        
        
        forgetPasswordButton.setTitle(NSLocalizedString("Forgot password?", comment: ""), for: .normal)
        
//        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
//        view.addGestureRecognizer(tap)
        let defaults = UserDefaults.standard
        let checkWasLogged = defaults.bool(forKey: "wasLogged")
        
        print("PJ nigdy nie było checkwaslogged ustawione \(checkWasLogged)")
        
        

        if checkWasLogged {
        
            showHUD()
            
//            let refToken = defaults.string(forKey: "refreshToken") ?? ""
//            let accessToken = defaults.string(forKey: "accessToken") ?? ""
            let password = defaults.string(forKey: "password") ?? ""
            let emailLogin = defaults.string(forKey: "login") ?? ""
            
//            print("PJ !!!! password: \(password), login: \(emailLogin)")
            
            AlamofireManager.sharedInstance.efitnessLogin(email: emailLogin, password: password) { (accToken, userId, refToken) in
                
//                print("PJ accTOken w login: \(accToken)")
                
                if !accToken.hasPrefix("-1"){
            
                    
                    UserDefaults.standard.set(accToken, forKey: "accessToken")
                    UserDefaults.standard.set(refToken, forKey: "refreshToken")
                    AlamofireManager.sharedInstance.getMemberships(token: accToken) { (memberships) in
                        self.hideHUD()
                        if memberships[0].name.hasPrefix("-1") {
                            print("PJ XXX error odczytaywania membership: \(memberships[0].name)")
                        } else {
                            
                            self.recievedMemberships = memberships.sorted(by: {$0.expirationDate > $1.expirationDate})
                            self.tableView.isHidden = false
                            self.tableView.reloadData()
                        }
                    }
                    
                } else {
                    self.hideHUD()
                }
            }
            
            
//            AlamofireManager.sharedInstance.refreshUserToken(accessToken: accessToken, refreshToken: refToken) {
//                (accessToken, id, refreshToken) in
//                self.hideHUD()
//                print("PJ po refreshu: id = \(id) i reftoken = \(refreshToken),  acctoken = \(accessToken)")
//
//                if !accessToken.hasPrefix("-1"){
//                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
//                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
//                    AlamofireManager.sharedInstance.getMemberships(token: accessToken) { (memberships) in
//
//                        if memberships[0].name.hasPrefix("-1") {
//                            print("PJ error odczytaywania membership: \(memberships[0].name)")
//                        } else {
//
//                            self.recievedMemberships = memberships.sorted(by: {$0.expirationDate > $1.expirationDate})
//                            self.tableView.isHidden = false
//                            self.tableView.reloadData()
//
//                        }
//                    }
//
//                }
//
//            }
            
            
            hideLogin()
            localLogin = defaults.string(forKey: "login") ?? ""
            localUserName = defaults.string(forKey: "userName") ?? ""
            
//            print("PJ odczytany username z UD: \(localUserName)")
            localCardNumber = defaults.string(forKey: "cardNumber") ?? ""
            
            userNameField.text = localUserName
           
            logoutButton.isHidden = false
           
            if (localCardNumber == "") {
                cardNumber.isHidden = true
                barcodeImage.isHidden = true
                
                FirebaseManager.sharedInstance.checkIfExist(login: localLogin) { (exist) in
                               
                    if exist {
                        FirebaseManager.sharedInstance.getCardNumber(login: self.localLogin) { (cNumber) in
                         
                            if (cNumber != "-1") {
                                
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (recievedMemberships == nil){
            
            tableView.isHidden = true
            return 0
        } else {
            tableView.isHidden = false
            return recievedMemberships.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MembershipTableViewCell", for: indexPath) as! MembershipTableViewCell
        
        if recievedMemberships.count > 0 {
    
            if (recievedMemberships[indexPath.row].isValid == true) {
                
                cell.statusDot.tintColor = UIColor(displayP3Red: 51.0/255.0, green: 188.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            } else {
                cell.statusDot.tintColor = UIColor(displayP3Red: 255.0/255.0, green: 51.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            }
            cell.membershipLabel.text = recievedMemberships[indexPath.row].name
            cell.expirationDate.text = recievedMemberships[indexPath.row].expirationDate.string(format: "dd-MM-yyyy")

        }

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "asdfghjkl"
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView.init(frame: CGRect.init(x: 8, y: 0, width: tableView.frame.width - 8, height: 30))
       headerView.backgroundColor = UIColor.lightGray //init(hex: "9EA09CFF")

        //Image View
        let imageView = UIImageView()
//        imageView.backgroundColor = UIColor.
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        imageView.anchorToEdge(.right, padding: 0.0, width: 30, height: 30)
        
//        imageView.anchorAndFillEdge(.right, xPad: 0.0, yPad: 0.0, otherSize: 0.0)
//        imageView.image = UIImage(named: "circle.fill")

        //Text Label
        let textLabel = UILabel()
//        textLabel.backgroundColor = UIColor.yellow
        textLabel.textColor = .white
//        textLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        
        textLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        textLabel.text  = NSLocalizedString("Memberships", comment: "")
        textLabel.font = UIFont(name: "Variable-Bold", size: 12)
        textLabel.textAlignment = .left
        
         let dateLabel = UILabel()
        //        textLabel.backgroundColor = UIColor.yellow
        dateLabel.textColor = .white
        dateLabel.widthAnchor.constraint(equalToConstant: 90).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dateLabel.text  = NSLocalizedString("Valid till", comment: "")
        dateLabel.font = UIFont(name: "Variable-Bold", size: 12)
        dateLabel.textAlignment = .left

        //Stack View
       
        
        let stackView   = UIStackView()
       stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fill
//       stackView.alignment = UIStackView.Alignment.center
       stackView.spacing   = 16.0
        
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(dateLabel)
//        stackView.addArrangedSubview(imageView)
//        imageView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0).isActive = true
//        imageView.anchorToEdge(.right, padding: 0, width: 30, height: 30)
        textLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 8).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(stackView)

        //Constraints
//        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
//        stackView.anchorToEdge(.right, padding: 0, width: headerView.width, height: headerView.height)
        stackView.widthAnchor.constraint(equalToConstant: tableView.bounds.size.width).isActive = true
        
        
        
       headerView.addSubview(stackView)// sectionLabel)
        return headerView
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
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
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


