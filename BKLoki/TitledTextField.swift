//
//  TitledTextField.swift
//  BKLoki
//
//  Created by Sara Du on 4/30/16.
//  Copyright © 2016 Masanori Uehara. All rights reserved.
//

import UIKit
class TitledTextField: UITextField {
    
    var title: String = "" {
        didSet{
            titleLabel.text = title
        }
    }
    
    private var titleLabel: UILabel!
    private var yPosition: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel = UILabel(frame: placeholderRectForBounds(bounds))
        titleLabel.font = font
        titleLabel.textColor = UIColor.lightGrayColor()
        titleLabel.text = placeholder
        addSubview(titleLabel)
        placeholder = nil
        clipsToBounds = false
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        let center = NSNotificationCenter.defaultCenter()
        
        if(newSuperview != nil){ //we're going into view hierarchy
            center.addObserver(self, selector: "didBeginEditing:", name: UITextFieldTextDidBeginEditingNotification, object: self)
            center.addObserver(self, selector: "didEndEditing:", name: UITextFieldTextDidEndEditingNotification, object: self)
        }
        else{ //coming out of view hierarchy
            center.removeObserver(self)
        }
    }
    
    func didBeginEditing(notification: NSNotification){
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .CurveEaseIn, animations: { () -> Void in
            
            self.yPosition = self.titleLabel.frame.origin.y
            self.titleLabel.frame.origin.y = self.bounds.origin.y - self.bounds.size.height
            self.titleLabel.textColor = UIColor.blueColor()
            self.titleLabel.alpha = 1
            
            
            }, completion: nil)
    }
    func didEndEditing(notification: NSNotification){
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .CurveEaseOut, animations: { () -> Void in
            
            self.titleLabel.frame.origin.y = self.yPosition
            self.titleLabel.textColor = UIColor.grayColor()
            
            if !self.text!.isEmpty {
                self.titleLabel.alpha = 0
                
            }
            
            }, completion: nil)
        
    }
    
}
