//
//  ExitButton.swift
//  ColorCoder
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import UIKit

public class ExitButton: UIButton {

    public var disabled = false {
        didSet {
            if disabled {
                self.alpha = 0.3
                self.isUserInteractionEnabled = false
            } else {
                self.alpha = 1
                self.isUserInteractionEnabled = true
            }
        }
    }
    public var constrictedRange: CGRect?
    public var maskBoolean  = true
    public var borderColor: UIColor? { didSet { self.setNeedsDisplay() } }
    
    //set some x and y coords
    var leftX: CGFloat!
    var middleX: CGFloat!
    var rightX: CGFloat!
    var quarterX: CGFloat!
    var thirdQuarterX: CGFloat!
    var topY: CGFloat!
    var middleY: CGFloat!
    var bottomY: CGFloat!
    var quarterY: CGFloat!
    var thirdQuarterY: CGFloat!

    public var borderPresent    = true { didSet { self.setNeedsDisplay() } }
    public var transparency: CGFloat    = 1
    public var borderButtonFraction: CGFloat   = 0.03
    public var lineWidth: CGFloat       = 4
    var offsetFrac: CGFloat             = 0.25

    override public func tintColorDidChange() {
        self.setNeedsDisplay()
    }

    override public func draw(_ rect: CGRect) {

        self.layer.cornerRadius = min(self.bounds.width, self.bounds.height)/2

        //setup graphics context with props
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(.round)
            context.setLineWidth(lineWidth)

            if let color = borderColor {
                context.setStrokeColor(color.withAlphaComponent(transparency).cgColor)
                context.setFillColor(color.withAlphaComponent(transparency).cgColor)
            } else {
                context.setStrokeColor(UIColor.black.cgColor)
                context.setFillColor(UIColor.black.cgColor)
            }

            self.resetSizeParameters()

            self.drawCrossSymbol(in: context)

            self.setBorder(borderPresent)

            context.strokePath()
        }
    }

    func setBorder(_ borderPresent: Bool) {
        if borderPresent {
            if let color = self.borderColor {
                self.layer.borderColor  = color.withAlphaComponent(transparency).cgColor
            } else {
                self.layer.borderColor  =  UIColor.darkGray.cgColor
            }

            self.layer.borderWidth      = min(self.bounds.width, self.bounds.height)*borderButtonFraction
        } else {
            self.layer.borderWidth      = 0
            self.layer.borderColor      = nil
        }
        self.layer.masksToBounds    = maskBoolean

    }

    func drawCrossSymbol(in context: CGContext) {
        context.saveGState()
        context.translateBy(x: middleX, y: middleY)
        context.rotate(by: CGFloat.pi/4)
        context.translateBy(x: -middleX, y: -middleY)
        //vertical line
        context.move(to: CGPoint(x: middleX, y: topY))
        context.addLine(to: CGPoint(x: middleX, y: bottomY))
        //horizontal line
        context.move(to: CGPoint(x: leftX, y: middleY))
        context.addLine(to: CGPoint(x: rightX, y: middleY))
        context.restoreGState()
    }

    func resetSizeParameters() {

        var drawingBounds: CGRect
        if let ranges = self.constrictedRange {
            drawingBounds           = .zero
            drawingBounds.origin    = ranges.origin * self.bounds.size
            drawingBounds.size      = self.bounds.size * ranges.size
        } else {
            drawingBounds  = self.bounds
        }
        leftX           = drawingBounds.origin.x + drawingBounds.size.width * offsetFrac
        middleX         = drawingBounds.midX
        rightX          = drawingBounds.origin.x + drawingBounds.size.width * (1-offsetFrac)
        quarterX        = drawingBounds.origin.x + drawingBounds.size.width * ((0.5-offsetFrac)/2 + offsetFrac)
        thirdQuarterX   = drawingBounds.origin.x + drawingBounds.size.width * (1.0-offsetFrac-(0.5-offsetFrac)/2)
        topY            = drawingBounds.origin.y + drawingBounds.size.height * offsetFrac
        middleY         = drawingBounds.midY
        bottomY         = drawingBounds.origin.y + drawingBounds.size.height * (1-offsetFrac)
        quarterY        = drawingBounds.origin.y + drawingBounds.size.height * ((0.5-offsetFrac)/2 + offsetFrac)
        thirdQuarterY   = drawingBounds.origin.y + drawingBounds.size.height * (1.0-offsetFrac-(0.5-offsetFrac)/2)

    }

}

public func * (size1: CGSize, size2: CGSize) -> CGSize {
    return CGSize(width: size1.width*size2.width, height: size1.height*size2.height)
}

public func * (point: CGPoint, size: CGSize) -> CGPoint {
    return CGPoint(x: point.x*size.width, y: point.y*size.height)
}
