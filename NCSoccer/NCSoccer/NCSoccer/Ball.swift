//
//  Ball.swift
//  NCSoccer
//
//  Created by Nathan Slager on 9/18/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

class Ball: PhysicalObject {
	
	let MAXBALLSPEED :CGFloat = 0.08
	//var accelerate: Bool
	//var steerRight: Bool
	//var steerLeft: Bool
	
	init(spawnPosition: CGPoint) {
		
		/* Temporary initialization.. will have further customization for different classes */
		let ballTexture = SKTexture(imageNamed: "ball")
		let ballRadius = CGFloat(25)
		let ballSize = CGSize(width: ballRadius, height: ballRadius)

		super.init(texture: ballTexture, color: UIColor.clear, size: ballSize)
		
		self.position = spawnPosition
		
		self.name = "ball"
		
		//Physics Setup
		//self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: spawnPosition, size: carSize) )
		self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2)
		self.objectMass = CGFloat(2)
		physicsBody?.isDynamic = true // Default is true
		
		
		self.physicsBody?.categoryBitMask = PhysicsCategory.Ball
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Boards | PhysicsCategory.Car
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
