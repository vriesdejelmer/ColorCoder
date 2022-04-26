//
//  ConstraintFunctions.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 28/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

///Add a subview to fit exactly the size and position of the superview using autolayout
@discardableResult public func addViewToFit(_ subView: UIView, superView: UIView) -> [NSLayoutConstraint] {
    return addViewToFit(subView, superView: superView, for: [.top, .bottom, .leading, .trailing])
}

@discardableResult public func addViewToFit(_ subView: UIView, superView: UIView, for edges: [NSLayoutConstraint.Attribute]) -> [NSLayoutConstraint] {
    superView.addSubview(subView)
    return addEqualityConstraints(subView, superView: superView, for: edges, offsets: [CGFloat](repeating: 0, count: edges.count))
}

//Add a subview to fit exactly the size and position of the superview using autolayout
public func addViewWithInsets(_ subView: UIView, superView: UIView, insets: UIEdgeInsets) {
    superView.addSubview(subView)
    var viewConstraints = [NSLayoutConstraint]()
    viewConstraints.append(NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: insets.top))
    viewConstraints.append(NSLayoutConstraint(item: subView, attribute: .bottom, relatedBy: .equal, toItem: superView, attribute: .bottom, multiplier: 1, constant: -insets.bottom))
    viewConstraints.append(NSLayoutConstraint(item: subView, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: insets.left))
    viewConstraints.append(NSLayoutConstraint(item: subView, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1, constant: -insets.right))
    superView.addConstraints(viewConstraints)
}

@discardableResult public func addEqualityConstraints(_ subView: UIView, superView: UIView, for edges: [NSLayoutConstraint.Attribute], offsets: [CGFloat]) -> [NSLayoutConstraint] {
    var viewConstraints = [NSLayoutConstraint]()
    for (edge, constant) in zip(edges, offsets) {
        viewConstraints.append(NSLayoutConstraint(item: subView, attribute: edge, relatedBy: .equal, toItem: superView, attribute: edge, multiplier: 1, constant: constant))
    }
    superView.addConstraints(viewConstraints)
    return viewConstraints
}

public func addConstraint(type: NSLayoutConstraint.Attribute, to view: UIView, with value: CGFloat) {
    for constraint in view.constraints where constraint.firstAttribute == type {
        constraint.constant = value
    }
}

public func addSizeConstraint(_ size: CGSize, to subView: UIView) {
    addWidthConstraint(size.width, to: subView)
    addHeightConstraint(size.height, to: subView)
}

public func addWidthConstraint(_ width: CGFloat, to subView: UIView) {
    subView.addConstraint(NSLayoutConstraint(item: subView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
}

public func addHeightConstraint(_ height: CGFloat, to subView: UIView) {
    subView.addConstraint(NSLayoutConstraint(item: subView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
}
