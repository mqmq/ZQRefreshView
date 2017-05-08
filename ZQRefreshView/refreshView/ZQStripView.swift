//
//  ZQStripView.swift
//  ZQRefreshView
//
//  Created by zhang on 2017/5/4.
//  Copyright © 2017年 zhangqq.com. All rights reserved.
//

import UIKit
import QuartzCore
enum ZQStripState {
    case Normal
    case Shortening
    case Dismiss
}

class ZQStripView: UIView {
    
//    var startPoint = CGPoint.zero
//    var toPoint = CGPoint.zero
    var viscous = 0.0
    var radius = 0.0
    var bodyColor:UIColor? = nil
    var skinColor:UIColor? = nil
    var shadowColor:UIColor? = nil
    var missWhenApart:Bool = false
    var state:ZQStripState?
    var target:AnyObject? = nil
    var action:Selector? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startPoint = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        toPoint = startPoint
        
        viscous = 55.0
        radius = 13.0
        bodyColor = UIColor.black
        missWhenApart = true
        lineWidth = 2
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var lineWidth:Double? {
        
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    var startPoint:CGPoint? {
        willSet{
            if __CGPointEqualToPoint(self.startPoint!, newValue!) {
                return
            }
            
            if state == ZQStripState.Normal {
                self.setNeedsDisplay()
            }
        }
    }
    
    var toPoint :CGPoint?{
        willSet{
            if __CGPointEqualToPoint(self.toPoint!, newValue!) {
                return
            }
            if state == ZQStripState.Normal {
                self.setNeedsDisplay()
            }
        }
    }
    
    
    func setPullApartTarget(target:AnyObject,action:Selector) -> Void {
        self.target = target
        self.action = action
    }
    
    //绘制贝赛尔曲线
    func bodyPath(startRadius:CGFloat,endRadius:CGFloat,percent:CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        let angle1 = CGFloat(M_PI/3) + CGFloat(M_PI/6)*percent
        let sp1 = pointLineToArc(center: startPoint!, p: toPoint!, angle: Float(angle1), radius: Float(radius))
        let sp2 = pointLineToArc(center: startPoint!, p: toPoint!, angle: Float(-angle1), radius: Float(radius))
        let ep1 = pointLineToArc(center: startPoint!, p: toPoint!, angle: Float(M_PI/2), radius: Float(radius))
        let ep2 = pointLineToArc(center: startPoint!, p: toPoint!, angle: Float(-M_PI/2), radius: Float(radius))

        let middle:CGFloat = 0.6
        
        var mp1 = CGPoint(x: sp2.x*middle + ep1.x*(1 - middle), y: sp2.y*middle + ep1.y*(1-middle))
        var mp2 = CGPoint (x: sp1.x*middle + ep2.x*(1-middle), y: sp1.y*middle + ep2.y*(1-middle))
        let mm  = CGPoint(x: (mp1.x - mp2.x)/2, y: (mp1.y-mp2.y)/2)
        let p = distansBetween(p1: mp1, p2: mp2)/2/endRadius*(0.9+percent/10)
        
        mp1 = CGPoint(x:(mp1.x - mm.x)/p, y: (mp1.y - mm.y)/p)
        mp2 = CGPoint(x:(mp2.x - mm.x)/p, y: (mp2.y - mm.y)/p)
        
        path.move(to: sp1)
        var angles = atan2f(float_t((toPoint?.x)! - (startPoint?.x)!), float_t((toPoint?.x)! - (startPoint?.x)!))
        
        path.addArc(withCenter: startPoint!, radius: startRadius, startAngle: CGFloat(angles) + angle1, endAngle: CGFloat(angles) + CGFloat(M_PI*2) - angle1, clockwise: true)
        path.addQuadCurve(to: ep1, controlPoint: mp1)
        angles = atan2f(float_t((startPoint?.y)! - (toPoint?.y)!), float_t((startPoint?.x)! - (toPoint?.x)!))
        
        path.addArc(withCenter: toPoint!, radius: endRadius, startAngle: CGFloat(angles) + CGFloat(M_PI/2), endAngle: CGFloat(angles) + CGFloat(M_PI*3/2), clockwise: true)
        
        path.addQuadCurve(to: sp1, controlPoint: mp2)
        
        return path
        
    }
    
    override func draw(_ rect: CGRect) {
        
        
    }
    
    
    func scaling() -> Void {
        if state == ZQStripState.Shortening {
            self.setNeedsDisplay()
            self.perform(#selector(ZQStripView.scaling), with: nil, afterDelay: 0.7, inModes:[RunLoopMode.commonModes])
        }
    }
    
    override var isHidden: Bool
    
    
    func pointLineToArc(center:CGPoint,p:CGPoint,angle:Float,radius:Float) -> CGPoint {
        
        let angles = atan2f(float_t(p.y - center.y), float_t(p.x - center.x))
        let anglet = angles + angle
        let x = radius*cosf(anglet)
        let y = radius*sinf(anglet)
        return CGPoint(x:CGFloat(x), y: CGFloat(y))
    }
    
    func distansBetween(p1:CGPoint,p2:CGPoint) -> CGFloat {
        
        let psx = p1.x - p2.x
        let psy = p1.y - p2.y
        return CGFloat(sqrtf(float_t(psx*psx + psy*psy)))
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
}
