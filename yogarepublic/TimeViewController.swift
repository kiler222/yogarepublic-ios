//
//  TimeViewController.swift
//  yogarepublic
//
//  Created by kiler on 10/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController {

    @IBAction func room2(_ sender: Any) {
        let vc = TimetableViewController()
        vc.eventList = eventList2
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func room1(_ sender: Any) {
        let vc = TimetableViewController()
        vc.eventList = eventList1
        present(vc, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
