//
//  SoccerScene.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

import SpriteKit
import GameKit

enum GameState {
	case findingHost
	case hostFound
	case readyToStart
	case started
	case paused
	case ended
}

class SoccerScene: SKScene, SKPhysicsContactDelegate, GKMatchDelegate {
	
	var car1: Car!
	var ball: Ball!
	
	// Controls
	var touchingJoystick: Bool = false
	var joyStickCenter: CGVector!
	var joyStick: Joystick!
	#if THROTTLE
	var throttle: Throttle!
	#endif
	
	var cam: SKCameraNode!
	var camObjects = SKNode()
	var innerCamPadding: CGFloat!
	var outerCamPadding: CGFloat!
	
	//var network: Network! // TODO: factor Network code into a class
	var recieveBuffer: UnsafeMutableBufferPointer<Any>!
	var match: GKMatch!
	var gameState: GameState = GameState.findingHost
	var host: Bool = false
	var hostID: String?
	
	//var hostID: String!
	var hostingMatch: Bool = false
	
	//var randomNumber = arc4random()
	
	var playerDict = [String: UInt32]()
	var localPlayerID: String?
	
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
		
		loadField()
		
		// Corner
		
		//let corner = SKSpriteNode(
		
		
		

		// Camera
		cam = SKCameraNode()
		cam.setScale(CAM_SCALE)
		self.camera = cam
		self.addChild(cam)
		// Cam start pos
		cam.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
		
		// Controls
		
		// joystick
		joyStick = Joystick()
		joyStick.position = CGPoint(x: -frame.midX/2.0, y: -frame.midY/2.0)
		cam.addChild(joyStick)
		
		#if THROTTLE
		// Throttle
		throttle = Throttle()
		throttle.position = CGPoint(x: frame.midX*(3/4), y: -frame.midY/2.0)
		throttle.zPosition += 1
		cam.addChild(throttle)
		#endif
		
		localPlayerID = GKLocalPlayer.localPlayer().playerID
		playerDict["\(localPlayerID!)"] = arc4random()
		
