//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


extension CGPoint {
    public static func +(a: CGPoint, b: CGPoint) -> CGPoint { return CGPoint(x: a.x + b.x, y: a.y + b.y) }
    public static func -(a: CGPoint, b: CGPoint) -> CGPoint { return CGPoint(x: a.x - b.x, y: a.y - b.y) }
}


func chooseRandom<T>(from list: [T]) -> T {
    return list[Int(arc4random_uniform(UInt32(list.count)))]
}

func createHandlePath(frame: CGRect, relativeRadius: CGFloat) -> UIBezierPath {
    
    let r1 = frame.height/2
    let r2 = relativeRadius * r1
    
    let c1 = CGPoint(x: r1,               y: frame.midY)
    let c2 = CGPoint(x: frame.width - r2, y: frame.midY)
    
//    let theta = atan2(r1 - r2, c2.x - c1.x)
    let theta = atan2(c2.x - c1.x, r1 - r2)
    
    let path = UIBezierPath(
        arcCenter: c1,
        radius: r1,
        startAngle: theta,
        endAngle: -theta, clockwise: true)
    
    path.addLine(to: c2 + CGPoint(x: r2*cos(theta), y: -r2*sin((theta))))
    
    path.addArc(withCenter: c2, radius: r2, startAngle: -theta, endAngle: theta, clockwise: true)
    
    path.close()
    
    return path
}

class TaperingView: UIView {
    
    var relativeRadius: CGFloat = 0.7 {
        didSet { self.updatePath() }
    }
    
    var lineWidth: CGFloat = 4.5 {
        didSet { self.updatePath() }
    }
    
    let shape: CAShapeLayer = CAShapeLayer()
    let outlineShape: CAShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    func initialise() {
        self.backgroundColor = .clear
        self.layer.addSublayer(self.shape)
        self.shape.fillColor = UIColor.clear.cgColor
        self.shape.lineWidth = self.lineWidth
        self.shape.strokeColor = UIColor.black.cgColor
        self.updatePath()
        
        self.outlineShape.fillColor = UIColor.clear.cgColor
        self.outlineShape.strokeColor = UIColor.blue.cgColor
        self.outlineShape.lineDashPhase = 0.0
        self.outlineShape.lineDashPattern = [8.0, 3.0]
        self.outlineShape.lineWidth = 2.0
        self.layer.addSublayer(self.outlineShape)
        
        //self.isUserInteractionEnabled = true
        //let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        //self.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updatePath()
    }
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        if self.outlineShape.path!.contains(gesture.location(in: self)) {
            self.outlineShape.isHidden = !self.outlineShape.isHidden
        } else if self.shape.path!.contains(gesture.location(in: self)) {
            //self.backgroundColor = .black
            self.frame = self.frame.insetBy(dx: -5, dy: -5)
            self.updatePath()
        }
    }
    
    func setRandomComplementaryColours() {
        print("setRandomComplementaryColours")
        let c = chooseRandom(from: [#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1),#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1),#colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1),#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)])
    
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 1.0
        let _ = c.getRed(&r, green: &g, blue: &b, alpha: &a)
    
        self.shape.fillColor = c.cgColor
        self.outlineShape.strokeColor = UIColor(red: 1.0-r, green: 1.0-g, blue: 1.0-b, alpha: a).cgColor
    }
    
    func updatePath() {
        self.shape.path = createHandlePath(frame: self.bounds, relativeRadius: self.relativeRadius).cgPath
        
        let path = CGPath(__byStroking: self.shape.path!,
                          transform: nil,
                          lineWidth: self.shape.lineWidth,
                          lineCap:  CGLineCap.round, //self.shape.lineCap,
            lineJoin: CGLineJoin.miter, //self.shape.lineJoin,
            miterLimit: self.shape.miterLimit)
        self.outlineShape.path = path
        
    }
}


class RubricView: UILabel {
    init() {
        super.init(frame: CGRect())
        self.initialise()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    func initialise() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = "Swift Sandbox"
        self.font = UIFont(name: "Rubrik-Light", size: 22.0)
        self.sizeToFit()
    }
}


class PolygonView: UIView {
    
    var shape: CAShapeLayer = CAShapeLayer()
    
    var sides: UInt    = 5 { didSet { self.updateShape() } }
    var phase: CGFloat = 0 { didSet { self.transform = CGAffineTransform(rotationAngle: self.phase) } }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialise()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateShape()
    }
    
    func updateShape() {
        let path  = UIBezierPath()
        let theta = 2 * .pi / CGFloat(self.sides)
        let r     = self.bounds.height/2
        let o     = CGPoint(x: self.bounds.midX, y:self.bounds.midY)
        path.move(to: o + CGPoint(x: r * cos(CGFloat(0)*theta), y: r * sin(CGFloat(0)*theta)))
        (1 ... self.sides).forEach { i in
            path.addLine(to: o + CGPoint(x: r * cos(CGFloat(i)*theta), y: r * sin(CGFloat(i)*theta)))
        }
        
        
        self.shape.fillColor = UIColor.clear.cgColor
        self.shape.lineWidth = 4
        self.shape.strokeColor = UIColor.red.cgColor
        
        self.shape.frame = self.bounds
        self.shape.path = path.cgPath
    }
    
    func initialise() {
        self.layer.addSublayer(self.shape)
        self.updateShape()
    }
    
}


