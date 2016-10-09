//
//  SoccerScene.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

import SpriteKit



class SoccerScene: SKScene, SKPhysicsContactDelegate {
	
	var car1: Car!
	
	// Controls
	var touchingJoystick: Bool = false
	var joyStickCenter: CGVector!
	var joyStick: Joystick!
	var throttle: Throttle!
	
	
    override func didMove(to view: SKView) {
		
		//let screenRect = UIScreen.mainScreen().bounds
		
		// Physics
		physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		
		physicsWorld.contactDelegate = self
		
		// Create boundary for field
		//let FieldBoundary = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height)
		//let boundaryBody = SKPhysicsBody(edgeLoopFrom: self.frame)
		//self.physicsBody = boundaryBody
		//self.physicsBody?.categoryBitMask = PhysicsCategory.Boards
		//self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
		
		
		// Controls
		
		// joystick
		joyStick = Joystick()
		joyStick.position = CGPoint(x: screenSize.width/5.0, y: screenSize.height/4.0)
		self.addChild(joyStick)
		
		// Throttle
		throttle = Throttle()
		throttle.position = CGPoint(x: frame.midX * 1.75, y: frame.midY/2.0)
		throttle.zPosition += 1
		self.addChild(throttle)
		
		// Field
		//let Field = SKSpriteNode(color: SKColor.green, size: CGSize(width: frame.size.width, height: frame.size.height))
		//Field.position = CGPoint(x: frame.midX, y: frame.midY)
		//addChild(Field)
		
		// Add a car
		let carSpawnSpot = CGPoint(x: 50, y: frame.midY)
		car1 = Car(spawnPosition: carSpawnSpot)
		addChild(car1)
		
		// Add ball
		let ballSpawnSpot = CGPoint(x: frame.midX*1.5, y: frame.midY)
		let ball = Ball(spawnPosition: ballSpawnSpot)
		addChild(ball)
		
    }
	
	
	// MARK: - Touch Handling
	

	
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
		
		var steering = 0
		for Touch in touches {
			let touch = Touch.location(in: self)
			let testNode = self.atPoint(touch) as? SKSpriteNode
			if (testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				throttle.moveTo(position: touch.y)
			} else { // Create joystick
				if (self.childNode(withName: "joystick") == nil) {
					joyStick.position = touch
					self.addChild(joyStick)
				}
				joyStick.steerTowards(position: touch)
				steering += 1
			}
			
		}
		
		if steering > 0 {
			car1.steering = true
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		var steering = 0
		for Touch in touches {
			let touch = Touch.location(in: self)
			let testNode = self.atPoint(touch) as? SKSpriteNode
			if (testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				throttle.moveTo(position: touch.y)
			} else {
				
				if (self.childNode(withName: "joystick") == nil) {
					joyStick.position = touch
					self.addChild(joyStick)
				}
				
				// This prevents unexpected behaviour when throttle thumb leaves throttle area
				if hypot(touch.x - joyStick.position.x, touch.y - joyStick.position.y) < (joyStick.leverLeash * 12.0) {
					joyStick.steerTowards(position: touch)
				}
				
				steering += 1
			}
		}
		
			
		if steering > 0 {
			car1.steering = true
		}
	
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for Touch in touches {
			let touch = Touch.location(in: self)
			let testNode = self.atPoint(touch) as? SKSpriteNode
			if !(testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				if (self.childNode(withName: "joystick") != nil) {
					self.joyStick.removeFromParent()
					car1.steering = false
				}
			}

		}
		
	}
	
	
	
	// MARK: - Frame Cycle
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
		
		// Really Strange syntax. Blocks are confusing but they're needed here for the
		// enumerateChildNodesWithName() function. Essentially a block is a function.
		// What I'm doing here is declaring a function that has parameter types SKNode!
		// and UnsafeMutablePointer<ObjCBool> and return type void. Then I'm setting that
		// equal to an actual function with with specific parameter names. Idrk how it works
		// It just does lol.. pretty sure this is like a 1 to 1 translation to a C function pointer.
		let updateNode: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			if let car = self.car1 {
				let carVelocity = car.physicsBody?.velocity
				let carVelocityMag = hypot((carVelocity?.dx)!, (carVelocity?.dy)!)
				let velocityAttenuation: CGFloat = 0.5
				if (carVelocityMag < (car.MAXCARSPEED)) {
					car.physicsBody?.applyImpulse(
						CGVector(dx: CGFloat(cos(car.zRotation)) * self.throttle.thrustRatio() * velocityAttenuation,
						         dy: CGFloat(sin(car.zRotation)) * self.throttle.thrustRatio() * velocityAttenuation))
					
				}
				
				

				// Converts spaceship movement to car movement by offsetting lateral velocity
				
				let driftDiff = atan2((carVelocity?.dy)!, (carVelocity?.dx)!) - (car.zRotation)

				let lateralMomentum = sin(driftDiff) * carVelocityMag * (car.physicsBody?.mass)! * CGFloat(1.1)
				
				let normalZRotation = CGFloat(M_PI/2.0)

				let lateralMomentumVecAngle = (car.zRotation) - normalZRotation
				
				let lateralMomentumVec = CGVector(dx: cos(lateralMomentumVecAngle) * lateralMomentum,
												  dy: sin(lateralMomentumVecAngle) * lateralMomentum)
				car.physicsBody?.applyImpulse(lateralMomentumVec)
				
				
			

				// Portal walls
				if (car.steering) {
					car.steerTowards(direction: self.joyStick.steeringAngle)
				}
				
				// Mirror boundaries
				if car.position.x > (self.frame.width + car.diagonalLength/2.0) {
					car.position.x = 0
				} else if car.position.x < (0 - car.diagonalLength/2.0) {
					car.position.x = self.frame.width
				}
				if car.position.y > (self.frame.height + car.diagonalLength/2.0) {
					car.position.y = 0
				} else if car.position.y < (0 - car.diagonalLength/2.0) {
					car.position.y = self.frame.height
				}
			
			/*
			var sl = "is not"
			var sr = "is not"
			var a = "is not"
			if (car?.steerLeft) {
				sl = "is"
			}
			if (car?.steerRight) {
				sr = "is"
			}
			if (car?.accelerate) {
				a = "is"
			}
			print("car \(sr) steering right, and \(sl) steering left, and \(a) accelerating")
*/
			
			//car.physicsBody?.velocity = CGVectorMake(CGFloat(cos(car?.zRotation)) * car.speed, CGFloat(sin(car?.zRotation)) * car.speed)
			//var carVelocity = sqrt(int(car.physicsBody?.velocity.dx << 1) + int(car.physicsBody?.velocity.dy << 1))
			//let carVelocity = sqrtf(pow(Float((carVelocity.dx)!), 2) + pow(Float((carVelocity.dx)!),2))
			
			
			

			/*
			// Update car rotation
			if (car?.steering) {
				car1.steerTowards(angle: angle)
				car?.physicsBody?.applyTorque(car?.steeringTorque)
				
			}
				
*/
			}
		}

		
		
		
			
			
		self.enumerateChildNodes(withName: "car", using: updateNode)
		
    }
}

