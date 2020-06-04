//
//  UIViewExtensions.swift
//  AutolayoutExtensions
//
//  Created by Alex Choi on 3/22/16.
//  Copyright © 2016 CHOI. All rights reserved.
//

import UIKit

public extension UIView {
    
    func addConstraints(withVisualFormats formatStrings: [String], options: NSLayoutConstraint.FormatOptions = [], metrics: [String: AnyObject] = [:], views: [String: AnyObject]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for formatString in formatStrings {
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: formatString, options: options, metrics: metrics, views: views))
        }
        
        addConstraints(constraints)
        return constraints
    }
    
    func addSubviewsWithAutoLayout(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
    
    /** Insets are applied as constants. bottom and trailing constants are applied in negative to produce an inset effect. */
    func anchorAllEdgesToView(_ view: UIView, topInset: CGFloat = 0, leadingInset: CGFloat = 0, bottomInset: CGFloat = 0, trailingInset: CGFloat = 0) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        return (top: anchorTopToTopEdgeOfView(view, constant: topInset),
                leading: anchorLeadingToLeadingEdgeOfView(view, constant: leadingInset),
                bottom: anchorBottomToBottomEdgeOfView(view, constant: -bottomInset),
                trailing: anchorTrailingToTrailingEdgeOfView(view, constant: -trailingInset))
    }
    
    /** Insets are applied as constants. trailing is applied in negative to produce an inset effect */
    func anchorLeadingAndTrailingEdgesToView(_ view: UIView, leadingInset: CGFloat = 0, trailingInset: CGFloat = 0) -> (leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        return (leading: anchorLeadingToLeadingEdgeOfView(view, constant: leadingInset),
                trailing: anchorTrailingToTrailingEdgeOfView(view, constant: -trailingInset))
    }
    
    /** Left and right insets are ignored. */
    func anchorTopAndBottomEdgesToView(_ view: UIView, topInset: CGFloat = 0, bottomInset: CGFloat = 0) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        return (top: anchorTopToTopEdgeOfView(view, constant: topInset),
                bottom: anchorBottomToBottomEdgeOfView(view, constant: -bottomInset))
    }
    
    func anchorWidthAndHeightToSize(_ size: CGSize) -> (width: NSLayoutConstraint, height: NSLayoutConstraint) {
        return (width: anchorWidthToConstant(size.width),
                height: anchorHeightToConstant(size.height))
    }
    
    func anchorHeightToConstant(_ height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1,
                                            constant: height)
        constraint.isActive = true
        return constraint
    }
    
    func anchorWidthToConstant(_ width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1,
                                            constant: width)
        constraint.isActive = true
        return constraint
    }
    
    func anchorWidthToViewWidth(_ view: UIView, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorHeightToViewHeight(_ view: UIView, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .height,
                                            multiplier: multiplier,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorTopToTopEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .top,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorBottomToBottomEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorLeftToLeftEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .left,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorLeadingToLeadingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorLeadingToTrailingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .trailing,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorTrailingToLeadingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorRightToRightEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .right,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorTrailingToTrailingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .trailing,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorBottomToTopEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .top,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorTopToBottomEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .bottom,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorCenterToCenterOfView(_ view: UIView) -> (centerX: NSLayoutConstraint, centerY: NSLayoutConstraint) {
        return (centerX: anchorCenterXToCenterXOfView(view),
                centerY: anchorCenterYToCenterYOfView(view))
    }
    
    func anchorCenterYToCenterYOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .centerY,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func anchorCenterXToCenterXOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .centerX,
                                            multiplier: 1,
                                            constant: constant)
        constraint.isActive = true
        return constraint
    }
    
}

