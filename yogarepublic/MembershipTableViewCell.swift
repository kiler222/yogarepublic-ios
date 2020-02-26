//
//  MembershipTableViewCell.swift
//  yogarepublic
//
//  Created by kiler on 25/02/2020.
//  Copyright © 2020 kiler. All rights reserved.
//

import UIKit

class MembershipTableViewCell: UITableViewCell {

    @IBOutlet weak var statusDot: UIImageView!
    
    @IBOutlet weak var expirationDate: UILabel!
    @IBOutlet weak var membershipLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