		print(" size of playerDict: \(playerDict.count)")

		
		self.isPaused = true
		/*
		if (gameCenterEnabled) {
			self.match.chooseBestHostingPlayer(completionHandler: {(player: GKPlayer?) -> Void in
				self.hostID = player?.playerID
				if player?.playerID == GKLocalPlayer.localPlayer().playerID {
					self.hostingMatch = true
					self.view?.backgroundColor = UIColor.red
				}
			})
		}
		print("The best player to host the game is: \(self.hostID)")
*/
	}
	
	
	func loadField() {
		// Field
		//let Field = SKSpriteNode(color: SKColor.clear, size: CGSize(width: frame.size.width, height: frame.size.height))
		/*let edgeTexture = SKTexture(imageNamed: "edge2")
		let edge = SKSpriteNode(texture: edgeTexture)
		edge.size = CGSize(width: screenSize.height/2.0, height: screenSize.height/5.0)
		edge.position = CGPoint(x: frame.midX, y: frame.midY)
		edge.physicsBody = SKPhysicsBody(texture: edgeTexture, alphaThreshold: 0.5, size: edge.size)
		edge.physicsBody?.isDynamic = false
		//edge.zRotation += CGFloat(M_PI/2.0)
		*/
		
		
		// Construct field
		let fieldElemLen = fieldElemSize.width
		//var startingPos = CGPoint(x: (-FIELD_WIDTH/2.0) + (fieldElemLen/2.0), y: (-FIELD_WIDTH/2.0) + (fieldElemLen/2.0))
		var startingPos = CGPoint.zero
		let xElems = UInt(HORIZ_FIELD_ELEMS-1)
		let yElems = UInt(VERT_FIELD_ELEMS-1)
		
		for x in 0...xElems {
			for y in 0...yElems {
				
				if x == 0 { // Western boundaries
					if y == 0 {
						let southWestCorner = Corner(spawnPosition: startingPos)
						southWestCorner.zRotation += CGFloat(M_PI)
						self.addChild(southWestCorner)
					} else if y == yElems/2 {
						//let westGoal = Goal(spawnPosition: CGPoint(x: startingPos.x, y: startingPos.y + (fieldElemLen * CGFloat(y))))
						//self.addChild(westGoal)
					} else if y == yElems {
						let northWestCorner = Corner(spawnPosition: CGPoint(x: startingPos.x, y: startingPos.y + (fieldElemLen * CGFloat(y))))
						northWestCorner.zRotation += CGFloat(M_PI/2.0)
						self.addChild(northWestCorner)
					} else {
						let westEdge = Edge(spawnPosition: CGPoint(x: startingPos.x, y: startingPos.y + (fieldElemLen * CGFloat(y))))
						westEdge.zRotation += CGFloat(M_PI/2.0)
						self.addChild(westEdge)
					}
				} else if x == xElems { // Eastern boundaries
					if y == 0 {
						startingPos.x = startingPos.x + (fieldElemLen * CGFloat(x))
						let southEastCorner = Corner(spawnPosition: startingPos)
						southEastCorner.zRotation -= CGFloat(M_PI * 0.5)
						self.addChild(southEastCorner)
					} else if y == yElems/2 {
						//let eastGoal = Goal(spawnPosition: CGPoint(x: startingPos.x, y: startingPos.y + (fieldElemLen * CGFloat(y))))
						//self.addChild(eastGoal)
					} else if y == yElems {
						let northEastCorner = Corner(spawnPosition: CGPoint(x: startingPos.x, y: startingPos.y + (fieldElemLen * CGFloat(y))))
						self.addChild(northEastCorner)
					} else {
						let eastEdge = Edge(spawnPosition: CGPoint(x: startingPos.x, y: startingPos.y + (fieldElemLen * CGFloat(y))))
						eastEdge.zRotation -= CGFloat(M_PI/2.0)
						self.addChild(eastEdge)
					}
				} else { // Top and bottom boundaries
					if y == 0 {
						let southEdge = Edge(spawnPosition: CGPoint(x: startingPos.x + (fieldElemLen * CGFloat(x)), y: startingPos.y))
						southEdge.zRotation += CGFloat(M_PI)
						self.addChild(southEdge)
					}  else if y == yElems {
						let northEdge = Edge(spawnPosition: CGPoint(x: startingPos.x + (fieldElemLen * CGFloat(x)), y: startingPos.y + (fieldElemLen * CGFloat(y))))
						self.addChild(northEdge)
					}
				}
				
				
			}
		}
	}

	func startGame() {
		
		
		// Add a car
		let carSpawnSpot = CGPoint(x: 50, y: frame.midY)
		car1 = Car(spawnPosition: carSpawnSpot)
		addChild(car1)
		
		// Add ball
		let ballSpawnSpot = CGPoint(x: frame.midX*1.5, y: frame.midY)
		self.ball = Ball(spawnPosition: ballSpawnSpot)
		addChild(ball)
		
		
	}
	
	// MARK: - Touch Handling
	

	
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
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
				#if THROTTLE
				throttle.moveTo(position: touch.y)
				#endif
			} else {
				
				if (self.cam.childNode(withName: "joystick") == nil) {
					joyStick.position = touch
					self.cam.addChild(joyStick)
				}

				#if THROTTLE
				// This prevents unexpected behaviour when throttle thumb leaves throttle area
				if hypot(touch.x - joyStick.position.x, touch.y - joyStick.position.y) < (joyStick.leverLeash * 12.0) {
					joyStick.steerTowards(position: touch)
				}
				#endif
				
				joyStick.steerTowards(position: touch)
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
	
	// MARK: - Physics Handling
	func didBegin(_ contact: SKPhysicsContact) {
		if ((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) & (PhysicsCategory.Car) == PhysicsCategory.Car) {
			car1.collided = true
		}
	}
	
	func resetBall(pos: CGPoint) {
		ball.position = pos
		ball.physicsBody?.velocity.dx = 0
		ball.physicsBody?.velocity.dy = 0
		ball.physicsBody?.angularVelocity = 0
	}
	
	// MARK: - Frame Cycle
    override func update(_ currentTime: TimeInterval) {
		
		let centerField = CGPoint(x: ((FIELD_WIDTH - fieldElemSize.width/2.0))/2.0,
		                    y: (FIELD_HEIGHT - fieldElemSize.height/2.0)/2.0)
		
		if ball.position.x > (FIELD_WIDTH - fieldElemSize.width/2.0) {
			resetBall(pos: centerField)
		} else if ball.position.x < (-fieldElemSize.width/2.0) {
			resetBall(pos: centerField)
		}
		
		let updateCar: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			if let car = self.car1 {
				let carVelocity = car.physicsBody?.velocity
				let carVelocityMag = hypot((carVelocity?.dx)!, (carVelocity?.dy)!)
				let carMass = (car.physicsBody?.mass)! * CGFloat(4)
				#if THROTTLE
				let force = CGVector(dx: (CGFloat(cos(car.zRotation)) * self.throttle.thrustRatio() * carMass),
				                     dy: (CGFloat(sin(car.zRotation)) * self.throttle.thrustRatio() * carMass))
				#else
				let force = CGVector(dx: (CGFloat(cos(car.zRotation)) * self.joyStick.steeringMagnitudeRatio * carMass),
					                     dy: (CGFloat(sin(car.zRotation)) * self.joyStick.steeringMagnitudeRatio * carMass))
				#endif
				if (carVelocityMag < (car.MAXCARSPEED)) {
					car.physicsBody?.applyImpulse(force)
					
				}
				
				/*
				if (car.collided) {
					car.collided = false
					car.collisionCoolDown = true
					car.collideTime = 1
				}
				else if (car.collisionCoolDown) {
					if (car.collideTime > car.driftTime) {
						car.collisionCoolDown = false
						car.collideTime = 0
					}
					car.collideTime += 1
				} else {
					car.collideTime = 100
				}
				*/

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
		
		checkNetwork()
		
		//// Check if objects are inside camera node

		// Set camera zoom padding
		innerCamPadding = (screenSize.height/2.0) * CAM_SCALE
		outerCamPadding = (screenSize.height/4.0) * CAM_SCALE

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
		
		// The withName parameter here is using regex.
		self.enumerateChildNodes(withName: "(^car$|^ball$)", using: countObjectsOutsideOuterRect)
		if (objectsOutsideOuterRect > 0) {
			CAM_SCALE *= CAM_ZOOM_FACTOR // Zoom out
		} else {
			self.enumerateChildNodes(withName: "(^car$|^ball$)", using: countObjectsOutsideInnerRect)
			if (objectsOutsideInnerRect == 0) {
				CAM_SCALE /= CAM_ZOOM_FACTOR // Zoom in
			}
		}
		
		if (CAM_SCALE < 5.0) {CAM_SCALE = 5.0}
		if (CAM_SCALE > 6.0) {CAM_SCALE = 6.0}
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
			//print("node\(objects) X: \(node?.position.x)")
			xSum += (node?.position.x)!
			ySum += (node?.position.y)!
			objects += 1
		}
		
		self.enumerateChildNodes(withName: "(^car$|^ball$)", using: sumCamObjectPositions)
		let CAM_POS = CGPoint(x: xSum/objects, y: ySum/objects)
		cam.position = CAM_POS
		
	}
	
	
	
	// MARK: - Network

	func checkNetwork() {
		/*
		guard (buffer != nil) else {
			return
		}
		*/
		
		switch (gameState) {
		case .findingHost:
			
			var randomNumberMessage = RandomNumberMessage()
			let randomInteger = playerDict["\(localPlayerID!)"]
			print("sending our random number, \(randomInteger)")
			randomNumberMessage.randomNumber = randomInteger

			let buffer = UnsafeBufferPointer(start: &randomNumberMessage, count: 1)
			var data = Data()
			data.append(buffer)
			do {
				try self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.reliable)
			} catch {
				print("sendData() failed")
			}
			
			/*
			if (hostingMatch) {
				var hostFoundMessage = MessageFromHost()
				let buffer = UnsafeBufferPointer(start: &hostFoundMessage, count: 1)
				var data = Data()
				data.append(buffer)
				do {
					try self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
				} catch {
					print("sendData() failed")
				}
			}
			*/
			/*
			if (player?.playerID == GKLocalPlayer.localPlayer().playerID) {
				var hostFoundMessage = (messageType: MessageType.hostIdentifier, hostID: player?.playerID)
				let buffer = UnsafeBufferPointer(start: &hostFoundMessage, count: 1)
			} else {
				
			}
			
			
			var data = Data()
			data.append(buffer)
			self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
			
		})
		*/
		
			break
		case .hostFound:
			break
		case .readyToStart:
			break
		case .started:
			break
		case .paused:
			break
		case .ended:
			break
			
		}
	} // checkNetwork()
	
	
	
	
	
	
	
	func handleReceivedData(data: Data, forRecipient recipient: GKPlayer? = nil, fromRemotePlayer sender: GKPlayer) {
		
		var messageType = MessageType.invalid
		let messageTypeBuffer = UnsafeMutableBufferPointer(start: &messageType, count: 1)
		let _ = data.copyBytes(to: messageTypeBuffer)
		print("handling \(messageType) data")

		
		switch (gameState) {
		case .findingHost:
			
			
			print("finding host....")
			
			switch(messageType) {
			case .randomNumberMessage:
				print("random number received!")
				// Unravel message
				var randomNumberMessage = RandomNumberMessage()
				let buffer = UnsafeMutableBufferPointer(start: &randomNumberMessage, count: 1)
				let _ = data.copyBytes(to: buffer)
				
				// Add random number to player:randomNumber dictionary
				//print("recvd message from unique player: \(sender.playerID)")
				if let id = sender.playerID {
					if (playerDict["\(id)"] == nil) {
						print("Dict current contents:")
						
						for (key, value) in playerDict {
							print("key: \(key), value: \(value)")
						}
						
						print("adding random number: \(randomNumberMessage.randomNumber) with key: \(id)")
						
						playerDict["\(id)"] = randomNumberMessage.randomNumber
						print(" size of playerDict: \(playerDict.count)")
					}
				}
				
				// Send out our random number (otherwise we might not ever send ours if this executes before checkNetwork())
				var randomNumberMessageRespone = RandomNumberMessage()
				randomNumberMessageRespone.randomNumber = playerDict[localPlayerID!]
				let responseBuffer = UnsafeBufferPointer(start: &randomNumberMessageRespone, count: 1)
				var responseData = Data()
				responseData.append(responseBuffer)
				do {
					try self.match.sendData(toAllPlayers: responseData, with: GKMatchSendDataMode.reliable)
				} catch {
					print("sendData() failed")
				}

				// If all player's random numbers received then we're ready to start
				if (playerDict.count == TOTAL_PLAYERS) {
					hostID = keyMinValue(dict: playerDict)
					if (hostID == localPlayerID) {
						hostingMatch = true
						print("we are hosting")
					}
					print("match started")
					gameState = .started
				}
				
				break
			case .hostAcknowledged:
				print("host acknowledged message received")
				if (hostingMatch) {
					gameState = GameState.started
					print("Game started on host")
				}
				break
			case .hostIdentifier:
				print("host identifier message received")
				hostID = sender.playerID
				var hostAcknowledgedMessage = HostAcknowledgedMessage()
				let buffer = UnsafeBufferPointer(start: &hostAcknowledgedMessage, count: 1)
				var ack = Data()
				ack.append(buffer)
				do {
					try self.match.sendData(toAllPlayers: ack, with: GKMatchSendDataMode.unreliable)
					gameState = GameState.started
				} catch {
					print("Sending ack failed!")
				}
				print("Slave ready!")
			default:
				break
				
			}
			
			/*
			if (hostingMatch) {
				var hostFoundMessage = MessageFromHost()
				let buffer = UnsafeBufferPointer(start: &hostFoundMessage, count: 1)
				var data = Data()
				data.append(buffer)
				do {
					try self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
				} catch {
					print("sendData() failed")
				}
			}
			/*
			if (player?.playerID == GKLocalPlayer.localPlayer().playerID) {
			var hostFoundMessage = (messageType: MessageType.hostIdentifier, hostID: player?.playerID)
			let buffer = UnsafeBufferPointer(start: &hostFoundMessage, count: 1)
			} else {
			
			}
			
			
			var data = Data()
			data.append(buffer)
			self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
			
			})
			*/
*/
		case .hostFound:
			break
		case .readyToStart:
			break
		case .started:
			break
		case .paused:
			break
		case .ended:
			break
		
		}
	}
	
	//MARK: GKMatchDelegate Methods
	func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
		if (self.match != match) { return }
		
		switch (state) {
		case GKPlayerConnectionState.stateConnected:
			// handle new player connection
			print("Player connected")
			
			if ((gameState == GameState.readyToStart) && (match.expectedPlayerCount == 0)) {
				print("Match ready to start")
			}
			break
			
		case GKPlayerConnectionState.stateDisconnected:
			print("Player disconnected!")
			break
			
		case GKPlayerConnectionState.stateUnknown:
			break
			
		}
		
	}
	
	func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
		if (self.match != match) { return }
		handleReceivedData(data: data, forRecipient: recipient, fromRemotePlayer: player)
		//print("received data from \(player.alias) for \(recipient.alias)")
	}
	
	func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
		if (self.match != match) { return }
		handleReceivedData(data: data, fromRemotePlayer: player)
		print("recieved data from \(player)")
	}
	
	func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
		if (self.match != match) { return false }
		
		print("match should reinvite disconnected player: \(player.alias)")
		return false
	}
	
	func match(_ match: GKMatch, didFailWithError error: Error?) {
		if (self.match != match) { return }
		
		print("match failed with error: \(error)")
	}
	
	
	


}


func keyMinValue(dict: [String: UInt32]) -> String? {
	
	// Note that this doesn't accoutn for duplicate minimums
	for (key, value) in dict {
		if value == dict.values.min() {
			return key
		}
	}
	
	return nil
}

