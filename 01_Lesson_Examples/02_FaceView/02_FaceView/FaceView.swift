//
//  FaceView.swift
//  02_FaceView
//
//  Created by Wes Auyueng on 3/31/17.
//  Copyright © 2017 Wes AuYeung. All rights reserved.
//

import UIKit

/*
 @IBDesignable makes it possible to see "FaceView" in our storyboard, allowing
 us to inspect and manipulate the component as we see fit.
 */
@IBDesignable
class FaceView: UIView {
    /*
     By default, iOS avoids draw; very expensive
     
     Display: In the interface, we can tie the edges of our custom
     
     UIView class by using the |-∆-| symbol in the lower right and selecting
     "Reset to Suggested Constraints"
    
     Note that when we draw something, we have to manually tell Swift to re-draw
     if we rotate the view (or if it changes for other reasons)
     
     We can fix this in Content-Mode in the Interface Builder (right) panel

     We don't necessarily want our face to touch the edges of our screen, so
     we can use a scale varaible (0-1) that scales down our drawing
    
     We can leave this variable public, so that others can manipulate the size
     of the face
     
     @IBInspectable allows us to inspect a variable in Interface Builder
     
     However, @IBInspectable *requires* explicit typing!
     */
    @IBInspectable
    var scale: CGFloat = 0.9 // 90% of whatever we multiply by
    
    /*
     @IBInspectable allows us to inspect a variable in Interface Builder
     
     However, @IBInspectable *requires* explicit typing!
     */
    @IBInspectable
    var eyesOpen: Bool = true
    
    /*
     This will need to be converted to a CGFloat
     
     @IBInspectable allows us to inspect a variable in Interface Builder
     
     However, @IBInspectable *requires* explicit typing!
     */
    @IBInspectable
    var mouthCurvature: Double = 0.5 // 1.0 = full smile | -1.0 = full frown

    /*
     @IBInspectable allows us to inspect a variable in Interface Builder
     
     However, @IBInspectable *requires* explicit typing!
     */
    @IBInspectable
    var lineWidth: CGFloat = 5.0
    
    /*
     @IBInspectable allows us to inspect a variable in Interface Builder
     
     However, @IBInspectable *requires* explicit typing!
     */
    @IBInspectable
    var color: UIColor = .blue
    
    /*
     bounds is a CGRect, with size property; size is a CGSize with a height and
     width property; height & width are CGFloats
     
     Divide by 2 for radius; not diameter
     
     We moved this from inside the draw function because we expect to reuse it
     
     This must be set as a computed property because we can't access bounds before
     the instance is initialized
     */
    private var skullRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    /*
     We can't use center here as is; it is in the *superview's* coordinate system
     
     We could convert the center point to our view
    
     >> What does this mean exactly? How does the superview's coordinate system
     differ from ours? <<
    
     Instead, we can create a new CGPoint with the midX and midY from our bounds
     variable -> is this the bounds variable in our FaceView or view?
    
     We moved this from inside the draw function because we expect to reuse it
     
     This must be set as a computed property because we can't access bounds before
     the instance is initialized
    
     Note that the center is *not* the origin, (top left corner)
     */
    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // Used to distinguish which eye we are drawing
    private enum Eye {
        case left
        case right
    }
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        /* We keep this function inside pathForEye to let readers know it will
        only be used by this function */
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            // Remember, +∆ is down and -∆ is up on the y-axis
            eyeCenter.y -= eyeOffset
            eyeCenter.x += (eye == .left ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        let eyeCenter = centerOfEye(eye)
        // Remember, angles are expressed in radians
        
        /*
         Even though we set path as a constant, it's undefined, so Swift knows
         to expect a value whenever it has to draw a path for the eye; this just
         can't change within a single call of the pathForEye function
         
         Swift knows that we will be conditionally assigning the variable later on
         */
        let path: UIBezierPath
        
        if eyesOpen {
            path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        } else {
            path = UIBezierPath()
            // Move to the left edge of the eye circle
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            // Add line from left edge to right edge of eye circle
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        path.lineWidth = lineWidth
        return path
    }
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset
        
        let mouthRect = CGRect(
            x: skullCenter.x - mouthWidth / 2,
            y: skullCenter.y + mouthOffset,
            width: mouthWidth,
            height: mouthHeight
        )
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y: start.y + smileOffset)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        
        return path
    }
    
    private func pathForSkull() -> UIBezierPath {
        /*
         startAngle 0 = straight to the right -> in radians (2π maximum) i.e.
         π = 180º | 2π = 360º
         
         Note that we cannot use Double.pi since endAngle expects a CGFloat;
         luckily, CGFloat has a pi as well
         */
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        
        // Here we have to set the linewidth on the path
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {
        /*
         Colors are set "globally", so a color is set for all subsequent commands
         until the next time we unset / re-assign the color
         */
        color.set()
        pathForSkull().stroke()
        // We don't need to type out the enum type; only its case
        pathForEye(.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
    
    /*
     While not absolutely necessary, having a structure allows us to group
     together constants that we expect to use. Remember, assigning the "static"
     keyword allows us to use it as a Type variable (vs instance variable)
     */
    private struct Ratios {
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }

}
