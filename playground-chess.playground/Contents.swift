//: A SpriteKit based Playground

import PlaygroundSupport
import XCPlayground
import SpriteKit
import Speech
import AVFoundation
import CoreText

//CTFontCreatePathForGlyph

//XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)
PlaygroundPage.current.needsIndefiniteExecution = true

let actor = VoiceActor()

func recognizeFile(url: URL) {
    
    print("Before request")
    
    SFSpeechRecognizer.requestAuthorization { (status) in
        print("Status:", status)
        guard let myRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-UK")) else {
            // A recognizer is not supported for the current locale
            return
        }
        
        if !myRecognizer.isAvailable {
            // The recognizer is not available right now
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        myRecognizer.recognitionTask(with: request) { (result, error) in
            print(result.debugDescription)
            print(error.debugDescription)
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                print("Failed to recognize")
                return
            }
            if result.isFinal {
                // Print the speech that has been recognized so far
                print("Speech in the file is \(result.bestTranscription.formattedString)")
            }
        }
    }
    print("After request")
    
}

class GameScene: SKScene {
    
    private var label : SKLabelNode!
    private var board : GridNode!
    
    private var chess: Chess = Chess()
    //private var pieces: [V2<UInt> : Chess.Piece] = [:]
    private var pieces: [V2Hash<UInt> : SKLabelNode] = [:]
    
    private var columnLabels: [SKLabelNode] = []
    private var rowLabels:    [SKLabelNode] = []
    
    private var selectedLabel: SKLabelNode = SKLabelNode()
    private var selectedGlyph: SKLabelNode = SKLabelNode()

    private let unselectedLabelColour: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    private let selectedLabelColour:   UIColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    
    private var selectedPosition: V2<UInt>? {
        
        willSet {
            if let pos = self.selectedPosition {
                self.columnLabels[Int(pos.x)].fontColor = self.unselectedLabelColour
                self.rowLabels[Int(pos.y)].fontColor = self.unselectedLabelColour
            }
        }
        
        didSet {
            if let pos = self.selectedPosition {
                guard let glyph = self.pieces[pos.hashable]?.text else { return }
                //self.selectedGlyph.fontColor = self.colour(for: self.chess.piece(at: pos)!)
                //self.selectedGlyph.isHidden = false
                //self.selectedGlyph.text = glyph
                //self.selectedGlyph.fontColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                
                //let marginX: CGFloat = 12
                //let dx = -(self.board.position.x + self.board.frame.width/2 + self.selectedGlyph.frame.width/2 + marginX)
                //self.selectedGlyph.position = V2(dx,0).cgPoint
                
                //self.selectedLabel.text = Chess.label(for: pos)
                //self.selectedLabel.position = V2(dx,0).cgPoint
                
                self.columnLabels[Int(pos.x)].fontColor = self.selectedLabelColour
                self.rowLabels[Int(pos.y)].fontColor = self.selectedLabelColour
            } else {
                self.selectedGlyph.isHidden = true
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        
        // Initialise the chess board
        self.board = GridNode(dimension: V2(8,8), tileSize: V2(60,60))!
        self.board.position = V2(0, 0).cgPoint
        self.addChild(self.board)
        
        // Just found out about file literals, want to try it out before I forget
        //#fileLiteral
        
        // Configure selected glyph
        self.selectedGlyph.fontSize = 124
        self.addChild(selectedGlyph)
        
        // Configure selected position label
        self.selectedLabel.fontSize = 32
        self.addChild(selectedLabel)
        
        // Initialise the pieces
        let o = V2(self.board.frame.origin)
        
        self.selectedGlyph.horizontalAlignmentMode = .center
        self.selectedGlyph.verticalAlignmentMode = .center
        
        self.selectedLabel.horizontalAlignmentMode = .center
        self.selectedLabel.verticalAlignmentMode = .center
        
        self.board.grid.withTiles { pos in
            
            // TODO | - Figure out the SpriteKit coordinate system
            //print(pos.x, pos.y)
            let box = self.board.grid.bounds(for: pos)
            guard let piece = self.chess.piece(at: pos) else { return }
            let glyph = SKLabelNode(text: Chess.glyph(for: piece))
            
            //let bg = SKSpriteNode(texture: nil, color: .red, size: glyph.frame.size)
            
            glyph.fontSize  = 52
            glyph.fontColor = self.colour(for: piece)
            glyph.position = (o + box.centre - V2(0,glyph.frame.height/2)).cgPoint
            
            //self.addChild(bg)
            // TOOD | - Shouldn't the scene object keep track of the glyphs rather than the pieces!
            self.pieces[pos.hashable] = glyph
            self.addChild(glyph)
            
            //bg.position = glyph.position
        }
        
        // Column labels
        let margins: V2<CGFloat> = V2(6,6)
        
        for column in (0 ... 7) {
            let label = SKLabelNode(text: Chess.alphabet[column])
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            let box = self.board.grid.bounds(for: V2(UInt(column), 0))
            
            label.position = (o + box.centre - V2(0,box.size.y/2) - V2(0,label.frame.height/2) - V2(0,margins.y)).cgPoint
            self.addChild(label)
            self.columnLabels.append(label)
        }
        
        // Row labels
        var midX: CGFloat? = nil
        
        for row in (0 ... 7) {
            let label = SKLabelNode(text: "\(row)")
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            let box = self.board.grid.bounds(for: V2(0,UInt(row)))
            
            midX = midX ?? (o.x + box.centre.x - box.size.x/2 - label.frame.width/2 - margins.x)
            
            label.position = V2(midX!, o.y+box.centre.y).cgPoint
            self.addChild(label)
            self.rowLabels.append(label)
        }
        
    }
    
    func colour(for piece: Chess.Piece) -> UIColor {
        // TODO | - Shouldn't this be the other way around (?)
        return (piece.colour == .white) ? #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) : #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //actor.say(words: [ "Knight to D5."
        //    , "Pawn to E6."
        //    , "Queen to E3."].reduce("", { $0 + $1 }))
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self.board)
        guard let p = self.board.grid.tile(for: V2(pos)) else { return }
        guard let piece = self.pieces[p.hashable] else { return }
        //print(Chess.glyph(for: piece))
        self.selectedPosition = p
        //self.selected = piece
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x: 0 , y: 0, width: 720, height: 480))
if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    sceneView.presentScene(scene)
}

guard let fileUrl = Bundle.main.url(forResource: "Chess", withExtension: "m4a") else { fatalError() }
//print(fileUrl)

//let player = (try? AVAudioPlayer(contentsOf: fileUrl))!
//player.play()

//recognizeFile(url: fileUrl)


PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
