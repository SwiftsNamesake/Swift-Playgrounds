import Foundation
import UIKit

public class V2<N> {
    public let x: N
    public let y: N
    public init(x: N, y: N) { self.x = x; self.y = y }
    public convenience init(_ x: N, _ y: N)  { self.init(x: x, y: y) }
    public convenience init(_ tuple: (N, N)) { self.init(x: tuple.0, y: tuple.1) }
}

extension V2 {
    // TODO | - Should these be static (?)
    //        - Gotta figure out the intricacies of generic types, especially scoping.
    public static func fmap<A>(_ f: (A) -> N, _ a: V2<A>) -> V2<N> {
        return V2(x: f(a.x), y: f(a.y))
    }
    
    public static func dotwise<A,B>(_ f: (A, B) -> N, _ a: V2<A>, _ b: V2<B>) -> V2<N> {
        return V2(x: f(a.x, b.x), y: f(a.y, b.y))
    }
    
    public static func reduce<R>(_ f: (R, N) -> R, _ x: R, _ a: V2<N>) -> R {
        return f(f(x, a.x), a.y)
    }
    
    // TODO | - Labelled tuple (?)
    public var tuple: (N, N) { get { return (self.x, self.y) } }
}

extension V2 where N: Numeric {
    //static func fmap // Not a numeric function
    public static func +(a: V2<N>, b: V2<N>) -> V2<N> { return V2(x: a.x + b.x, y: a.y + b.y) }
    public static func -(a: V2<N>, b: V2<N>) -> V2<N> { return V2(x: a.x - b.x, y: a.y - b.y) }
}

extension V2 where N == CGFloat {
    public var cgSize:  CGSize  { get { return CGSize(width: self.x, height: self.y) } }
    public var cgPoint: CGPoint { get { return CGPoint(x: self.x, y: self.y) } }
    
    convenience public init(_ size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
    
    convenience public init(_ point: CGPoint) {
        self.init(x: point.x, y: point.y)
    }
}

// TODO | - Remove this ugly workaround as soon as possible!
public struct V2Hash<N: Hashable>: Equatable, Hashable {
    
    public let x: N
    public let y: N
    
    public static func == (lhs: V2Hash<N>, rhs: V2Hash<N>) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y)
    }
    
    public var hashValue: Int {
        return self.x.hashValue ^ self.y.hashValue // &* 16777619
    }
}

//extension V2: Hashable where N: Hashable {
// https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md
extension V2 where N: Hashable {
    
    public var hashable: V2Hash<N> { get { return V2Hash(x: self.x, y: self.y) } }
    
    public var hashValue: Int {
        return self.x.hashValue ^ self.y.hashValue // &* 16777619
    }
}
