//
//  GameScene.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
	static let None			: UInt32 = 0x0
	static let All			: UInt32 = UInt32.max
	static let Ball			: UInt32 = 0x1 << 0
	static let Boards		: UInt32 = 0x1 << 1
	static let Player		: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
	
	
    override func didMoveToView(view: SKView) {
		
		// Setup Physics
		physicsWorld.gravity = CGVectorMake(0, 0)
		physicsWorld.contactDelegate = self
		
		// Create boundary for field
		let FieldBoundary = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
		let boundaryBody = SKPhysicsBody(edgeLoopFromRect: FieldBoundary)
		self.physicsBody = boundaryBody
		self.physicsBody?.categoryBitMask = PhysicsCategory.Boards
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball | PhysicsCategory.Player
		
		
		// Field
		let Field = SKSpriteNode(color: SKColor.greenColor(), size: CGSize(width: frame.size.width, height: frame.size.height))
		
		addChild(Field)
		
    }
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
		
	}
	
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
