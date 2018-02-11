import Foundation
import UIKit

public class AABB<N> {
    
    public let lo: V2<N>
    public let hi: V2<N>
    
    public init(lo: V2<N>, hi: V2<N>) {
        self.lo = lo
        self.hi = hi
    }
    
}

extension AABB where N: Numeric {
    
    public var size: V2<N> { get { return self.hi - self.lo } }
    public var area: N     { get { return V2.reduce(*, 1, self.size) } }
    
    public convenience init(lo: V2<N>, size: V2<N>) {
        self.init(lo: lo, hi: lo + size)
    }
    
    public convenience init(centre: V2<N>, offset: V2<N>) {
        self.init(lo: centre - offset, size: V2.fmap({ 2*$0 }, offset))
    }
    
}

extension AABB where N: FloatingPoint {
    public var centre: V2<N> { get { return self.lo + V2.fmap({ $0 / 2 }, self.size) } }
}

extension AABB where N == CGFloat {
    public var cgRect: CGRect { get { return CGRect(origin: self.lo.cgPoint, size: self.size.cgSize) } }
}

