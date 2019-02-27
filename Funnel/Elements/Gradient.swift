//
//  Gradient.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 27/12/18.
//  Copyright © 2018 Funnel. All rights reserved.
//

import UIKit

@IBDesignable class Gradient: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    var colors: [Any]?
    // An array of CGColorRef objects defining the color of each gradient stop. Animatable.
    
    // initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installGradient()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        installGradient()
    }
    
    // the gradient layer
    private var gradient: CAGradientLayer?
    
    // create gradient layer
    private func createGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.zPosition = -1
        return gradient
    }
    
    // Create a gradient and install it on the layer
    private func installGradient() {
        // if there's already a gradient installed on the layer, remove it
        if let gradient = self.gradient {
            gradient.removeFromSuperlayer()
        }
        let gradient = createGradient()
        self.layer.addSublayer(gradient)
        self.gradient = gradient
    }
    
    override var frame: CGRect {
        didSet {
            updateGradient()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // this is crucial when constraints are used in superviews
        updateGradient()
    }
    
    // Update an existing gradient
    private func updateGradient() {
        if let gradient = self.gradient {
            let startColor = self.startColor
            let endColor = self.endColor
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.frame = self.bounds
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        installGradient()
        updateGradient()
    }
}
