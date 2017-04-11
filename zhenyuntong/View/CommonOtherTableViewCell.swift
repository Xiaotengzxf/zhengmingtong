//
//  CommonOtherTableViewCell.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/24.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit

class CommonOtherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageWidthLC: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
