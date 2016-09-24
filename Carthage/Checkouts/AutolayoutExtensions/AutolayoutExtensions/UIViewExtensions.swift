//
//  UIViewExtensions.swift
//  AutolayoutExtensions
//
//  Created by Alex Choi on 3/22/16.
//  Copyright © 2016 CHOI. All rights reserved.
//


public extension UIView {
    
    public func addConstraints(withVisualFormats formatStrings: [String], options: NSLayoutFormatOptions = [], metrics: [String: AnyObject] = [:], views: [String: AnyObject]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for formatString in formatStrings {
            constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: formatString, options: options, metrics: metrics, views: views))
        }
        
        addConstraints(constraints)
        return constraints
    }
    
    public func addSubviewsWithAutoLayout(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
    
    /** Insets are applied as constants. bottom and trailing constants are applied in negative to produce an inset effect. */
    public func anchorAllEdgesToView(_ view: UIView, topInset: CGFloat = 0, leadingInset: CGFloat = 0, bottomInset: CGFloat = 0, trailingInset: CGFloat = 0) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        return (top: anchorTopToTopEdgeOfView(view, constant: topInset),
                leading: anchorLeadingToLeadingEdgeOfView(view, constant: leadingInset),
                bottom: anchorBottomToBottomEdgeOfView(view, constant: -bottomInset),
                trailing: anchorTrailingToTrailingEdgeOfView(view, constant: -trailingInset))
    }
    
    /** Insets are applied as constants. trailing is applied in negative to produce an inset effect */
    public func anchorLeadingAndTrailingEdgesToView(_ view: UIView, leadingInset: CGFloat = 0, trailingInset: CGFloat = 0) -> (leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        return (leading: anchorLeadingToLeadingEdgeOfView(view, constant: leadingInset),
                trailing: anchorTrailingToTrailingEdgeOfView(view, constant: -trailingInset))
    }
    
    /** Left and right insets are ignored. */
    public func anchorTopAndBottomEdgesToView(_ view: UIView, topInset: CGFloat = 0, bottomInset: CGFloat = 0) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        return (top: anchorTopToTopEdgeOfView(view, constant: topInset),
                bottom: anchorBottomToBottomEdgeOfView(view, constant: -bottomInset))
    }
    
    public func anchorWidthAndHeightToSize(_ size: CGSize) -> (width: NSLayoutConstraint, height: NSLayoutConstraint) {
        return (width: anchorWidthToConstant(size.width),
                height: anchorHeightToConstant(size.height))
    }
    
    public func anchorHeightToConstant(_ height: CGFloat) -> NSLayoutConstraint {
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
    
    public func anchorWidthToConstant(_ width: CGFloat) -> NSLayoutConstraint {
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
    
    public func anchorWidthToViewWidth(_ view: UIView, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorHeightToViewHeight(_ view: UIView, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorTopToTopEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorBottomToBottomEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorLeftToLeftEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorLeadingToLeadingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorLeadingToTrailingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorTrailingToLeadingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorRightToRightEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorTrailingToTrailingEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorBottomToTopEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorTopToBottomEdgeOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorCenterToCenterOfView(_ view: UIView) -> (centerX: NSLayoutConstraint, centerY: NSLayoutConstraint) {
        return (centerX: anchorCenterXToCenterXOfView(view),
                centerY: anchorCenterYToCenterYOfView(view))
    }
    
    public func anchorCenterYToCenterYOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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
    
    public func anchorCenterXToCenterXOfView(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
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

