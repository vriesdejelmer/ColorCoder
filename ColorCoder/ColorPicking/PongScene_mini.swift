//
//  GameScene.swift
//  PsychoPong
//
//  Created by Jelmer de Vries on 26/09/2019.
//  Copyright © 2019 Jelmer de Vries. All rights reserved.
//

import SpriteKit

enum Player {
    case player1, player2
}

protocol PongViewContainer: AnyObject {
    func updateScore(for player: Player, to score: Int)
}

typealias PaddleNode = SKNode & Paddle

class PongScene: SKScene {

    var player1: PaddleNode!
    var player2: PaddleNode!
    var ball    = SKShapeNode(ellipseOf: GameSettings.ballSize)
    
    var orientation: OrientationDirection   = .horizontal
    let edgeExtension: CGFloat  = 400       //the extension of the edges behind the players beyond the visible field
    var movingInitiated = false
    var initialPositionsSet = false
    var setup   = false
    var previousWinner: Player?
    weak var viewDelegate: PongViewContainer?

    var player1Score = 0 {
        didSet { self.viewDelegate?.updateScore(for: .player1, to: player1Score) }
    }
    var player2Score = 0 {
        didSet { self.viewDelegate?.updateScore(for: .player2, to: player2Score) }
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        view.showsPhysics   = true

        if !self.setup { self.setupScene() }
        self.constrainPaddles()
        self.initiateMovement()
    }

    func setupScene() {
        self.backgroundColor = .white

        self.setupBorder()
        self.setupNodes()
        self.setInitialPositions()
        self.addNodesToScene()
        self.setup = true
    }

    func initiateMovement() {
            //TODO uggly as fuck
        self.ball.physicsBody?.isDynamic    = false
        self.ball.physicsBody?.isDynamic    = true
        if previousWinner == .player1 {
            self.ball.physicsBody?.applyImpulse(GameSettings.getReversedIntensity(for: self.orientation))
        } else {
            self.ball.physicsBody?.applyImpulse(GameSettings.directionalSpeed)
        }
    }

    func resetGame() {
        self.setInitialPositions()
        self.initiateMovement()
    }

    func setupNodes() {

        let paddleSize      = self.orientation == .vertical ? GameSettings.paddleSize : GameSettings.invertedPaddleSize
        self.player1 = SoapPaddle(paddleSize: paddleSize)
        self.player2 = RegularPaddle(paddleSize: paddleSize, color: .red)
        
        self.ball = Ball(of: GameSettings.ballSize)
//        let weirdPaddleSize = CGSize(width: paddleSize.width, height: paddleSize.height*2)
//        let player2Img          = UIImage(named: "redSquare1000")?.getWeirdShape(for: weirdPaddleSize, with: GameSettings.paddleThickness)
//        self.player2.size       = weirdPaddleSize
//        self.player2.texture    = SKTexture(image: player2Img!)
//        self.player2.physicsBody   = self.getWeirdPaddleBody(with: weirdPaddleSize)
    }
    
    func setupBorder() {
        let frame   = orientation == .vertical ? self.frame.insetBy(dx: 0, dy: -edgeExtension) : self.frame.insetBy(dx: -edgeExtension, dy: 0)
        let border  = SKPhysicsBody(edgeLoopFrom: frame)
        border.friction         = 0
        border.restitution      = 1
        border.linearDamping    = 0
        border.angularDamping   = 0
        self.physicsBody    = border
    }

    func setInitialPositions() {
        let viewSize            = self.frame.size
        if viewSize != .zero {
            self.ball.position          = CGPoint(x: viewSize.width/2, y: viewSize.height/2)
            if orientation == .vertical {
                self.player1.position       = CGPoint(x: viewSize.width/2, y: GameSettings.paddleSideOffset)
                self.player2.position       = CGPoint(x: viewSize.width/2, y: viewSize.height-GameSettings.paddleSideOffset)
            } else if orientation == .horizontal {
                self.player1.position       = CGPoint(x: GameSettings.paddleSideOffset, y: viewSize.height/2)
                self.player2.position       = CGPoint(x: viewSize.width-GameSettings.paddleSideOffset, y: viewSize.height/2)
            }
            self.initialPositionsSet    = true
        }
    }

