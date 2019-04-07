import PlaygroundSupport
import SpriteKit

struct PhysicsCategory{
    static let CHARACTER : UInt32 = 0x1 << 1
    static let GROUND : UInt32 = 0x1 << 2
    static let BLOCK : UInt32 = 0x1 << 3
    static let BLOCKGREEN: UInt32 = 0x1 << 4
    static let ENEMY: UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var character = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var ground = SKSpriteNode()
    var block = SKSpriteNode()
    var restartButton = SKSpriteNode()
    var startOverButton = SKSpriteNode()
    var startOverBackground = SKSpriteNode()
    var isGameOver = Bool()
    var scoreBackground = SKSpriteNode()
    var score = Int()
    var moveSpeed = Int()
    var level = Int()
    var enemy = SKSpriteNode()
    
    func buildChar(){
        character = SKLabelNode(text: "")
        character.setScale(0.5)
        character.fontSize = 64
        character.physicsBody = SKPhysicsBody(circleOfRadius: character.frame.height/2)
        character.physicsBody?.categoryBitMask = PhysicsCategory.CHARACTER
        character.position = CGPoint(x: 50, y: 200)
        character.physicsBody?.affectedByGravity = true
        character.physicsBody?.isDynamic = true
        character.physicsBody?.contactTestBitMask = PhysicsCategory.GROUND | PhysicsCategory.BLOCK | PhysicsCategory.BLOCKGREEN | PhysicsCategory.ENEMY
        character.physicsBody?.collisionBitMask = PhysicsCategory.GROUND | PhysicsCategory.BLOCK | PhysicsCategory.BLOCKGREEN | PhysicsCategory.ENEMY
        character.name = "char"
        self.addChild(character)
    }
    
