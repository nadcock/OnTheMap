//
//  LoginTextField.swift
//  OnTheMap
//
//  Created by Nick Adcock on 3/23/16.
//  Copyright © 2016 NEA. All rights reserved.
//

import Foundation
import UIKit

class LoginTextField: UITextField  {
    
    let udacityBlue: UIColor = UIColor(red: 22/255, green: 164/255, blue: 220/255, alpha: 1.0)
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    init(frame: CGRect, arg1: CGFloat, arg2: String) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = arg1
        print(arg2)
        print("Instantiated")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.5
        self.layer.borderColor = udacityBlue.CGColor
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    private func newBounds(bounds: CGRect) -> CGRect {
        
        var newBounds = bounds
        newBounds.origin.x += padding.left
        newBounds.origin.y += padding.top
        newBounds.size.height -= padding.top + padding.bottom
        newBounds.size.width -= padding.left + padding.right
        return newBounds
    }
}