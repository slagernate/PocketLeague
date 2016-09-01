//
//  Car.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/31/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

class Car: PhysicalObject {

	init(spawnPosition: CGPoint) {
		
		/* Temporary initialization.. will have further customization for different classes of cars */
		let carTexture = SKTexture(imageNamed: "BasicCar")
		let carWidth = CGFloat(screenSize.width/15)
		let carScale = CGFloat(183.0/140.0)
		let carSize = CGSize(width: carWidth, height: (carWidth*carScale))
		super.init(texture: carTexture, color: UIColor.clearColor(), size: carSize)
		self.position = spawnPosition
		self.name = "car"
		self.physicsBody = SKPhysicsBody(rectangleOfSize: carSize)
		self.objectMass = CGFloat(0.10)
		
		//Physics Setup
		self.physicsBody?.categoryBitMask = PhysicsCategory.Car
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Boards | PhysicsCategory.Car
		self.physicsBody?.categoryBitMask = PhysicsCategory.Car
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}