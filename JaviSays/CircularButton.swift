//
//  CircularButton.swift
//  JaviSays
//
//  Created by Javier Giner Alvarez on 16/10/2019.
//  Copyright © 2019 Javier Giner Alvarez. All rights reserved.
//

import UIKit

class CircularButton: UIButton {
    
    @IBInspectable var hasAlpha: Bool = true

    override func awakeFromNib() {
        
        layer.cornerRadius = frame.size.height / 2
        layer.masksToBounds = true
    }

    override var isHighlighted: Bool {
        didSet {
            if hasAlpha {
                alpha = isHighlighted ? 1.0 : 0.4
            } else {
                alpha = 1.0
            }
        }
    }
}
