//
//  Car.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/31/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

class Car: PhysicalObject {

	let MAXCARSPEED: CGFloat = 500
	var steering: Bool
	var diagonalLength: CGFloat
	
	init(spawnPosition: CGPoint) {
		
		/* Temporary initialization.. will have further customization for different classes of cars */
		let carTexture = SKTexture(imageNamed: "BasicCar")
		let carWidth = CGFloat(screenSize.width/20)
		let carScale = CGFloat(183.0/140.0) // TODO
		let carSize = CGSize(width: (carWidth*carScale), height: carWidth)
		
		// Initialize movement variables
		self.steering = false
		self.diagonalLength = hypot(carSize.width, carSize.height)
		
		//self.steerRight = false
		//self.steerLeft = false
		
		super.init(texture: carTexture, color: UIColor.clear, size: carSize)
		
		
		self.speed = CGFloat(MAXCARSPEED)
		self.position = spawnPosition
		self.name = "car"
		
		//Physics Setup
		//self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: spawnPosition, size: carSize) )
		let carPhysicsSize = CGSize(width: self.size.width, height: self.size.height)
		self.physicsBody = SKPhysicsBody(rectangleOf: carPhysicsSize)
		self.objectMass = CGFloat(20000)
		self.physicsBody?.friction = 0.5
		self.physicsBody?.angularDamping = 1.0
		self.physicsBody?.linearDamping = 1.0
		self.physicsBody?.restitution = 0.1
		physicsBody?.isDynamic = true // Default is true
		
		
		self.physicsBody?.categoryBitMask = PhysicsCategory.Car
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Car | PhysicsCategory.Ball | PhysicsCategory.Boards
		

	}
	
	func steerTowards(direction: CGFloat)
	{
		
		var requestedTorque = self.zRotation - direction
		if requestedTorque < CGFloat(-M_PI) {
			requestedTorque += CGFloat(2 * M_PI)
		} else if requestedTorque > CGFloat(M_PI) {
			requestedTorque -= CGFloat(2 * M_PI)
		}
		
		//print("requested torque: \(requestedTorque)")
		let attenuatedTorque = CGFloat(0.0015) * requestedTorque
		//let attenuatedTorque = (requestedTorque * torqueAttenuator)
		
		let carVelocity = hypot((self.physicsBody?.velocity.dx)!, (self.physicsBody?.velocity.dy)!)

		let carVelRatio = carVelocity / self.MAXCARSPEED
		// Steering low and high velocities should be reduced using adjustedTorqueFactor
		// See function plotted on wolfram alpha here:
		/* https://www.wolframalpha.com/input/?i=graph+y+%3D+1%2F(+(x%5E3)+*+(+e%5E(1%2F(x))+-+1+)+) */
		let adjustedTorqueFactor = 1.0/(pow(carVelRatio, 3.0) * (pow(CGFloat(M_E), 1.0/(carVelRatio)) - 1.0))
		
		self.physicsBody?.applyTorque(-(attenuatedTorque * adjustedTorqueFactor))
		//print("adjusted torque: \(adjustedTorqueFactor)")
		
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
