//
//  HitTestScrollViewCell.swift
//  UserProfileExample
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class HitTestScrollViewCell: UITableViewCell {
    
    fileprivate lazy var controller : HitTestContainerViewController = {
        let controller = HitTestContainerViewController()
        return controller
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    fileprivate func setupUI() {
        self.contentView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0)
        controller.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0)
        controller.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0)
        controller.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
