//
//  UIViewExtensions.swift
//  AutolayoutExtensions
//
//  Created by Alex Choi on 3/22/16.
//  Copyright © 2016 CHOI. All rights reserved.
//


public extension UIView {
    
    public func addConstraintsWithVisualFormatStrings(formatStrings: [String], options: NSLayoutFormatOptions = [], metrics: [String: AnyObject] = [:], views: [String: AnyObject]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for formatString in formatStrings {
            constraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(formatString, options: options, metrics: metrics, views: views))
        }
        
        addConstraints(constraints)
        return constraints
    }
    
    public func addSubviewsWithAutoLayout(views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
    
    /** Insets are applied as constants. bottom and trailing constants are applied in negative to produce an inset effect. */
    public func anchorAllEdgesToView(view: UIView, topInset: CGFloat = 0, leadingInset: CGFloat = 0, bottomInset: CGFloat = 0, trailingInset: CGFloat = 0) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        return (top: anchorTopToTopEdgeOfView(view, constant: topInset),
                leading: anchorLeadingToLeadingEdgeOfView(view, constant: leadingInset),
                bottom: anchorBottomToBottomEdgeOfView(view, constant: -bottomInset),
                trailing: anchorTrailingToTrailingEdgeOfView(view, constant: -trailingInset))
    }
    
    /** Insets are applied as constants. trailing is applied in negative to produce an inset effect */
    public func anchorLeadingAndTrailingEdgesToView(view: UIView, leadingInset: CGFloat = 0, trailingInset: CGFloat = 0) -> (leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        return (leading: anchorLeadingToLeadingEdgeOfView(view, constant: leadingInset),
                trailing: anchorTrailingToTrailingEdgeOfView(view, constant: -trailingInset))
    }
    
    /** Left and right insets are ignored. */
    public func anchorTopAndBottomEdgesToView(view: UIView, topInset: CGFloat = 0, bottomInset: CGFloat = 0) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        return (top: anchorTopToTopEdgeOfView(view, constant: topInset),
                bottom: anchorBottomToBottomEdgeOfView(view, constant: -bottomInset))
    }
    
    public func anchorWidthAndHeightToSize(size: CGSize) -> (width: NSLayoutConstraint, height: NSLayoutConstraint) {
        return (width: anchorWidthToConstant(size.width),
                height: anchorHeightToConstant(size.height))
    }
    
    public func anchorHeightToConstant(height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Height,
                                            relatedBy: .Equal,
                                            toItem: nil,
                                            attribute: .NotAnAttribute,
                                            multiplier: 1,
                                            constant: height)
        constraint.active = true
        return constraint
    }
    
    public func anchorWidthToConstant(width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Width,
                                            relatedBy: .Equal,
                                            toItem: nil,
                                            attribute: .NotAnAttribute,
                                            multiplier: 1,
                                            constant: width)
        constraint.active = true
        return constraint
    }
    
    public func anchorWidthToViewWidth(view: UIView, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Width,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Width,
                                            multiplier: multiplier,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorHeightToViewHeight(view: UIView, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Height,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Height,
                                            multiplier: multiplier,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorTopToTopEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Top,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Top,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorBottomToBottomEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Bottom,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Bottom,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorLeftToLeftEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Left,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Left,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorLeadingToLeadingEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Leading,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Leading,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorLeadingToTrailingEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Leading,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Trailing,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorTrailingToLeadingEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Trailing,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Leading,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorRightToRightEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Right,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Right,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorTrailingToTrailingEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Trailing,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Trailing,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorBottomToTopEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Bottom,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Top,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorTopToBottomEdgeOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .Top,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .Bottom,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorCenterToCenterOfView(view: UIView) -> (centerX: NSLayoutConstraint, centerY: NSLayoutConstraint) {
        return (centerX: anchorCenterXToCenterXOfView(view),
                centerY: anchorCenterYToCenterYOfView(view))
    }
    
    public func anchorCenterYToCenterYOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .CenterY,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .CenterY,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
    public func anchorCenterXToCenterXOfView(view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .CenterX,
                                            relatedBy: .Equal,
                                            toItem: view,
                                            attribute: .CenterX,
                                            multiplier: 1,
                                            constant: constant)
        constraint.active = true
        return constraint
    }
    
}

