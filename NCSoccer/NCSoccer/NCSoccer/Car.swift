//
//  Car.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/31/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

class Car: PhysicalObject {

    let MAXCARSPEED :CGFloat = 0.5
	var accelerate: Bool
	var steerRight: Bool
	var steerLeft: Bool
	
	init(spawnPosition: CGPoint) {
		
		/* Temporary initialization.. will have further customization for different classes of cars */
		let carTexture = SKTexture(imageNamed: "BasicCar")
		let carWidth = CGFloat(screenSize.width/20)
		let carScale = CGFloat(183.0/140.0)
		let carSize = CGSize(width: (carWidth*carScale), height: carWidth)
		
		// Initialize movement variables
    	self.accelerate = false
    	self.steerRight = false
    	self.steerLeft = false
		
		super.init(texture: carTexture, color: UIColor.clear, size: carSize)
		
		
		self.speed = CGFloat(MAXCARSPEED)
		self.position = spawnPosition
		self.name = "car"
		
		//Physics Setup
		//self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: spawnPosition, size: carSize) )
		let carPhysicsSize = CGSize(width: self.size.width, height: self.size.height)
		self.physicsBody = SKPhysicsBody(rectangleOf: carPhysicsSize)
		self.objectMass = CGFloat(20)
		self.physicsBody?.friction = 0.5
		self.physicsBody?.angularDamping = 1.0
		self.physicsBody?.linearDamping = 1.0
		self.physicsBody?.restitution = 1.0
		physicsBody?.isDynamic = true // Default is true

		
		self.physicsBody?.categoryBitMask = PhysicsCategory.Car
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Boards | PhysicsCategory.Car | PhysicsCategory.Ball
		

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