    func buildGround(){
        ground = SKSpriteNode(imageNamed: "ground.jpg")
        ground.size = CGSize(width: size.width, height: 50)
        ground.position = CGPoint(x: 300, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.GROUND
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.CHARACTER
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.CHARACTER
        self.addChild(ground)
    }
    
    func buildBlock(){
        let random = Int.random(in: 1...5)
        for i in 1...5{
            if i != random{
                block = SKSpriteNode(color: UIColor.red, size: CGSize(width: 50, height: 50))
                block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
                block.physicsBody?.categoryBitMask = PhysicsCategory.BLOCK
            }else{
                block = SKSpriteNode(color: UIColor.green, size: CGSize(width: 50, height: 50))
                block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
                block.physicsBody?.categoryBitMask = PhysicsCategory.BLOCKGREEN
            }
            block.name = "block"
            block.position = CGPoint(x: 100*i, y: 300)
            block.physicsBody?.affectedByGravity = false
            block.physicsBody?.isDynamic = false
            block.physicsBody?.contactTestBitMask = PhysicsCategory.CHARACTER
            block.physicsBody?.contactTestBitMask = PhysicsCategory.CHARACTER
            self.addChild(block)
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        self.physicsWorld.contactDelegate = self
        buildBackground()
        buildChar()
        buildGround()
        buildBlock()
        buildScore()
        buildStartOverButton()
        level = 1
        isGameOver = false
        moveCharacter()
    }
    
    func buildEnemy(){
        enemy = SKSpriteNode(imageNamed: "germ.png")
        enemy.setScale(0.5)
        enemy.name = "enemy"
        enemy.size = CGSize(width: 50, height: 50)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.ENEMY
        enemy.position = CGPoint(x: 550, y: 200)
        enemy.physicsBody?.affectedByGravity = true
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.CHARACTER | PhysicsCategory.GROUND
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.CHARACTER | PhysicsCategory.GROUND
        self.addChild(enemy)
    }
    
    func buildScore(){
        scoreBackground = SKSpriteNode(color: UIColor.white, size: CGSize(width: 143, height: 30))
        scoreBackground.position = CGPoint(x: 493, y: 360)
        self.addChild(scoreBackground)
        
        score = 0
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = UIColor.blue
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.position = CGPoint(x: 500, y: 350)
        self.addChild(scoreLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask{
        case PhysicsCategory.CHARACTER | PhysicsCategory.GROUND :
            break
        case PhysicsCategory.CHARACTER | PhysicsCategory.BLOCK:
            isGameOver = true
            buildRestartButton()
        case PhysicsCategory.CHARACTER | PhysicsCategory.BLOCKGREEN:
            score += 10
            level = (score/10) + 1
            scoreLabel.text = "Score: \(score)"
            for _ in 0...4{
                if let block = self.childNode(withName: "block") as? SKSpriteNode{
                    block.removeFromParent()
                }
            }
            if let char = self.childNode(withName: "char") as? SKLabelNode{
                char.removeFromParent()
            }
            if let enemy = self.childNode(withName: "enemy") as? SKSpriteNode{
                enemy.removeFromParent()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.buildChar()
                self.moveCharacter()
                self.buildBlock()
                if self.level >= 10{
                    self.buildEnemy()
                self.moveEnemy()
                }
            }
        case PhysicsCategory.CHARACTER | PhysicsCategory.ENEMY:
            isGameOver = true
            buildRestartButton()
        default: break
        }
    }
    
    func buildBackground(){
        let background = SKSpriteNode(imageNamed: "galaxyconvert.png")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        self.addChild(background)
    }
    
    func buildRestartButton(){
        restartButton = SKSpriteNode(imageNamed: "tryAgainButton.png")
        restartButton.name = "restart"
        restartButton.size.height = 100
        restartButton.size.width = 100
        restartButton.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        self.addChild(restartButton)
    }
    
    func buildStartOverButton(){
        startOverBackground = SKSpriteNode(color: UIColor.white, size: CGSize(width: 50, height: 50))
        startOverBackground.position = CGPoint(x: 30, y: 350)
        startOverBackground.name = "startOver"
        self.addChild(startOverBackground)
        
        startOverButton = SKSpriteNode(imageNamed: "retry.png")
        startOverButton.size.height = 50
        startOverButton.size.width = 50
        startOverButton.position = CGPoint(x: 30, y: 350)
        self.addChild(startOverButton)
    }
    
    func moveCharacter(){
        if score == 0{
            moveSpeed = 0
        }else{
            moveSpeed = score / 100
        }
        let moveRight = SKAction.moveBy(x: 500, y: 0, duration: 5.0-Double(moveSpeed))
        let moveLeft = SKAction.moveBy(x: -500, y: 0, duration: 5.0-Double(moveSpeed))
        
        let sequence = SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft]))
        //let sequence = SKAction.sequence([moveRight, moveLeft])
        character.run(sequence)
    }
    
    func moveEnemy(){
        let moveLeft = SKAction.moveBy(x: -500, y: 0, duration: 5.0-Double((level/10)-1))
        let moveRight = SKAction.moveBy(x: 500, y: 0, duration: 5.0-Double((level/10)-1))
        let sequence = SKAction.repeatForever(SKAction.sequence([moveLeft, moveRight]))
        enemy.run(sequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver{
            self.character.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.character.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            enumerateChildNodes(withName: "//*") { (node, err) in
                if node.name == "startOver"{
                    if node.contains(touches.first!.location(in: self)){
                        self.restartGame()
                    }
                }
            }
        }else{
            for touch in touches{
                if touch == touches.first{
                    enumerateChildNodes(withName: "//*") { (node, err) in
                        if node.name == "restart"{
                            if node.contains(touch.location(in: self)){
                                self.restartGame()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func restartGame(){
        let scene = GameScene(size: self.size)
        let animation = SKTransition.crossFade(withDuration: 0.5)
        self.view?.presentScene(scene, transition: animation)
    }
}

let frame = CGRect(x: 0, y: 0, width: 600, height: 400)
let view = SKView(frame: frame)
let scene = GameScene(size: frame.size)
view.presentScene(scene)
PlaygroundPage.current.liveView = view
