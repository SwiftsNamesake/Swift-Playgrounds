import Foundation
import SpriteKit

public class Grid {
    
    // TODO | - Factor out pure grid layout logic
    
    public let dimension: V2<UInt> // TOOD | - Rename (?)
    public let tileSize: V2<CGFloat>
    
    public var tileCount: UInt { get { return V2.reduce(*, 1, self.dimension) } }
    
    // TODO | - Rename (?)
    public var size: V2<CGFloat> {
        get {
            return V2.dotwise({ CGFloat($0) * $1 }, self.dimension, self.tileSize)
        }
    }
    
    init(dimension: V2<UInt>, tileSize: V2<CGFloat>) {
        self.dimension = dimension
        self.tileSize = tileSize
    }
    
    public func bounds(for position: V2<UInt>) -> AABB<CGFloat> {
        // TODO | - Use optional (position might be out of bounds) (?)
        return AABB(lo: V2.dotwise({ CGFloat($0) * $1 }, position, self.tileSize), size: self.tileSize)
    }
    
    //public func hasTile(at position: V2<Int>) -> Bool {
    //
    //}
    
    public func tile(for point: V2<CGFloat>) -> V2<UInt>? {
        // TODO | - Take transforms into account (and origin, etc.)
        //        - What should we do for points outside the grid (?)
        //          The map would still work the same (at least if we changed
        //          UInt to Int), and it might be useful in some cases.
        //          Consider adding a separate method that never returned nil.
        //guard let x = UInt(point.x) else { return nil }
        
        let p = point + V2.fmap({$0/2}, self.size)
        let x = Int(p.x / self.tileSize.x)
        let y = Int(p.y / self.tileSize.y)
        
        guard (0 ..< Int(self.dimension.x)).contains(x) else { return nil }
        guard (0 ..< Int(self.dimension.y)).contains(y) else { return nil }
        return V2(UInt(x), UInt(y))
        //return V2.dotwise({ UInt($0 / CGFloat($1)) }, point, self.dimension)
    }
    
    public func withTiles(_ f: (V2<UInt>) -> Void) {
        // TODO | - Use autoclosure (?)
        //        - Rename (?)
        //        - Return an iterator of some kind instead (and rename) (?)
        for x in (0..<self.dimension.x) {
            for y in (0..<self.dimension.y) {
                f(V2(x,y))
            }
        }
    }
    
}

public class GridNode: SKSpriteNode {
    
    public let grid: Grid
    
    public init?(dimension: V2<UInt>, tileSize: V2<CGFloat>) {
        let grid = Grid(dimension: dimension, tileSize: tileSize)
        self.grid = grid
        guard let texture = GridNode.makeTexture(for: grid) else { return nil }
        super.init(texture: texture, color: .white, size: grid.size.cgSize)
        //SKLabelNode(text: )
    }
    
    
    public required init?(coder aDecoder: NSCoder) {
        // TODO | - Do this properly
        self.grid = Grid(dimension: V2(8,8), tileSize: V2(20.0, 20.0))
        super.init(coder: aDecoder)
    }

    
    static func colour(for position: V2<UInt>) -> UIColor {
        let light: UIColor = .white
        let dark: UIColor  = .black
        return ((position.x % 2) == (position.y % 2)) ? light : dark
    }
    
    static func makeTexture(for grid: Grid) -> SKTexture? {
        let renderer = UIGraphicsImageRenderer(size: grid.size.cgSize)
        let image = renderer.image { ctx in
            grid.withTiles { p in
                let rect =  grid.bounds(for: p).cgRect
                ctx.cgContext.setFillColor(GridNode.colour(for: p).cgColor)
                ctx.cgContext.addRect(rect.insetBy(dx: 4, dy: 4))
                ctx.cgContext.drawPath(using: .fill)
            }
        }
        
        return SKTexture(image: image)
    }
    
}
