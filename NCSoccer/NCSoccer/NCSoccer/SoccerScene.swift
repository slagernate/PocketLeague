//
//  SoccerScene.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

import SpriteKit



class SoccerScene: SKScene, SKPhysicsContactDelegate {
	
	var car1: Car! = nil
	
    override func didMoveToView(view: SKView) {
		
		//let screenRect = UIScreen.mainScreen().bounds
		
		// Physics
		physicsWorld.gravity = CGVectorMake(0, 0)
		
		physicsWorld.contactDelegate = self
		
		// Create boundary for field
		//let FieldBoundary = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height)
		let boundaryBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
		//let boundaryBody = SKPhysicsBody(edgeLoopFromRect: screenRect)
		self.physicsBody = boundaryBody
		self.physicsBody?.categoryBitMask = PhysicsCategory.Boards
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Ball | PhysicsCategory.Car
		
		
		// Field
		let Field = SKSpriteNode(color: SKColor.greenColor(), size: CGSize(width: frame.size.width, height: frame.size.height))
		Field.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(Field)
		
		// Add a car
		let carSpawnSpot = CGPoint(x: frame.midX, y: frame.midY)
		car1 = Car(spawnPosition: carSpawnSpot)
		addChild(car1)
		
		
		// Add ball
		let ballSpawnSpot = CGPoint(x: frame.midX*1.5, y: frame.midY)
		let ball = Ball(spawnPosition: ballSpawnSpot)
		addChild(ball)
		
    }
	
	// MARK: - Touch Handling
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
		/* Test code splits up screen to act as controls */
		for Touch in touches {
			if Touch.locationInNode(self).x < frame.midX { // touch on left side of screen
				if Touch.locationInNode(self).x < frame.midX/2.0 { // touch on left quarter of screen // turn left
					car1.steerLeft = true
					car1.steerRight = false
				} else { // Touch on 2nd quarter of screen // turn right
					car1.steerRight = true
					car1.steerLeft = false
				}
			} else { // Touch on right half of screen
				car1.accelerate = true
			}
		}
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		var accelerating = 0
		var turnRight = 0x0
		var turnLeft = 0x0
		for Touch in touches {
			if Touch.locationInNode(self).x < frame.midX { // touch on left side of screen
    			if Touch.locationInNode(self).x < frame.midX/2.0 { // touch on left quarter of screen
					turnLeft |= 0x1
    			} else { // Touch on 2nd quarter of screen
					turnRight |= 0x1
    			}
    		} else { // Touch on right half of screen
				accelerating += 1
    		}
    	}
		
		if (turnLeft ^ turnRight == 0x1) { // If turnLeft and turnRight are different
			if (turnRight == 0) {
    			car1.steerLeft = true
    			car1.steerRight = false
    		} else if (turnLeft == 0) {
    			car1.steerRight = true
    			car1.steerLeft = false
    		}
		} else {
			car1.steerLeft = false
			car1.steerRight = false
		}
		
		if accelerating > 0 {
			car1.accelerate = true
		} else {
			car1.accelerate = false
		}
		
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for Touch in touches {
			if Touch.locationInNode(self).x < frame.midX { // touch on left side of screen
    			if Touch.locationInNode(self).x < frame.midX/2.0 { // touch on left quarter of screen
    				car1.steerLeft = false
    			} else { // Touch on 2nd quarter of screen
    				car1.steerRight = false
    			}
    		} else { // Touch on right half of screen
				car1.accelerate = false
    		}
    	}
		
	}
	
	// MARK: - Frame Cycle
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
		
		// Really Strange syntax. Blocks are confusing but they're needed here for the
		// enumerateChildNodesWithName() function. Essentially a block is a function.
		// What I'm doing here is declaring a function that has parameter types SKNode!
		// and UnsafeMutablePointer<ObjCBool> and return type void. Then I'm setting that
		// equal to an actual function with with specific parameter names. Idk it just works lol
		// Pretty sure this is like a 1 to 1 translation to a C function pointer.
		let updateNode: (SKNode!, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			
			// Update car rotation
			if (self.car1.steerLeft) {
				self.car1.physicsBody?.applyTorque(CGFloat(0.01))
			} else if (self.car1.steerRight) {
				self.car1.physicsBody?.applyTorque(CGFloat(-0.01))
			}
			/*
			var sl = "is not"
			var sr = "is not"
			var a = "is not"
			if (self.car1.steerLeft) {
				sl = "is"
			}
			if (self.car1.steerRight) {
				sr = "is"
			}
			if (self.car1.accelerate) {
				a = "is"
			}
			print("car \(sr) steering right, and \(sl) steering left, and \(a) accelerating")
*/
			
			//car.physicsBody?.velocity = CGVectorMake(CGFloat(cos(self.car1.zRotation)) * car.speed, CGFloat(sin(self.car1.zRotation)) * car.speed)
			//var carVelocity = sqrt(int(car.physicsBody?.velocity.dx << 1) + int(car.physicsBody?.velocity.dy << 1))
			let carVelocity = sqrtf(pow(Float((self.car1.physicsBody?.velocity.dx)!), 2) + pow(Float((self.car1.physicsBody?.velocity.dx)!),2))
			
			if (self.car1.accelerate) {
    			if (carVelocity < 120) {
        			self.car1.physicsBody?.applyImpulse(CGVectorMake(CGFloat(cos(self.car1.zRotation)) * self.car1.speed, CGFloat(sin(self.car1.zRotation)) * self.car1.speed))
    			}
    		}
		}
		
		self.enumerateChildNodesWithName("car", usingBlock: updateNode)
		
    }
}

