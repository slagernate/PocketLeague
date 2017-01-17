//
//  Ball.swift
//  NCSoccer
//
//  Created by Nathan Slager on 9/18/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

class Ball: PhysicalObject {
	
	let MAXBALLSPEED: CGFloat = 0.08
	let BALLMASS: CGFloat = 8.0
	//var accelerate: Bool
	//var steerRight: Bool
	//var steerLeft: Bool
	
	init() {
		
		/* Temporary initialization.. will have further customization for different classes */
		let ballTexture = SKTexture(imageNamed: "ball.png")
		let ballRadius = screenSize.height / CGFloat(3)
		let ballSize = CGSize(width: ballRadius, height: ballRadius)

		super.init(texture: ballTexture, color: UIColor.clear, size: ballSize)
		
		self.name = "ball"
		
		//Physics Setup
		self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2)
		self.physicsBody?.mass = BALLMASS
		physicsBody?.isDynamic = true // Default is true
		physicsBody?.restitution = 1.0
		physicsBody?.linearDamping = 0.5
		
		self.physicsBody?.categoryBitMask = PhysicsCategory.Ball
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Boards | PhysicsCategory.Car
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
