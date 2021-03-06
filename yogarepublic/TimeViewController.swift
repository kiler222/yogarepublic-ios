//
//  TimeViewController.swift
//  yogarepublic
//
//  Created by kiler on 10/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import UIKit
import CalendarKit

class TimeViewController: UIViewController {

    @IBAction func room2(_ sender: Any) {
       
        
        if (eventList2.isEmpty) {
            let alertController = UIAlertController(title: NSLocalizedString("Updating data", comment: ""), message:
                             NSLocalizedString("Please try later...", comment: ""), preferredStyle: .alert)
                         alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))

               self.present(alertController, animated: true, completion: nil)
        } else {
            let vc = TimetableViewController()
            vc.eventList = eventList2
            present(vc, animated: true, completion: nil)
        }
        
    
    }
    
    
    @IBAction func room1(_ sender: Any) {
        
        if (eventList1.isEmpty) {
           let alertController = UIAlertController(title: NSLocalizedString("Updating data", comment: ""), message:
                  NSLocalizedString("Please try later...", comment: ""), preferredStyle: .alert)
              alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))

              self.present(alertController, animated: true, completion: nil)
        } else {
            let vc = TimetableViewController()
            vc.eventList = eventList1
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var room1: UIButton!
    @IBOutlet weak var room2: UIButton!
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
//        room1.layer.cornerRadius  = 25
//         room1.layer.borderWidth   = 3.0
//         room1.layer.borderColor   = UIColor.darkGray.cgColor

        if (eventList1.isEmpty || eventList2.isEmpty) {
            showHUD()
            AlamofireManager.sharedInstance.fetchAllRooms(){ (list1, list2) in
                       //TODO - dorobic konwersje eventlist do json i zapisywania potem w userdefaults.
                       eventList1 = list1
                       eventList2 = list2
                self.hideHUD()
                   }
        } else {
            hideHUD()
        }
        
         
        room1.alignTextBelow(spacing: 10.0)
        room1.layer.shadowColor = UIColor.black.cgColor
        room1.layer.shadowOffset = CGSize(width: 2.0, height: 6.0)
        room1.layer.shadowRadius = 8
        room1.layer.shadowOpacity = 0.7
        room1.layer.masksToBounds = false
        
        room2.alignTextBelow(spacing: 10.0)
        room2.layer.shadowColor = UIColor.black.cgColor
        room2.layer.shadowOffset = CGSize(width: 2.0, height: 6.0)
        room2.layer.shadowRadius = 8
        room2.layer.shadowOpacity = 0.7
        room2.layer.masksToBounds = false
        
        room1.isHidden = false
        room2.isHidden = false
        
    }
    
    
    
    
    func showHUD(){
        progressIndicator.startAnimating()
        progressIndicator.isHidden = false
    }
    
    func hideHUD(){
        progressIndicator.stopAnimating()
        progressIndicator.isHidden = true
    }


}


public extension UIButton {

    func alignTextBelow(spacing: CGFloat = 6.0) {
        if let image = self.imageView?.image {
            let imageSize: CGSize = image.size
            self.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -imageSize.width, bottom: -(imageSize.height), right: 0.0)
            let labelString = NSString(string: self.titleLabel!.text!)
            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: self.titleLabel!.font])
            self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        }
    }

}
