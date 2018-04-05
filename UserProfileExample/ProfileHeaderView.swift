//
//  ProfileHeaderView.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPProfileHeaderView)
class ProfileHeaderView: UIView {
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var praiseLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    let maxHeight: CGFloat = 80
    let minHeight: CGFloat = 50
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconHeightConstraint.constant = maxHeight
        self.praiseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.followingLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.followersLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.praiseLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.followingLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.followersLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func animator(t: CGFloat) {
        //    print(t)
        
        if t < 0 {
            iconHeightConstraint.constant = maxHeight
            return
        }
        
        let height = max(maxHeight - (maxHeight - minHeight) * t, minHeight)
        
        iconHeightConstraint.constant = height
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        praiseLabel.sizeToFit()
        let bottomFrame = praiseLabel.frame
        let iSize = praiseLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let padding : CGFloat = 10.0
        let resultSize = CGSize.init(width: size.width, height: bottomFrame.origin.y + iSize.height + padding)
        return resultSize
    }
    
    override var frame: CGRect {
        didSet {
            print(frame.size.height)
            if frame.size.height > 423 {
                print("")
            }
        }
    }
    
    
}

