//
//  Assets.swift
//  TextYourMom
//
//  Created by Antonin Hildebrand on 08/11/14.
//  Copyright (c) 2014 -. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

public class Assets : NSObject {

    //// Cache

    private struct Cache {
        static var normalButton: UIColor = UIColor(red: 0.008, green: 0.765, blue: 0.008, alpha: 1.000)
    }

    //// Colors

    public class var normalButton: UIColor { return Cache.normalButton }

    //// Drawing Methods

    public class func drawButton(#frame: CGRect, label: String) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let buttonText = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRectMake(frame.minX + floor(frame.width * 0.00000 + 0.5), frame.minY + floor(frame.height * 0.00000 + 0.5), floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5)), cornerRadius: 50)
        Assets.normalButton.setFill()
        rectanglePath.fill()


        //// Text Drawing
        let textRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center

        let textFontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 20)!, NSForegroundColorAttributeName: buttonText, NSParagraphStyleAttributeName: textStyle]

        let textTextHeight: CGFloat = NSString(string: label).boundingRectWithSize(CGSizeMake(textRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, textRect);
        NSString(string: label).drawInRect(CGRectMake(textRect.minX, textRect.minY + (textRect.height - textTextHeight) / 2, textRect.width, textTextHeight), withAttributes: textFontAttributes)
        CGContextRestoreGState(context)
    }

}

@objc protocol StyleKitSettableImage {
    func setImage(image: UIImage!)
}

@objc protocol StyleKitSettableSelectedImage {
    func setSelectedImage(image: UIImage!)
}
