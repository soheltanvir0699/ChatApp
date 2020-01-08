//
//  ChatCellOne.swift
//  ChatAppRealtime
//
//  Created by Apple Guru on 30/11/19.
//  Copyright © 2019 Apple Guru. All rights reserved.
//

import UIKit

class ChatCellOne: UITableViewCell {

    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
