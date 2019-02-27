//
//  SearchButton.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 3/1/19.
//  Copyright © 2019 Funnel. All rights reserved.
//

import UIKit

@IBDesignable class SearchButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installButton()
    }
    
    // initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installButton()
    }
    
    override func prepareForInterfaceBuilder() {
        installButton()
    }
    
    func installButton() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
        
    }
    
    func updateButton() {
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: self.bounds.height/2).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButton()
        self.setNeedsDisplay()
    }
}
