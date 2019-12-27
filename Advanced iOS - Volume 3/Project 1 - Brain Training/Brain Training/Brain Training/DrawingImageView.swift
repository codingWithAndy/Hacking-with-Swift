//
//  DrawingImageView.swift
//  Brain Training
//
//  Created by Andy Gray on 24/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import UIKit

class DrawingImageView: UIImageView {
    
    weak var delegate: ViewController?
    var currentTouchPosition: CGPoint?

    
    func draw(from start: CGPoint, to end: CGPoint) {
        
        let renderer = UIGraphicsImageRenderer(size: bounds.size)

            image = renderer.image { ctx in
                image?.draw(in: bounds)

                UIColor.black.setStroke()
                ctx.cgContext.setLineCap(.round)
                ctx.cgContext.setLineWidth(15)

                ctx.cgContext.move(to: start)
                ctx.cgContext.addLine(to: end)
                ctx.cgContext.strokePath()
            }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        currentTouchPosition = touches.first?.location(in: self)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesMoved(touches, with: event)

        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        guard let previousTouchPoint = currentTouchPosition else { return }

        draw(from: previousTouchPoint, to: newTouchPoint)
        currentTouchPosition = newTouchPoint
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        currentTouchPosition = nil

        perform(#selector(numberDrawn), with: nil, afterDelay: 0.3)
    }

    @objc func numberDrawn() {
        
        guard let image = image else { return }
        
        let drawRect = CGRect(x: 0, y: 0, width: 28, height: 28)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(bounds: drawRect, format: format)
        
        let imageWithBackground = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(bounds)
            image.draw(in: drawRect)
        }
        
        // convert our UIImage into a CIImage; the force unwrap is safe here because the CGImage is only nil if the UIImage was created from a CIImage
        let ciImage = CIImage(cgImage: imageWithBackground.cgImage!)

        // attempt to create a color inversion filter
        if let filter = CIFilter(name: "CIColorInvert") {
            // give it our input CIImage
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            // create a context so we can perform conversion
                let context = CIContext(options: nil)

                // attempt to read the output CIImage
                if let outputImage = filter.outputImage {
                    // attempt to convert that to a CGImage
                    if let imageRef = context.createCGImage(outputImage, from: ciImage.extent) {
                        // attempt to convert *that* to a UIImage
                        let finalImage = UIImage(cgImage: imageRef)

                        // and finally pass the finished image to our delegate
                        delegate?.numberDrawn(finalImage)
                    }
                }
            }
    }
}
