//
//  ViewController.swift
//  AEWD
//
//  Created by Candour Pc on 5/2/19.
//  Copyright © 2019 pebble. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    public var colorCodes: String = "929918,C8CC86,66581A,3A4A73,185D99"
    public var areas: String = "20,20,20,20,20"
    @IBOutlet var MainViewMy: UIView!
    
    
    
    public var arcAngle: CGFloat = 2.4
    public var needleColor: UIColor = UIColor(red: 18/255.0, green: 112/255.0, blue: 178/255.0, alpha: 1.0)
    public var needleValue: CGFloat = 0
    
    public var applyShadow: Bool = true {
        didSet {
            shadowColor = applyShadow ? shadowColor : UIColor.clear
        }
    }
    public var isRoundCap: Bool = true {
        didSet {
            capStyle = isRoundCap ? .round : .butt
        }
    }
    public var blinkAnimate: Bool = true
    public var circleColor: UIColor = UIColor.black
    public var shadowColor: UIColor = UIColor.lightGray.withAlphaComponent(0.3)
    var firstAngle = CGFloat()
    var capStyle = CGLineCap.round
    
    // MARK:- UIView Draw method
    func drawGauge() {
        MainViewMy.layer.sublayers = []
        drawSmartArc()
        drawNeedle()
        drawNeedleCircle()
    }
    
    func drawSmartArc() {
        var angles = getAllAngles()
        let arcColors = colorCodes.components(separatedBy: ",")
        let center = CGPoint(x: MainViewMy.bounds.width / 2, y: MainViewMy.bounds.height / 2)
        
        var arcs = [ArcModel(startAngle: angles[0],
                             endAngle: angles.last!,
                             strokeColor: shadowColor,
                             arcCap: CGLineCap.round,
                             center:CGPoint(x: MainViewMy.bounds.width / 2, y: (MainViewMy.bounds.height / 2)+5))]
        
        for index in 0..<arcColors.count {
            let arc = ArcModel(startAngle: angles[index], endAngle: angles[index+1],
                               strokeColor: UIColor(hex: arcColors[index]),
                               arcCap: CGLineCap.butt,
                               center: center)
            arcs.append(arc)
        }
        arcs.rearrange(from: arcs.count-1, to: 2)
        arcs[1].arcCap = self.capStyle
        arcs[2].arcCap = self.capStyle
        for i in 0..<arcs.count {
            createArcWith(startAngle: arcs[i].startAngle, endAngle: arcs[i].endAngle, arcCap: arcs[i].arcCap, strokeColor: arcs[i].strokeColor, center: arcs[i].center)
        }
        
        if blinkAnimate {
            blink()
        }
    }
    public func blink() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0.2
        animation.duration = 0.1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        animation.autoreverses = true
        animation.repeatCount = 3
        MainViewMy.layer.add(animation, forKey: "opacity")
    }
    
    func radian(for area: CGFloat) -> CGFloat {
        let degrees = arcAngle * area
        let radians = degrees * .pi/180
        return radians
    }
    
    func getAllAngles() -> [CGFloat] {
        var angles = [CGFloat]()
        firstAngle = radian(for: 0) + .pi/2
        var lastAngle = radian(for: 100) + .pi/2
        
        let degrees:CGFloat = 3.6 * 100
        let radians = degrees * .pi/(1.8*100)
        
        let thisRadians = (arcAngle * 100) * .pi/(1.8*100)
        let theD = (radians - thisRadians)/2
        firstAngle += theD
        lastAngle += theD
        
        angles.append(firstAngle)
        let allAngles = self.areas.components(separatedBy: ",")
        for index in 0..<allAngles.count {
            let n = NumberFormatter().number(from: allAngles[index])
            let angle = radian(for: CGFloat(truncating: n!)) + angles[index]
            angles.append(angle)
        }
        
        angles.append(lastAngle)
        return angles
    }
    
    func createArcWith(startAngle: CGFloat, endAngle: CGFloat, arcCap: CGLineCap, strokeColor: UIColor, center:CGPoint) {
        // 1
        let center = center
        let radius: CGFloat = max(MainViewMy.bounds.width, MainViewMy.bounds.height)/2 - MainViewMy.frame.width/20
        let lineWidth: CGFloat = MainViewMy.frame.width/10
        // 2
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        // 3
        path.lineWidth = lineWidth
        path.lineCapStyle = arcCap
        strokeColor.setStroke()
        path.stroke()
    }
    
    func drawNeedleCircle() {
        // 1
        let circleLayer = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: MainViewMy.bounds.width / 2, y: MainViewMy.bounds.height / 2), radius: MainViewMy.bounds.width/20, startAngle: 0.0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
        // 2
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = circleColor.cgColor
        MainViewMy.layer.addSublayer(circleLayer)
    }
    
    func drawNeedle() {
        // 1
        let triangleLayer = CAShapeLayer()
        let shadowLayer = CAShapeLayer()
        
        // 2
        triangleLayer.frame = MainViewMy.bounds
        shadowLayer.frame = CGRect(x: MainViewMy.bounds.origin.x, y: MainViewMy.bounds.origin.y + 5, width: MainViewMy.bounds.width, height: MainViewMy.bounds.height)
        
        // 3
        let needlePath = UIBezierPath()
        needlePath.move(to: CGPoint(x: MainViewMy.bounds.width/2, y: MainViewMy.bounds.width * 0.95))
        needlePath.addLine(to: CGPoint(x: MainViewMy.bounds.width * 0.47, y: MainViewMy.bounds.width * 0.42))
        needlePath.addLine(to: CGPoint(x: MainViewMy.bounds.width * 0.53, y: MainViewMy.bounds.width * 0.42))
        
        needlePath.close()
        
        // 4
        triangleLayer.path = needlePath.cgPath
        shadowLayer.path = needlePath.cgPath
        
        // 5
        triangleLayer.fillColor = needleColor.cgColor
        triangleLayer.strokeColor = needleColor.cgColor
        shadowLayer.fillColor = shadowColor.cgColor
        // 6
        MainViewMy.layer.addSublayer(shadowLayer)
        MainViewMy.layer.addSublayer(triangleLayer)
        
        var firstAngle = radian(for: 0)
        
        let degrees:CGFloat = 3.6 * 100 // Entire Arc is of 240 degrees
        let radians = degrees * .pi/(1.8*100)
        
        let thisRadians = (arcAngle * 100) * .pi/(1.8*100)
        let theD = (radians - thisRadians)/2
        firstAngle += theD
        let needleValue = radian(for: self.needleValue) + firstAngle
        animate(triangleLayer: triangleLayer, shadowLayer: shadowLayer, fromValue:self.fromvalue1, toValue: self.tovalue1, duration:CFTimeInterval(self.durationValue1)) {
        //    self.animate(triangleLayer: triangleLayer, shadowLayer: shadowLayer, fromValue: self.fromvalue1, toValue: self.tovalue1, duration: CFTimeInterval(self.durationValue1), callBack: {})
        }
    }
    
    func animate(triangleLayer: CAShapeLayer, shadowLayer:CAShapeLayer, fromValue: CGFloat, toValue:CGFloat, duration: CFTimeInterval, callBack:@escaping ()->Void) {
        // 1
        CATransaction.begin()
        let spinAnimation1 = CABasicAnimation(keyPath: "transform.rotation.z")
        spinAnimation1.fromValue = fromValue//radian(for: fromValue)
        spinAnimation1.toValue = toValue//radian(for: toValue)
        spinAnimation1.duration = duration
        spinAnimation1.fillMode = CAMediaTimingFillMode.forwards
        spinAnimation1.isRemovedOnCompletion = false
        
        CATransaction.setCompletionBlock {
            callBack()
        }
        // 2
        triangleLayer.add(spinAnimation1, forKey: "indeterminateAnimation")
        shadowLayer.add(spinAnimation1, forKey: "indeterminateAnimation")
        CATransaction.commit()
    }
    
    
    public func animatefrom0to1(fromValue:CGFloat,toValue:CGFloat,duration:CFTimeInterval,callBack:@escaping()-> Void){
        
        
    }
    
    
    
    
    
    
    
    
    
    
    @IBOutlet var pushbtn: UIButton!
    var fromvalue1: CGFloat = 1
     var tovalue1: CGFloat = 1
     var durationValue1: CGFloat = 1.5
     //var fromvalue1: CGFloat = 2.4
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawGauge()
        pushbtn.addTarget(self, action: #selector(buttonAction), for: UIControl.Event.touchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        fromvalue1 = 1
        tovalue1 = 5
        durationValue1 = 1.5
        
        self.drawGauge()
    }

}