class MyViewController : UIViewController {
    
    weak var slider: UISlider!
    weak var label: UILabel!
    var tapering: [TaperingView] = []
    
    var selected: TaperingView? = nil
    
    weak var polygon: PolygonView!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        self.tapering = [ TaperingView(frame: CGRect(x: 20, y:  50, width: 100, height: 30))
                        , TaperingView(frame: CGRect(x: 20, y:  90, width: 100, height: 30))
                        , TaperingView(frame: CGRect(x: 20, y: 130, width: 200, height: 60))]
        self.tapering.forEach({ view.addSubview($0) })
        
        let rubric = RubricView()
        view.addSubview(rubric)
        rubric.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        rubric.topAnchor.constraint(equalTo: view.topAnchor, constant: 17.0).isActive = true
        
        print("Creating slider")
        let slider = UISlider()
        //slider.isContinuous = true
        slider.minimumValue = 0.0
        slider.maximumValue = 2.0
        
        
        slider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)),
                       for: .valueChanged)
        
        view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60.0).isActive = true
        slider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        self.slider = slider
        //self.view.layoutIfNeeded()
        
        let label = UILabel()
        label.text = "\(slider.value)"
        label.font = UIFont(name: "Rubrik-Medium", size: 22.0)
        label.textColor = .black
        
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(equalTo: slider.leadingAnchor, constant: -4).isActive = true
        label.centerYAnchor.constraint(equalTo: slider.centerYAnchor, constant: 0).isActive = true
        
        let polygon = PolygonView()
        polygon.sides = 6
        polygon.shape.fillColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        view.addSubview(polygon)
        polygon.translatesAutoresizingMaskIntoConstraints = false
        polygon.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        polygon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        polygon.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
        polygon.heightAnchor.constraint(equalTo: polygon.widthAnchor, multiplier: 1.0).isActive = true
        
        self.polygon = polygon
        self.label = label
        self.view = view
    }
}

extension MyViewController {
    
    @objc func sliderValueDidChange(_ sender: UISlider) {
        self.label.text = "\(String(format: "%.02f", sender.value))"
        self.label.sizeToFit()
        self.selected?.relativeRadius = CGFloat(sender.value)
        
        self.polygon.phase = CGFloat(sender.value * 2 * .pi)
    }
    
}

extension MyViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let view  = self.view.hitTest(touch.location(in: self.view), with: nil) as? TaperingView else { return }
        self.selected?.outlineShape.lineDashPattern = [8.0, 3.0]
        self.selected = view
        view.outlineShape.lineDashPattern = nil
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}



// Present the view controller in the Live View window
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = MyViewController()
