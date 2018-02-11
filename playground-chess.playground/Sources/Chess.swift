import Foundation

// TOOD | - 'Outcome' types

public class Chess {
   
    public static let alphabet: [String] = ["A","B","C","D","E","F","G","H"]
    
    public typealias Position = V2<UInt>
    public typealias Board = [[Chess.Piece?]]
    
    let board: Chess.Board
    
    public static let formations: Chess.Board = {
        // TODO | - Rename (?)
        //        - Refactor (?)
        let wp = Chess.Piece(colour: .white, kind: .pawn)
        let bp = Chess.Piece(colour: .black, kind: .pawn)
        
        let br  = Chess.Piece(colour: .black, kind: .rook)
        let bk  = Chess.Piece(colour: .black, kind: .knight)
        let bb  = Chess.Piece(colour: .black, kind: .bishop)
        let bq  = Chess.Piece(colour: .black, kind: .queen)
        let bki = Chess.Piece(colour: .black, kind: .king)
        
        let wr  = Chess.Piece(colour: .white, kind: .rook)
        let wk  = Chess.Piece(colour: .white, kind: .knight)
        let wb  = Chess.Piece(colour: .white, kind: .bishop)
        let wq  = Chess.Piece(colour: .white, kind: .queen)
        let wki = Chess.Piece(colour: .white, kind: .king)
        
        let blanks: [Chess.Piece?] = Array(repeating: nil,  count: 8)
        
        return [ [br, bk, bb, bq, bki, bb, bk, br]
               , Array(repeating: bp, count: 8)
               , blanks
               , blanks
               , blanks
               , blanks
               , Array(repeating: wp, count: 8)
               , [wr, wk, wb, wq, wki, wb, wk, wr]]
    }()
    
    public static func label(for position: Position) -> String {
        // TODO | - Rename (?)
        return "\(Chess.alphabet[Int(position.x)])\(position.y+1)"
    }
    
    public init() {
        self.board = Chess.formations
    }
    
    public func piece(at position: Position) -> Chess.Piece? {
        return self.board[Int(position.y)][Int(position.x)]
    }
    
    public func moves(from position: Position) -> [V2<UInt>] {
        // TODO | - Use a result type to distinguing between (eg.) empty tile and an obstructed piece (?)
        guard let piece = self.piece(at: position) else { return [] }
        let directions = self.directions(for: piece).filter({ Chess.withinBounds(from: position, direction: $0) })
        return []
    }
    
    public static func withinBounds(from position: Position, direction: V2<Int>) -> Bool {
        // TODO | - Rename (?)
        let pos = V2.fmap({Int($0)}, position)
        return Chess.withinBounds(position: pos + direction)
    }
    
    public static func withinBounds(position: V2<Int>) -> Bool {
        // TODO | - Rename (?)
        //        - Refactor
        return (0 ... 7).contains(position.x) && (0 ... 7).contains(position.y)
    }
    
    public func directions(for piece: Chess.Piece) -> [V2<Int>] {
        // TODO | - Make this static, if it's not taking the state of the board into account anyway (?)
        let horizontals = [V2(-1, 0), V2(1, 0)]
        let verticals   = [V2( 0,-1), V2(0, 1)]
        let diagonals   = [V2( 1, 1), V2(1,-1), V2(-1,-1), V2(-1,1)]
        
        switch piece.kind {
        case .king:   return horizontals + verticals + diagonals
        case .queen:  return horizontals + verticals + diagonals
        case .rook:   return horizontals + verticals
        case .bishop: return diagonals
        case .knight: return [] // Special case
        case .pawn:
            // TODO | - Special case for capturing
            //        - Robust way of determining direction for each colour
            //          Tie it to the original arrangement of the pieces.
            return (piece.colour == .white) ? [V2(0,-1)] : [V2(0,1)]
        }
    }
    
    public enum Colour {
        case white
        case black
    }
    
    public enum Kind {
        // TODO | - Rename (?)
        case king
        case queen
        case rook
        case bishop
        case knight
        case pawn
    }
    
    public struct Piece {
        public let colour: Chess.Colour
        public let kind:   Chess.Kind
        public init(colour: Chess.Colour, kind: Chess.Kind) {
            self.colour = colour
            self.kind   = kind
        }
    }
    
    public enum Index: UInt {
        // TODO | - Safe arithmetic
        case zero = 0
        case one
        case two
        case three
        case four
        case five
        case six
        case seven
        
        public static func from(_ i: UInt) -> Index? {
            return Index(rawValue: i)
        }
    }
    
    public static func adjacents(for position: V2<Index>) -> [V2<Index>] {
        return []
    }
    
    //public static func moves(for piece: Chess.Piece) -> [V2<UInt>] {
    //    let directions = self.directions(for: piece).filter({  })
    //    return []
    //}
    
}


extension Chess {
    public static func glyph(for piece: Chess.Piece) -> String {
        switch (piece.kind, piece.colour) {
        case (.king,   .black): return "♔"
        case (.queen,  .black): return "♕"
        case (.rook,   .black): return "♖"
        case (.bishop, .black): return "♗"
        case (.knight, .black): return "♘"
        case (.pawn,   .black): return "♙"
            
        case (.king,   .white): return "♚"
        case (.queen,  .white): return "♛"
        case (.rook,   .white): return "♜"
        case (.bishop, .white): return "♝"
        case (.knight, .white): return "♞"
        case (.pawn,   .white): return "♟"
        }
    }
}
