import SpriteKit

class Corner: PhysicalObject {
    
    //    let MAXBALLSPEED :CGFloat = 0.08
    //    //var accelerate: Bool
    //    //var steerRight: Bool
    //    //var steerLeft: Bool
    //
    init(spawnPosition: CGPoint) {
        
        /* Temporary initialization.. will have further customization for different classes */
        let cornerTexture = SKTexture(imageNamed: "Corner")
        let cornerSize = CGSize(width: 100, height: 100)
        
        super.init(texture: cornerTexture, color: UIColor.clear, size: cornerSize)
        
        self.position = spawnPosition
        
        self.name = "Corner"
        
        //Physics Setup
        self.physicsBody = SKPhysicsBody(texture: self.texture!,
                                               size: self.texture!.size())
        self.physicsBody?.usesPreciseCollisionDetection = true
        physicsBody?.isDynamic = false // Default is true
        physicsBody?.restitution = 1.0
        
        self.physicsBody?.categoryBitMask = PhysicsCategory.Corner
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Boards | PhysicsCategory.Car
    
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
