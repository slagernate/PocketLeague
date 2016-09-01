//
//  SoccerScene.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

import SpriteKit



class SoccerScene: SKScene, SKPhysicsContactDelegate {
	
	
    override func didMoveToView(view: SKView) {
		
		let screenRect = UIScreen.mainScreen().bounds
		
		// Setup Physics
		physicsWorld.gravity = CGVectorMake(0, -1.0)
		physicsWorld.contactDelegate = self
		
		// Create boundary for field
		let FieldBoundary = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height)
		let boundaryBody = SKPhysicsBody(edgeLoopFromRect: FieldBoundary)
		self.physicsBody = boundaryBody
		self.physicsBody?.categoryBitMask = PhysicsCategory.Boards
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball | PhysicsCategory.Car
		
		
		// Field
		let Field = SKSpriteNode(color: SKColor.greenColor(), size: CGSize(width: frame.size.width, height: frame.size.height))
		Field.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(Field)
		
		// Add a car
		let carSpawnSpot = CGPoint(x: frame.midX, y: frame.midY)
		let car1 = Car(spawnPosition: carSpawnSpot)
		addChild(car1)
		
    }
	
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
		
	}
	
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
