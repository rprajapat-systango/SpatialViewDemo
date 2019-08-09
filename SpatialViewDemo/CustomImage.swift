//
//  CustomImage.swift
//  SpatialViewDemo
//
//  Created by SGVVN on 09/08/19.
//  Copyright © 2019 Systango. All rights reserved.
//

import UIKit
import CoreGraphics

class CustomImage: UIImage {
    override func draw(in rect: CGRect, blendMode: CGBlendMode, alpha: CGFloat) {
        let path = UIBezierPath.init(ovalIn: rect)
        path.lineWidth = 1.0
        path.addClip()
        UIColor.black.setStroke()
        UIColor.white.setFill()
    }

}

extension CustomImage{
    func DrawOnImage(startingImage: UIImage) -> UIImage? {
        
        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext(startingImage.size)
        
        // Draw the starting image in the current context as background
        startingImage.draw(at: CGPoint.zero)
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw a red line
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.move(to: CGPoint(x: 100, y: 100))
        context.addLine(to: CGPoint(x: 200, y: 200))
        context.strokePath()
        
        // Draw a transparent green Circle
        context.setStrokeColor(UIColor.green.cgColor)
        context.setAlpha(0.5)
        context.setLineWidth(10.0)
        context.addEllipse(in: CGRect(x: 100, y: 100, width: 100, height: 100))
        context.drawPath(using: .stroke) // or .fillStroke if need filling
        
        // Save the context as a new UIImage
        let myImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return modified image
        return myImage
    }
}