    func addNodesToScene() {
        self.addChild(self.player1)
        self.addChild(self.player2)
        self.addChild(self.ball)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.count == 1 {
            guard let locationOfTouch = touches.first?.location(in: self) else { return }
            if orientation == .horizontal && locationOfTouch.x < 200 {
                self.movingInitiated = true
            } else if orientation == .vertical && locationOfTouch.y < 200 {
                self.movingInitiated = true
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.movingInitiated && touches.count == 1 {
            guard let locationOfTouch = touches.first?.location(in: self) else { return }
            if orientation == .horizontal {
                self.player1.targetPosition = CGPoint(x: GameSettings.paddleSideOffset, y: locationOfTouch.y)
            } else {
                self.player1.targetPosition = CGPoint(x: locationOfTouch.x, y: GameSettings.paddleSideOffset)
            }
            self.constrainPaddles()

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.movingInitiated    = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.movingInitiated    = false
    }

    override func didChangeSize(_ oldSize: CGSize) {

        if oldSize == .zero { self.setInitialPositions() }
        self.setOrientation(to: self.frame.size)
        self.setupBorder()
    }

    func setOrientation(to size: CGSize) {
        let oldOrientation: OrientationDirection?   = self.orientation
        if size.width > size.height {
            self.orientation = .horizontal
        } else {
            self.orientation = .vertical
        }

        if let previousOrientation = oldOrientation {
            self.adaptObjects(to: orientation, from: previousOrientation)
        }
    }

    func adaptObjects(to newOrientation: OrientationDirection, from oldOrientation: OrientationDirection) {
        if oldOrientation != newOrientation {
            self.setupNodes()

            let currentPlayer1Pos   = self.player1.position
            self.player1.position   = CGPoint(x: currentPlayer1Pos.y, y: currentPlayer1Pos.x)
            let currentPlayer2Pos   = self.player2.position
            self.player2.position   = CGPoint(x: currentPlayer2Pos.y, y: currentPlayer2Pos.x)
            let currentBallPosition = self.ball.position
            self.ball.position      = CGPoint(x: currentBallPosition.y, y: currentBallPosition.x)
            self.constrainPaddles()
        }
    }

    func constrainPaddles() {
        let currentPlayer1Pos = self.player1.position
        let currentPlayer2Pos = self.player2.position

        self.player1.position   = self.getConstrainedPaddlePosition(from: currentPlayer1Pos, player1: true)
        self.player2.position   = self.getConstrainedPaddlePosition(from: currentPlayer2Pos, player1: false)
    }

    func getConstrainedPaddlePosition(from position: CGPoint, player1: Bool) -> CGPoint {
        var newPosition = position

        if orientation == .horizontal {
            if player1 {
                newPosition.x = GameSettings.paddleSideOffset
            } else {
                newPosition.x = self.frame.width - GameSettings.paddleSideOffset
            }
            return newPosition
        } else if orientation == .vertical {
            if player1 {
                newPosition.y = GameSettings.paddleSideOffset
            } else {
                newPosition.y = self.frame.height - GameSettings.paddleSideOffset
            }
        }

        return newPosition
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        self.allowPlayer2Response()
        self.checkGameStatus()
    }

    func allowPlayer2Response() {
        if let ballVelocity = self.ball.physicsBody?.velocity {
            
            let verticalTowards     = self.orientation == .vertical && ballVelocity.dy > 0
            let horizontalTowards   = self.orientation == .horizontal && ballVelocity.dx > 0
            
            if verticalTowards || horizontalTowards {
            
                self.movePlayer2()
            }
        }
    }

    func checkGameStatus() {
        let player1Death = (self.orientation == .horizontal && ball.position.x < -20) ||
                            (self.orientation == .vertical && ball.position.y < -20)
        let player2Death = (self.orientation == .horizontal && ball.position.x > self.frame.width + 20) ||
                            (self.orientation == .vertical && ball.position.y > self.frame.height + 20)
        if player1Death {
            self.previousWinner = .player1
            self.player1Score += 1
        } else if player2Death {
            self.previousWinner = .player2
            self.player2Score += 1
        }

        if player1Death || player2Death {
            self.isPaused   = true
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] (_) in
                self?.resetGame()
                self?.isPaused   = false
            }

        }
    }

    func movePlayer2() {
        if self.orientation == .vertical {
            self.player2.run(SKAction.moveTo(x: self.ball.position.x, duration: 0.15))
        } else if self.orientation == .horizontal {
            self.player2.run(SKAction.moveTo(y: self.ball.position.y, duration: 0.15))
        }
    }

}


@discardableResult func saveImage(_ image: UIImage, imageName: String) -> Bool {

    let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(imageName)

    var imageData: Data?

    imageData = image.pngData()
    
    do {
        print(filePath.relativeString)
        try imageData?.write(to: filePath, options: [.atomic])
        return true
    } catch {
        return false
    }
}
