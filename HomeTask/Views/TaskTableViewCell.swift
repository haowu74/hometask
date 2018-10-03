//
//  TaskTableViewCell.swift
//  HomeTask
//
//  Created by Hao Wu on 3/10/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskDue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
