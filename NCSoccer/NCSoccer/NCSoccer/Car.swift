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
	let CARMASS: CGFloat = 50
	
	var steering: Bool
	var steeringMagnitudeRatio: CGFloat = 0
	var steeringAngle: CGFloat = 0
	
	var diagonalLength: CGFloat
	var collided: Bool = false
	var collisionCoolDown: Bool = false
	var driftTime: UInt64 = 25
	var collideTime: UInt64 = 0
	var exhaust: SKEmitterNode!
	
	var playerID: String!
	
	init() {
		
		/* Temporary initialization.. will have further customization for different classes of cars */
		let carTexture = SKTexture(imageNamed: "BasicCar")
		let carWidth = CGFloat(screenSize.width/20)*2.0
		let carScale = CGFloat(183.0/140.0) 
		let carSize = CGSize(width: (carWidth*carScale), height: carWidth)
		
		// Initialize movement variables
		self.steering = false
		self.diagonalLength = hypot(carSize.width, carSize.height)
		
		//self.steerRight = false
		//self.steerLeft = false

		
		super.init(texture: carTexture, color: UIColor.clear, size: carSize)
		
		
		self.speed = CGFloat(MAXCARSPEED)
		self.name = "car"
		
		//Physics Setup
		//self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: spawnPosition, size: carSize) )
		let carPhysicsSize = CGSize(width: self.size.width, height: self.size.height)
		self.physicsBody = SKPhysicsBody(rectangleOf: carPhysicsSize)
		self.physicsBody?.mass = CARMASS  
		self.physicsBody?.friction = 0.5
		self.physicsBody?.angularDamping = 1.0
		self.physicsBody?.linearDamping = 0.5
		self.physicsBody?.restitution = 1.0
		physicsBody?.isDynamic = true // Default is true
		
		
		self.physicsBody?.categoryBitMask = PhysicsCategory.Car
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Car | PhysicsCategory.Ball | PhysicsCategory.Boards
		
		self.zPosition = 1
		
		exhaust = SKEmitterNode(fileNamed: "flame.sks")
		exhaust.position = CGPoint(x: -(self.size.width/2.5), y: 0)
		exhaust.zRotation += CGFloat(M_PI/2)
		exhaust.name = "exhaust"
		self.addChild(exhaust)
	}
	
	func steerTowards(direction: CGFloat)
	{
		
		var requestedTorque = self.zRotation - direction
		
		
		if requestedTorque < CGFloat(-M_PI) {
			requestedTorque += CGFloat(2 * M_PI)
		} else if requestedTorque > CGFloat(M_PI) {
			requestedTorque -= CGFloat(2 * M_PI)
		}
		
		// correction torque gets large as abs(requested torque) gets small. But it scales with the angular velocity. 
		// So when the requested torque is small (i.e. the joystick is close to where the car is facing) and the
		// car's angular velocity is high, this term will kick in and reverse the applied torque to smooth out the
		// car's oscillations and overcorrections
		let rotationalVelocity = self.physicsBody?.angularVelocity
		let correctionTorque = (rotationalVelocity! / (abs(requestedTorque) + 2.0))
		
		let carVelocity = hypot((self.physicsBody?.velocity.dx)!, (self.physicsBody?.velocity.dy)!)

		let carVelRatio = carVelocity / self.MAXCARSPEED
		// Steering at low and high velocities should be reduced using adjustedTorqueFactor
		// See function plotted on wolfram alpha here:
		/* https://www.wolframalpha.com/input/?i=graph+y+%3D+1%2F(+(x%5E3)+*+(+e%5E(1%2F(x))+-+1+)+) */
		let adjustedTorqueFactor = 1.0/(pow(carVelRatio, 3.0) * (pow(CGFloat(M_E), 1.0/(carVelRatio)) - 1.0))
		
		let torqueAttenuationFactor = CGFloat(10) // CARMASS
		let torque = (( -correctionTorque -  requestedTorque) * adjustedTorqueFactor) * torqueAttenuationFactor
		self.physicsBody?.applyTorque(torque)
		
		//self.physicsBody?.applyTorque(-output * 0.0015 * adjustedTorqueFactor)
		//print("adjusted torque: \(adjustedTorqueFactor)")
		
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
