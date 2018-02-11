//: A UIKit based Playground for presenting user interface

import UIKit
//import AppKit
import PlaygroundSupport

class V2<T> {
    public let x : T
    public let y : T
    init(_ x : T, _ y : T) {
        self.x = x
        self.y = y
    }
}

class MyViewController : UIViewController {
    override func loadView() {
        let appView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 700))
        appView.backgroundColor = .red
        
        [V2(0,0), V2(1,0), V2(2,0),
         V2(0,1), V2(1,1), V2(2,1)].forEach { (v) in
            let sz     = V2(60,60)
            let pd     = V2(10,10)
            let colour = [UIColor.blue,
                          UIColor.green,
                          UIColor.cyan][(v.x + v.y*3)%3]
            let rounded = RoundedCornerShadowView(frame: CGRect(x: 20+32*v.x, y: 20+(sz.y)*v.y, width: sz.x, height: sz.y), colour: colour)
            appView.addSubview(rounded)
        }
        
        appView.addSubview(GradientView(frame: CGRect(x: 10, y: 320, width: 320, height: 40)))
        
        //let inner   = UIView()
        //inner.addConstraint(NSLayoutConstraint())
        //inner.backgroundColor = UIColor.blue
        
        //rounded.addSubview(inner)
        
        self.view = appView
    }
}

class GradientView : UIView {
    
    @IBInspectable var startColour : UIColor = .white {
        didSet { self.setNeedsLayout() }
    }
 
    @IBInspectable var endColour : UIColor = .black {
        didSet { self.setNeedsLayout() }
    }

    @IBInspectable var startPointX : CGFloat = 0.0 {
        didSet { self.setNeedsLayout() }
    }
    
    @IBInspectable var startPointY : CGFloat = 0.0 {
        didSet { self.setNeedsLayout() }
    }

    @IBInspectable var endPointX : CGFloat = 1.0 {
        didSet { self.setNeedsLayout() }
    }
    
    @IBInspectable var endPointY : CGFloat = 0.0 {
        didSet { self.setNeedsLayout() }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        let gradientLayer = self.layer as! CAGradientLayer
        //gradientLayer.colors = [self.startColour.cgColor, self.endColour.cgColor]
        gradientLayer.colors = [UIColor.red,
                                UIColor(red: 255, green: 165, blue: 0, alpha: 1.0),
                                UIColor.yellow,
                                UIColor(red: 0, green: 128, blue: 0, alpha: 1.0),
                                UIColor.cyan,
                                UIColor.blue,
                                UIColor.purple].map({ (c) -> CGColor in c.cgColor }).reversed()
        gradientLayer.startPoint = CGPoint(x: self.startPointX, y: self.startPointY)
        gradientLayer.endPoint = CGPoint(x: self.endPointX, y: self.endPointY)
        self.layer.cornerRadius = 5 //cornerRadius
        self.layer.shadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor //shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 2.0 //shadowBlur
        self.layer.shadowOpacity = 0.3
    }
}

class RoundedCornerShadowView : UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.debugDescription)
        print(event.debugDescription)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.debugDescription)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, colour: UIColor.white)
    }
    
    init(frame: CGRect, colour: UIColor) {
        super.init(frame: frame)
        let shadowView = UIView(frame: frame)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 8)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 5
        
        let view = UIView(frame: shadowView.bounds)
        view.backgroundColor = colour
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        
        shadowView.addSubview(view)
        self.addSubview(shadowView)
        
    }
    
    //override func draw(_ rect: CGRect) {
        //let c = UIGraphicsGetCurrentContext()
        //c?.addRect(CGRect(x: 10, y: 10, width: 80, height: 80))
        //c?.setStrokeColor(UIColor.red.cgColor)
        //c?.strokePath()
    //}
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
