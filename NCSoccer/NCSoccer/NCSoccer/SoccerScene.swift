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
	//var ball: Ball!
	
	// Controls
	var touchingJoystick: Bool = false
	var joyStickCenter: CGVector!
	var joyStick: Joystick!
	var throttle: Throttle!
	
	var cam: SKCameraNode!
	var innerCamPadding: CGFloat!
	var outerCamPadding: CGFloat!
	
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
		
		
		// Field
		let Field = SKSpriteNode(color: SKColor.green, size: CGSize(width: frame.size.width, height: frame.size.height))
		Field.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(Field)
		
		// Corner
		
		//let corner = SKSpriteNode(
		
		
		// Add a car
		let carSpawnSpot = CGPoint(x: 50, y: frame.midY)
		car1 = Car(spawnPosition: carSpawnSpot)
		addChild(car1)
		
		// Add ball
		let ballSpawnSpot = CGPoint(x: frame.midX*1.5, y: frame.midY)
		let ball = Ball(spawnPosition: ballSpawnSpot)
		addChild(ball)

		// Camera
		cam = SKCameraNode()
		cam.setScale(CAM_SCALE)
		self.camera = cam
		self.addChild(cam)
		
		cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
		
		//// Cam children nodes
		// Note: cam node origin is at center of screen, e.g. (0, 0)
		
		// Controls
		
		// joystick
		joyStick = Joystick()
		joyStick.position = CGPoint(x: -frame.midX/2.0, y: -frame.midY/2.0)
		cam.addChild(joyStick)
		
		// Throttle
		throttle = Throttle()
		throttle.position = CGPoint(x: frame.midX*(3/4), y: -frame.midY/2.0)
		throttle.zPosition += 1
		cam.addChild(throttle)
		
		
	} // DidMoveTo
	
	
	// MARK: - Touch Handling
	

	
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
		
		var steering = 0
		for Touch in touches {
			let touch = Touch.location(in: self.cam) // Touches registered relative to camera i.e. center of screen is (0, 0)
			let testNode = self.cam.atPoint(touch) as? SKSpriteNode
			if (testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				//throttle.moveTo(position: touch.y)
			} else { // Create joystick
				if (self.cam.childNode(withName: "joystick") == nil) {
					joyStick.position = touch
					self.cam.addChild(joyStick)
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
			let touch = Touch.location(in: self.cam)
			
			let testNode = self.cam.atPoint(touch) as? SKSpriteNode
			if (testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				throttle.moveTo(position: touch.y)
			} else {
				
				if (self.cam.childNode(withName: "joystick") == nil) {
					joyStick.position = touch
					self.cam.addChild(joyStick)
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
			let touch = Touch.location(in: self.cam)
			let testNode = self.cam.atPoint(touch) as? SKSpriteNode
			if !(testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				if (self.cam.childNode(withName: "joystick") != nil) {
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
		let updateCar: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
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
				
				
				
				if (car.steering) {
					car.steerTowards(direction: self.joyStick.steeringAngle)
				}
				
				// Mirror boundaries
				/*
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
*/
			
				}
		}
		self.enumerateChildNodes(withName: "car", using: updateCar)

    }
	
	override func didFinishUpdate() {
		/* Last method called before scene is rendered */
		
		
		//// Check if objects are inside camera node

		// Set camera zoom padding
		innerCamPadding = (screenSize.height/2.0) * CAM_SCALE
		outerCamPadding = (screenSize.height/8.0) * CAM_SCALE

		// Create inner and outer paddings to cushion camera movement
		let cameraWidth = screenSize.width * CAM_SCALE
		let cameraHeight = screenSize.height * CAM_SCALE

		// Create an inner outer rectangles which are slightly smaller than the camera's size
		
		// Adjust for different coordinate systems between camera and soccerscene by subtracting camera(Width|Height)/2.0
		// Add (inner|outer)CamPadding to position cushion frame position
		// Let me know if you want a visual for what's happening here!
		let innerCamOrigin = CGPoint(x: cam.position.x - cameraWidth/2.0 + innerCamPadding/2.0, y: cam.position.y - cameraHeight/2.0 + innerCamPadding)
		let innerCushionRect = CGRect(
				origin: innerCamOrigin,
				size: CGSize(width: cameraWidth - innerCamPadding, height: cameraHeight - innerCamPadding))
		
		let outerCamOrigin = CGPoint(x: cam.position.x - cameraWidth/2.0 + outerCamPadding/2.0, y: cam.position.y - cameraHeight/2.0 + outerCamPadding/2.0)
		let outerCushionRect = CGRect(
			origin: outerCamOrigin,
			size: CGSize(width: cameraWidth - outerCamPadding, height: cameraHeight - outerCamPadding))
		
		
		var objectsOutsideInnerRect = 0
		let countObjectsOutsideInnerRect: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			if !(node?.frame.intersects(innerCushionRect))! {
				objectsOutsideInnerRect += 1
			}
		}
		
		var objectsOutsideOuterRect = 0
		let countObjectsOutsideOuterRect: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			if !(node?.frame.intersects(outerCushionRect))! {
				objectsOutsideOuterRect += 1
			}
		}
		
		// The withName parameter here is using regex. Google regex if you're unfamiliar.
		self.enumerateChildNodes(withName: "(^car$|^ball$)", using: countObjectsOutsideOuterRect)
		if (objectsOutsideOuterRect > 0) {
			CAM_SCALE *= CAM_ZOOM_FACTOR // Zoom out
		} else {
			self.enumerateChildNodes(withName: "(^car$|^ball$)", using: countObjectsOutsideInnerRect)
			if (objectsOutsideInnerRect == 0) {
				CAM_SCALE /= CAM_ZOOM_FACTOR // Zoom in
			}
		}
		
		if (CAM_SCALE < 1.0) {CAM_SCALE = 1.0}
		if (CAM_SCALE > 4.0) {CAM_SCALE = 4.0}
		cam.setScale(CAM_SCALE)


		/*
		//// See http://imgur.com/7G2W3nu for what "outside|within|inside padding frame" means
		let padding = self.camPadding!
		let paddingMargin = padding/2.0
		
		var objectsOutsidePaddingFrame = 0
		let countObjectsOutsideFrame: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			let pos = node?.position
			if let x = node?.position.x {
				if let y = node?.position.y {
					// Cam object outside padding frame
					if (x < (padding - paddingMargin) ||
						x > (screenSize.width - (padding - paddingMargin)) ||
						y < (padding - paddingMargin) ||
						y > (screenSize.height - (padding - paddingMargin)))
					{
						objectsOutsidePaddingFrame += 1
					}
				}
			}
		}
		
		var objectsWithinPaddingFrame = 0
		let countObjectsWithinFrame: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			if let x = node?.position.x {
				if let y = node?.position.y {
					// Cam object within padding frame (not inside, not outside)
					if (x < (padding + paddingMargin) ||
						x > (screenSize.width - (padding + paddingMargin)) ||
						y < (padding + paddingMargin) ||
						y > (screenSize.height - (padding + paddingMargin)))
					{
						objectsWithinPaddingFrame += 1
					}
				}
			}
		}
		
		self.enumerateChildNodes(withName: "(^car$|^ball$)", using: countObjectsOutsideFrame)
		if (objectsOutsidePaddingFrame > 0) {
			CAM_SCALE *= CAM_ZOOM_FACTOR // Zoom out
		} else {
			self.enumerateChildNodes(withName: "(^car$|^ball$)", using: countObjectsWithinFrame)
			if (0 == objectsWithinPaddingFrame) {
				CAM_SCALE /= CAM_ZOOM_FACTOR // Zoom in
			}
		}
		cam.setScale(CAM_SCALE)
		*/
		
		//// Move camera to centroid of cars and ball
		var xSum: CGFloat = 0
		var ySum: CGFloat = 0
		var objects: CGFloat = 0
		let sumCamObjectPositions: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			// Sum x and y coordinates for centroid calculation
			xSum += (node?.position.x)!
			ySum += (node?.position.y)!
			objects += 1
		}
		self.enumerateChildNodes(withName: "(^car$|^ball$)", using: sumCamObjectPositions)
		let CAM_POS = CGPoint(x: xSum/objects, y: ySum/objects)
		cam.position = CAM_POS
	}
}
