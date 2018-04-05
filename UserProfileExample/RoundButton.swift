//
//  RoundButton.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

internal class RoundButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = BaseProfileViewController.globalTint
        self.layer.masksToBounds = true
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height * 0.5
    }
}

internal class ProfileIconView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width * 0.5
    }
}
