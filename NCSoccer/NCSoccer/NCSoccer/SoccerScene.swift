//
//  SoccerScene.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

// TODO: Clean up code and separate code into orthogonal modules

import SpriteKit
import GameKit

enum GameState {
	case initializing
	case findingHost
	case countingDown
	case started
	case overtime
	case paused
	case ended
}

let TOP_LEFT = 1
let BOTTOM_LEFT = 3
let BOTTOM_RIGHT = 2
let TOP_RIGHT = 4

let COUNTDOWN_START: UInt8 = 5
let MATCH_TIME: UInt16 = 180
let HOST_DELAY_START_TIME = 4

class SoccerScene: SKScene, SKPhysicsContactDelegate, GKMatchDelegate {
	
	var localCar: Car!
	var ball: Ball!
	
	// Controls
	var touchingJoystick: Bool = false
	var joyStickCenter: CGVector!
	var joyStick: Joystick!
	//#if THROTTLE
	var throttle: Throttle!
	//#endif
	
	var camObjects = SKNode()
	var innerCamPadding: CGFloat!
	var outerCamPadding: CGFloat!
	
	var cam = SKCameraNode()
	
	//var network: Network! // TODO: factor Network code into a class
	var match: GKMatch!
	var gameState = GameState.initializing
	var hostID: String?
	
	var hostingMatch: Bool = false
	
	var randomNumbers = [String: UInt32]()
	var localPlayerID: String?
	
	var updateCounter = 0
	
	var countdown321Label = SKLabelNode(fontNamed: gill)
	var countdown321: UInt8 = COUNTDOWN_START
	
	var clockLabel = SKLabelNode(fontNamed: gill)
	var clock: UInt16 = MATCH_TIME
	var scoreLabel = SKLabelNode(fontNamed: gill)
	var score: (UInt8, UInt8) = (0, 0)
	
	var startLabel = SKLabelNode(fontNamed: gill)
	
	var overtime: Bool = false
	var countdown: SKAction!
	
	override init(size: CGSize) {
		super.init(size: size)
		loadField()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func didMove(to view: SKView) {
		
		// Physics
		physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		
		physicsWorld.contactDelegate = self
		
		localPlayerID = GKLocalPlayer.localPlayer().playerID!
		randomNumbers["\(localPlayerID!)"] = arc4random()
		
		clock = 45
		countdown321 = COUNTDOWN_START
		
		localCar = Car()
		self.addChild(localCar)
		localCar.playerID = localPlayerID
		localCar.playerName = GKLocalPlayer.localPlayer().displayName!
		localCar.playerNameLabel.text = localCar.playerName
		localCar.playerNameLabel.name = localPlayerID
		
		ball = Ball()

		// Camera
		cam = SKCameraNode()
		self.camera = cam
		cam.setScale(CAM_SCALE)
		cam.position = CGPoint(x: FIELD_WIDTH/2.0, y: FIELD_HEIGHT/2.0)
		self.addChild(cam)
		
		// Add ball
		let ballSpawnSpot = CGPoint(x: FIELD_WIDTH/2.0, y: FIELD_HEIGHT/2.0)
		ball.position = ballSpawnSpot
		self.addChild(ball)
		
		// joystick
		joyStick = Joystick()
		joyStick.position = CGPoint(x: -frame.midX/2.0, y: -frame.midY/2.0)
		cam.addChild(joyStick)
		
		//#if THROTTLE
		// Throttle
		throttle = Throttle()
		throttle.position = CGPoint(x: frame.midX*(3/4), y: -frame.midY/2.0)
		cam.addChild(throttle)
		//#endif
		
		clockLabel.fontSize = 40
		clockLabel.position = CGPoint(x: 0, y: frame.midY * 0.80)
		clockLabel.color = SKColor.white
		updateClockLabel()
		cam.addChild(clockLabel)
		
		scoreLabel.fontSize = 30
		scoreLabel.color = SKColor.white
		scoreLabel.position = CGPoint(x: 0, y: frame.midY*0.60)
		scoreLabel.text = "\(score.0) - \(score.1)"
		cam.addChild(scoreLabel)
		
		countdown321Label.fontSize = 70
		countdown321Label.position = CGPoint(x: 0, y: frame.midY * 0.25)
		countdown321Label.color = SKColor.white
		countdown321Label.name = "countdown321Label"
		
		let waitOneSec = SKAction.wait(forDuration: 1.000)
		let update = SKAction.run({
			() -> Void in
			if (self.hostingMatch) {
    			if (self.gameState == .overtime) {
            		self.countdown321Label.text = "Overtime!"
    				self.gameState = .countingDown
    			} else if (self.gameState == .countingDown) {
    				if (self.countdown321 > 0) {
        				self.countdown321 -= 1
    				}
    				if (self.countdown321 == 0) {
    					if (self.cam.childNode(withName: "countdown321Label") != nil) {
            				self.countdown321Label.removeFromParent()
    					}
    					self.turnExhuast(on: true)
    					self.gameState = .started
    				}
    			} else {
    				if (self.overtime) {
        					self.clock += 1
    				} else {
    					if self.clock > 0 {
        					self.clock -= 1
    					} else {
    						self.endGame()
    					}
    				}
    			}
			}
		})
		
		countdown = SKAction.sequence([waitOneSec, update])
		
		let wait20ms = SKAction.wait(forDuration: 0.020)
		let send = SKAction.run(sendNetworkMessages)
		let s = SKAction.sequence([wait20ms, send])
		let r = SKAction.repeatForever(s)
		run(r)
		
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
*/
		spawnCars()
		gameState = GameState.findingHost
	}
	
	
	
	// MARK: - Starting the Game
	
	
	func updateCountdown321Label() {
		if (countdown321 <= 3) {
			self.countdown321Label.text = "\(countdown321)"
		} else {
			self.countdown321Label.text = ""
		}
	}
	
	func updateClockLabel() {
		let min = self.clock/60
		let sec = self.clock%60
		var plus = ""
		if (overtime) {
			plus = "+"
		}
		
		if (sec >= 10) {
			self.clockLabel.text = "\(plus)\(min):\(sec)"
		} else {
			self.clockLabel.text = "\(plus)\(min):0\(sec)"
		}
	}
	
	func goal(left: Bool) {
		if (left) {
			score.0 += 1
		} else {
			score.1 += 1
		}
		if (overtime) {
			gameState = .ended
			endGame()
			return
		}
		
		scoreLabel.text = "\(score.0) - \(score.1)"
		resetFieldObjects()
		countdown321 = COUNTDOWN_START
		gameState = .countingDown
		turnExhuast(on: false)
		sendNetworkMessages()
		startCountdown()
	}
	
	func startCountdown() {
		if (cam.childNode(withName: "countdown321Label") == nil) {
    		cam.addChild(countdown321Label)
		}
		countdown321 = COUNTDOWN_START
		run(SKAction.repeatForever(countdown), withKey: "countdown")
	}
	
	func spawnCars() {
		
		let sortedCars = randomNumbers.keys.sorted(by: { $0 > $1 }).flatMap({ ($0, randomNumbers[$0]!) })
		
		let setPosition: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			
			var spawnSpot = CGPoint.zero
			var spawnRotation: CGFloat = 0
			var carTexture = ""
			if let car = node as? Car {
				var sequence: Int = 0
				for (key, _) in sortedCars { // Highest to lowest
					sequence += 1
					if car.playerID == key {
						switch(sequence) {
						case TOP_LEFT:
							spawnSpot = CGPoint(x: FIELD_WIDTH/4.0, y: FIELD_HEIGHT*(3/4))
							spawnRotation = 0
							car.leftTeam = true
							carTexture = "GreenCar"
							break
						case BOTTOM_LEFT:
							spawnSpot = CGPoint(x: FIELD_WIDTH/4.0, y: FIELD_HEIGHT*(1/4))
							spawnRotation = 0
							car.leftTeam = true
							carTexture = "GreenCar"
							break
						case BOTTOM_RIGHT:
							spawnSpot = CGPoint(x: FIELD_WIDTH*(3/4), y: FIELD_HEIGHT*(1/4))
							spawnRotation = CGFloat(M_PI)
							car.leftTeam = false
							carTexture = "OrangeCar"
							break
						case TOP_RIGHT:
							spawnSpot = CGPoint(x: FIELD_WIDTH*(3/4), y: FIELD_HEIGHT*(3/4))
							spawnRotation = CGFloat(M_PI)
							car.leftTeam = false
							carTexture = "OrangeCar"
							break
						default:
							spawnSpot = CGPoint.zero
							spawnRotation = 0
							break
						}
					}
				}
				
				car.exhaust.targetNode = self
				car.exhaust.isHidden = true
				car.position = spawnSpot
				car.zRotation = spawnRotation
				let body = car.physicsBody
				body?.velocity.dx = 0
				body?.velocity.dy = 0
				body?.angularVelocity = 0
				car.setTexture(textureName: carTexture)
				self.updateCarNameLabel(car: car)
			}
		}
		
		self.enumerateChildNodes(withName: "^car$", using: setPosition)
	}
	
	func updateCarNameLabel(car: Car) {
		if (car.playerNameLabel.name != nil) {
			if (self.childNode(withName: car.playerNameLabel.name!) == nil) {
				self.addChild(car.playerNameLabel)
			} else {
				car.playerNameLabel.position = CGPoint(x: car.position.x, y: car.position.y+car.size.width)
			}
		}
	}
	
	func turnExhuast(on: Bool) {
		let exhaust: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			if let car = node as? Car {
					car.exhaust.isHidden = on
			}
		}
		self.enumerateChildNodes(withName: "^car$", using: exhaust)
	}
	
	func endGame() {
		self.isPaused = true
		var gameWon: Bool!
		if (score.0) < (score.1) {
			if (localCar.leftTeam) {
				gameWon = false
			} else {
				gameWon = true
			}
		} else if (score.0) > (score.1) {
			if (localCar.leftTeam) {
				gameWon = true
			} else {
				gameWon = false
			}
		} else {
			/* overtime */
			clock = MATCH_TIME
			countdown321 = COUNTDOWN_START
			self.overtime = true
			self.gameState = .overtime
			resetFieldObjects()
			startCountdown()
			self.isPaused = false
			return
		}
		self.removeAction(forKey: "countdown")
		
		self.gameState = .ended
		sendNetworkMessages()
		let reveal = SKTransition.fade(withDuration: 1.0)
		let endGameScene = EndGameScene(size: self.size, victory: gameWon)
		self.view?.presentScene(endGameScene, transition: reveal)
	}
	
	func resetFieldObjects() {
		ball.position = CGPoint(x: FIELD_WIDTH/2.0, y: FIELD_HEIGHT/2.0)
		ball.physicsBody?.velocity.dx = 0
		ball.physicsBody?.velocity.dy = 0
		ball.physicsBody?.angularVelocity = 0
		
		spawnCars()
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
		var startingPos = fieldOrigin
		//var startingPos = CGPoint(x: (-FIELD_WIDTH/2.0) + (fieldElemLen/2.0), y: (-FIELD_WIDTH/2.0) + (fieldElemLen/2.0))
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
						let westGoal = Goal(spawnPosition: CGPoint(x: startingPos.x-(fieldElemLen*0.9), y: startingPos.y + (fieldElemLen * CGFloat(y))))
						self.addChild(westGoal)
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
						southEastCorner.zRotation -= CGFloat(M_PI/2.0)
						self.addChild(southEastCorner)
					} else if y == yElems/2 {
						let eastGoal = Goal(spawnPosition: CGPoint(x: startingPos.x + (fieldElemLen*0.9), y: startingPos.y + (fieldElemLen * CGFloat(y))))
						eastGoal.zRotation += CGFloat(M_PI)
						self.addChild(eastGoal)
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

	
	/* 	/
	
	/// Animation
	
	Example of adding text to game. Use this to show countdown: 3... 2... 1... START! at beginning of game.

	func startAnimation() {
		let pointsLabel = SKLabelNode(text: "\(amount)")
		pointsLabel.position = killSpot
		pointsLabel.fontColor = UIColor.orange
		pointsLabel.fontName = gillI
		pointsLabel.fontSize = screenSize.width/40.0
		self.addChild(pointsLabel)
		let moveLabelAction = SKAction.move(by: CGVector(dx: 0, dy: screenSize.width/20.0), duration: 1.5)
		let fadeOut = SKAction.fadeOut(withDuration: 1.5)
		let deleteLabelAction = SKAction.run() {
			pointsLabel.removeFromParent()
		}
		
		let fade = SKAction.group([moveLabelAction, fadeOut])
		pointsLabel.run(SKAction.sequence([fade, deleteLabelAction]))
	}
	
	*/
	
	// MARK: - Touch Handling
	
	
	
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		var steering = 0
		for Touch in touches {
			let touch = Touch.location(in: self.cam) // Touches registered relative to camera i.e. center of screen is (0, 0)
			let testNode = self.cam.atPoint(touch) as? SKSpriteNode
			if (testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				localCar.thrustRatio = throttle.moveTo(position: touch.y)
			} else { // Create joystick
				
				// This prevents joystick from popping up right next to throttle
				if hypot(touch.x - throttle.position.x, touch.y - throttle.position.y) > (JOYSTICK_LEASH) {

					
					if (self.cam.childNode(withName: "joystick") == nil) {
						joyStick.position = touch
						self.cam.addChild(joyStick)
					}
					
					let motion = joyStick.steerTowards(position: touch)
					//localCar.steeringMagnitudeRatio = motion.mag
					localCar.steeringAngle = motion.angle
					steering += 1
					
				}
			}
		}
		
		if steering > 0 {
			localCar.steering = true
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		var steering = 0
		for Touch in touches {
			let touch = Touch.location(in: self.cam)
			
			let testNode = self.cam.atPoint(touch) as? SKSpriteNode
			if (testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				//#if THROTTLE
				localCar.thrustRatio = throttle.moveTo(position: touch.y)
				//#endif
			} else {
				
				

				//#if THROTTLE
				// This prevents unexpected behaviour when throttle thumb leaves throttle area
				if hypot(touch.x - joyStick.position.x, touch.y - joyStick.position.y) < (joyStick.stickLeash * 3.0) {
					
					if (self.cam.childNode(withName: "joystick") == nil) {
						joyStick.position = touch
						self.cam.addChild(joyStick)
					}
					
					let motion = joyStick.steerTowards(position: touch)
					localCar.steeringAngle = motion.angle
					steering += 1
					
				}
				//#endif
				
				/*
				let motion = joyStick.steerTowards(position: touch)
				localCar.steeringMagnitudeRatio = motion.mag
				localCar.steeringAngle = motion.angle
				steering += 1

				*/
			}
		}
		
			
		if steering > 0 {
			localCar.steering = true
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for Touch in touches {
			let touch = Touch.location(in: self.cam)
			let testNode = self.cam.atPoint(touch) as? SKSpriteNode
			if !(testNode?.name == "throttlebase" || testNode?.name == "throttle") {
				if (self.cam.childNode(withName: "joystick") != nil) {
					// This prevents throttle thumb from removing joystick when touch ends just outside of throttle
					if hypot(touch.x - throttle.position.x, touch.y - throttle.position.y) > (JOYSTICK_LEASH) {
						self.joyStick.removeFromParent()
						localCar.steeringMagnitudeRatio = 0
						localCar.steeringAngle = 0
						localCar.steering = false
						//localCar.physicsBody?.angularVelocity = 0
					}
				}
			}
		}
	}
	
	// MARK: - Physics Handling
	func didBegin(_ contact: SKPhysicsContact) {
		if ((contact.bodyA.categoryBitMask & contact.bodyB.categoryBitMask) & (PhysicsCategory.Car) == PhysicsCategory.Car) {
			if let carA = contact.bodyA.node as? Car {
				carA.collided = true
			}
			if let carB = contact.bodyB.node as? Car {
				carB.collided = true
			}
		}
		
		// Nudge car away from wall
//		if ((contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) == PhysicsCategory.Car | PhysicsCategory.Boards) {
//			var car: Car!
//			if let carA = contact.bodyA.node as? Car {
//				car = carA
//			}
//			if let carB = contact.bodyB.node as? Car {
//				car = carB
//			}
//			
//			if car != nil {
//				if (car.physicsBody?.isResting)! {
//				car.physicsBody?.applyImpulse(contact.contactNormal)
//				}
//			} else {
//				print("car collided with wall but was unable to be retrieved in didBegin() function")
//			}
//		}
	}
	
	
	
	
	// MARK: - Frame Cycle
    override func update(_ currentTime: TimeInterval) {
		
		if (self.gameState == .countingDown) {
    		if (cam.childNode(withName: "countdown321Label") == nil) {
        		cam.addChild(countdown321Label)
    		}
			self.updateCountdown321Label()
		}
		
		if (self.gameState != .started) {
			return
		}
		
		self.updateClockLabel()
		if (ball.position.x > (FIELD_WIDTH)) {
			goal(left: true)
		} else if (ball.position.x < 0) {
			goal(left: false)
		}
		
		let updateCar: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
			(node, NilLiteralConvertible) -> Void in
			if let car = node as? Car {

				
				self.updateCarNameLabel(car: car)
				
				let carVelocity = car.physicsBody?.velocity
				let carVelocityMag = hypot((carVelocity?.dx)!, (carVelocity?.dy)!)

				if (car.steering) {
					car.steerTowards(direction: car.steeringAngle)
				} 
				
				let massMultiplier: CGFloat = 2.5
				let carMass = (car.physicsBody?.mass)! * massMultiplier
				//#if THROTTLE
				let thrustRatio = car.thrustRatio
				let force = CGVector(dx: (CGFloat(cos(car.zRotation)) * thrustRatio * carMass),
									 dy: (CGFloat(sin(car.zRotation)) * thrustRatio * carMass))
				/*#else
				let force = CGVector(dx: (CGFloat(cos(car.zRotation)) * car.steeringMagnitudeRatio * carMass),
									 dy: (CGFloat(sin(car.zRotation)) * car.steeringMagnitudeRatio * carMass))
				#endif */
				
				if (carVelocityMag < (car.MAXCARSPEED)) {
					car.physicsBody?.applyImpulse(force)
				}
				
				if car.childNode(withName: "exhaust") == nil {
					car.addChild(car.exhaust)
				}
				
				if (thrustRatio > 0.2) {
					car.exhaust.particleBirthRate = 130 * thrustRatio
				} else {
					car.exhaust.particleBirthRate = 0
				}
				
				
				if (car.collided) {
					car.collisionCoolDown = true
					car.collided = false
					car.collideTime = 0
				}
				
				
				if (car.collisionCoolDown) {
					car.collideTime += 1
					if (car.collideTime > car.driftTime) {
						car.collisionCoolDown = false
						car.collideTime = 0
					}
				} else {
					//// Converts spaceship movement to car movement by offsetting lateral velocity
					let driftDiff = atan2((carVelocity?.dy)!, (carVelocity?.dx)!) - (car.zRotation)
					let multiplier: CGFloat = 1.1
					let lateralMomentum = sin(driftDiff) * carVelocityMag * (car.physicsBody?.mass)! * multiplier
					let normalZRotation = CGFloat(M_PI/2.0)
					let lateralMomentumVecAngle = (car.zRotation) - normalZRotation
					let lateralMomentumVec = CGVector(dx: cos(lateralMomentumVecAngle) * lateralMomentum,
													  dy: sin(lateralMomentumVecAngle) * lateralMomentum)
					car.physicsBody?.applyImpulse(lateralMomentumVec)
				}
				
				// Nudge car away from boards if stuck
//				let carContacts = car.physicsBody?.allContactedBodies()
//				if carContacts != nil {
//					var contacts = 0
//					for body in carContacts! {
//						if body.node?.name == "(^corner$|^edge$|^goal$)" {
//							contacts += 1
//						}
//						if contacts > 0 {
//							if (car.physicsBody?.isResting)! {
//							let centeringVector = CGVector(dx: (FIELD_WIDTH - car.position.x)/(FIELD_WIDTH) * 2.0, dy: (FIELD_HEIGHT - car.position.y)/(FIELD_HEIGHT) * 2.0)
//							car.physicsBody?.applyImpulse(centeringVector)
//							}
//						}
//					}
//				}
				
				
				
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
			xSum += (node?.position.x)!
			ySum += (node?.position.y)!
			objects += 1
		}
		
		self.enumerateChildNodes(withName: "(^car$|^ball$)", using: sumCamObjectPositions)
		let CAM_POS = CGPoint(x: xSum/objects, y: ySum/objects)
		cam.position = CAM_POS
		
	}
	
	
	
	// MARK: - Network
/*
	let queue = DispatchQueue(label: "com.soccer.network")
	
	queue.async {
	
		sendNetworkMessages()
	
	}
*/
/*
	// Move to a background thread to do some long running work
	DispatchQueue.global(attributes: .qosUserInitiated).async {
	let image = self.loadOrGenerateAnImage()
	// Bounce back to the main thread to update the UI
	DispatchQueue.main.async {
	self.imageView.image = image
	}
	}
	*/
	func sendNetworkMessages() {
		/*
		guard (buffer != nil) else {
			return
		}
		*/
		
		if (hostingMatch) {
			var updateGameStateMessage = UpdateGameStateMessage()
			updateGameStateMessage.messageType = .updateGameState
			updateGameStateMessage.gameState = gameState
			updateGameStateMessage.hostClock = clock
			updateGameStateMessage.hostCountdown321 = countdown321
			updateGameStateMessage.hostScoreLeftTeam = score.0
			updateGameStateMessage.hostScoreRightTeam = score.1
			let UGSMbuffer = UnsafeBufferPointer(start: &updateGameStateMessage, count: 1)
			var UGSMdata = Data()
			UGSMdata.append(UGSMbuffer)
			
			do {
				try self.match.sendData(toAllPlayers: UGSMdata, with: .reliable)
			} catch {
				print("Unable to send match start message -host")
			}
		}
		
		switch (gameState) {
		case .initializing:
			break
		case .findingHost:
			
			var randomNumberMessage = RandomNumberMessage()
			let randomInteger = randomNumbers["\(localPlayerID!)"]
			randomNumberMessage.randomNumber = randomInteger!

			let buffer = UnsafeBufferPointer(start: &randomNumberMessage, count: 1)
			var data = Data()
			data.append(buffer)
			do {
				try self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.reliable)
			} catch {
				print("sendData() failed - sending local randomNumberMessage")
			}
			
//			
//			if (hostingMatch) {
//				var hostFoundMessage = MessageFromHost()
//				let buffer = UnsafeBufferPointer(start: &hostFoundMessage, count: 1)
//				var data = Data()
//				data.append(buffer)
//				do {
//					try self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
//				} catch {
//					print("sendData() failed")
//				}
//			}
//
//			
//			if (player?.playerID == GKLocalPlayer.localPlayer().playerID) {
//				var hostFoundMessage = (messageType: MessageType.hostIdentifier, hostID: player?.playerID)
//				let buffer = UnsafeBufferPointer(start: &hostFoundMessage, count: 1)
//			} else {
//				
//			}
//			
//			
//			var data = Data()
//			data.append(buffer)
//			self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
//			
//		})

		
			break
		case .countingDown:
			
//			if (hostingMatch) {
//    			var countdown321UpdateMessage = Countdown321UpdateMessage()
//    			countdown321UpdateMessage.hostCountdown321 = countdown321
//    			let C321UMbuffer = UnsafeBufferPointer(start: &countdown321UpdateMessage, count: 1)
//    			var C321UMdata = Data()
//    			C321UMdata.append(C321UMbuffer)
//    			do {
//    				try self.match.sendData(toAllPlayers: C321UMdata, with: .unreliable)
//    			} catch {
//    				print("sendData() failed - gameClockUpdateMessage")
//    			}
//			}

			
			break
		case .started:
			
		
			if (hostingMatch) {
				
//    			var gameClockUpdateMessage = GameClockUpdateMessage()
//    			gameClockUpdateMessage.hostClock = clock
//    			let GCUMbuffer = UnsafeBufferPointer(start: &gameClockUpdateMessage, count: 1)
//    			var GCUMdata = Data()
//    			GCUMdata.append(GCUMbuffer)
//    			do {
//    				try self.match.sendData(toAllPlayers: GCUMdata, with: .unreliable)
//    			} catch {
//    				print("sendData() failed - gameClockUpdateMessage")
//    			}
				
				var ballUpdateMessage = BallUpdateMessage()
				ballUpdateMessage.messageType = .ballUpdateMessage
				ballUpdateMessage.positionX = package(data: ball.position.x, conversion: positionConversion)
				ballUpdateMessage.positionY = package(data: ball.position.y, conversion: positionConversion)
				ballUpdateMessage.velocityX = package(data: (ball.physicsBody?.velocity.dx)!, conversion: positionConversion)
				ballUpdateMessage.velocityY = package(data: (ball.physicsBody?.velocity.dy)!, conversion: positionConversion)
				ballUpdateMessage.angularVelocity = package(data: (ball.physicsBody?.angularVelocity)!, conversion: generalConversion)
				let BUMbuffer = UnsafeBufferPointer(start: &ballUpdateMessage, count: 1)
				var BUMdata = Data()
				BUMdata.append(BUMbuffer)
				
				do {
					try self.match.sendData(toAllPlayers: BUMdata, with: .unreliable)
				} catch {
					print("sendData() failed - ballUpdateMessage")
				}
				
				
				
				let sendCarUpdates: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
					(node, NilLiteralConvertible) -> Void in
					if let car = node as? Car {
						var carUpdateMessage = CarUpdateMessage()
						carUpdateMessage.messageType = .carUpdateMessage
						let intID = integerFrom(str: car.playerID)!
						carUpdateMessage.lower32PlayerID = lowerU32(int: intID)
						carUpdateMessage.upper32PlayerID = upperU32(int: intID)
						carUpdateMessage.positionX = package(data: car.position.x, conversion: positionConversion)
						carUpdateMessage.positionY = package(data: car.position.y, conversion: positionConversion)
						carUpdateMessage.velocityX = package(data: (car.physicsBody?.velocity.dx)!, conversion: positionConversion)
						carUpdateMessage.velocityY = package(data: (car.physicsBody?.velocity.dy)!, conversion: positionConversion)
						carUpdateMessage.zRotation = package(data: car.zRotation, conversion: generalConversion)
						carUpdateMessage.angularVelocity = package(data: (car.physicsBody?.angularVelocity)!, conversion: generalConversion)
						let CUMbuffer = UnsafeBufferPointer(start: &carUpdateMessage, count: 1)
						var CUMdata = Data()
						CUMdata.append(CUMbuffer)
						
						do {
							try self.match.sendData(toAllPlayers: CUMdata, with: .unreliable)
						} catch {
							print("sendData() failed - sending ball and car update messages")
						}
					}
				}
				
				self.enumerateChildNodes(withName: "^car$", using: sendCarUpdates)
			
			} else {
				
				var controlInputMessage = ControlInputMessage()
				controlInputMessage.messageType = .controlInputMessage
				//controlInputMessage.steeringMagnitudeRatio = package(data: localCar.steeringMagnitudeRatio, conversion: generalConversion)
				controlInputMessage.thrustRatio = package(data: localCar.thrustRatio, conversion: generalConversion)
				controlInputMessage.steeringAngle = package(data: localCar.steeringAngle, conversion: generalConversion)
				controlInputMessage.steering = localCar.steering
				let CIMbuffer = UnsafeBufferPointer(start: &controlInputMessage, count: 1)
				var data = Data()
				data.append(CIMbuffer)
				
				do {
					try self.match.sendData(toAllPlayers: data, with: GKMatchSendDataMode.unreliable)
					//try self.match.send(data, to: [self.match.players.filter{ $0.playerID == self.hostID }.first!], dataMode: .unreliable)
				} catch {
					print("sendData() failed - sending control messages")
				}
				
				
			}
			
			
			
				
			break
		case .paused:
			break
		case .ended:
			break
		default:
			break
		}
	}
	
	
	
	func receiveMessage(data: Data, forRecipient recipient: GKPlayer? = nil, fromRemotePlayer sender: GKPlayer) {
		
		if (.initializing == gameState) {
			return
		}
			
		var messageType = MessageType.invalid
		let messageTypeBuffer = UnsafeMutableBufferPointer(start: &messageType, count: 1)
		let _ = data.copyBytes(to: messageTypeBuffer)
		
		var shouldEndGame = false
		if (messageType == .updateGameState) {
			var updateGameStateMessage = UpdateGameStateMessage()
			let UGSMbuffer = UnsafeMutableBufferPointer(start: &updateGameStateMessage, count: 1)
			let _ = data.copyBytes(to: UGSMbuffer)
			
			/* Call game state transition functions */
			switch(gameState) {
			case .findingHost:
				if (updateGameStateMessage.gameState == .countingDown) {
					turnExhuast(on: false)
					resetFieldObjects()
					spawnCars()
					//startCountdown()
					//self.removeAction(forKey: ^)
				}
				break
			case .countingDown:
				
				if (updateGameStateMessage.gameState == .started) {
					turnExhuast(on: true)
					if (cam.childNode(withName: "countdown321Label") != nil) {
        				self.countdown321Label.removeFromParent()
					}
				}
				break
			case .started:
				if (updateGameStateMessage.gameState == .overtime) {
					turnExhuast(on: false)
					resetFieldObjects()
					overtime = true
				} else if (updateGameStateMessage.gameState == .ended) {
					shouldEndGame = true
				}
			default:
				break
			}
			
			if ((updateGameStateMessage.gameState == .countingDown) && (gameState != .countingDown)) {
				resetFieldObjects()
			}
			
			gameState =		updateGameStateMessage.gameState
			clock =			updateGameStateMessage.hostClock
			countdown321 =	updateGameStateMessage.hostCountdown321
			score.0 =		updateGameStateMessage.hostScoreLeftTeam
			score.1 =		updateGameStateMessage.hostScoreRightTeam
    		scoreLabel.text = "\(score.0) - \(score.1)"
			/* Make sure we receive correct score from host before ending game */
			if (shouldEndGame) {
				endGame()
			}
			return
		}
		
		
		switch (gameState) {
		case .initializing:
			break
		case .findingHost:
			
			
			
			switch(messageType) {
			case .randomNumberMessage:
				// Unravel message
				var randomNumberMessage = RandomNumberMessage()
				let RNMbuffer = UnsafeMutableBufferPointer(start: &randomNumberMessage, count: 1)
				let _ = data.copyBytes(to: RNMbuffer)
				
				// Add random number to player:randomNumber dictionary
				if let id = sender.playerID {
					
					
					if (randomNumbers["\(id)"] == nil) {
						let car = Car()
						car.playerID = id
						car.playerNameLabel.name = id // Used to find label node
						car.playerName = sender.displayName?.replacingOccurrences(of: "\"", with: "")
						car.playerNameLabel.text = car.playerName
						self.addChild(car)
					}
					
					
					if (randomNumbers["\(localPlayerID!)"] == randomNumberMessage.randomNumber) {
						randomNumbers["\(localPlayerID!)"] = arc4random()
					} else {
						randomNumbers["\(id)"] = randomNumberMessage.randomNumber
					}
					
					
				}
				
				// Send out this device's random number (otherwise we might not ever send ours if this executes before sendNetworkMessages())
				var randomNumberMessageRespone = RandomNumberMessage()
				randomNumberMessageRespone.randomNumber = randomNumbers["\(localPlayerID!)"]!
				let responseBuffer = UnsafeBufferPointer(start: &randomNumberMessageRespone, count: 1)
				var responseData = Data()
				responseData.append(responseBuffer)
				do {
					try self.match.sendData(toAllPlayers: responseData, with: GKMatchSendDataMode.reliable)
				} catch {
					print("sendData() failed - responding to other player's random numbers")
				}

				// If all players' random numbers received, then we're ready to start
				if (randomNumbers.count == 2 && randomNumbers.hasUniqueUInt32Members()) {
					hostID = keyMinValue(dict: randomNumbers)
					if (hostID != nil) {

						if (hostID == localPlayerID!) {
							hostingMatch = true
            				gameState = .countingDown
							turnExhuast(on: false)
            				resetFieldObjects()
            				startCountdown()
						}

					} else { // Two devices generated the same random number
						// Choose new random number for this device
						// Reset randomNumbers
						randomNumbers = ["\(localPlayerID!)": arc4random()]
					}
				}
				
				break
				
			default:
				print("recieved message type other than randomNumberMessage while attempting to find host")
				break
			}

		case .countingDown:
//			if (messageType == .countdown321UpdateMessage) {
//				var countdown321UpdateMesage = Countdown321UpdateMessage()
//				let C321UMbuffer = UnsafeMutableBufferPointer(start: &countdown321UpdateMesage, count: 1)
//				let _ = data.copyBytes(to: C321UMbuffer)
//				countdown321 = countdown321UpdateMesage.hostCountdown321
//    			updateCountdown321Label()
//			} else {
//				print("Recieved incorrect message while in countingDown state. Incorrect msg: \(messageType)")
//			}
			break
		case .started:
			
			switch(messageType) {
//			case .gameClockUpdateMessage:
//				var gameClockUpdateMessage = GameClockUpdateMessage()
//				let GCUMbuffer = UnsafeMutableBufferPointer(start: &gameClockUpdateMessage, count: 1)
//				let _ = data.copyBytes(to: GCUMbuffer)
//				clock = gameClockUpdateMessage.hostClock
//				break
			case .controlInputMessage:

				var controlInputMessage = ControlInputMessage()
				let CIMbuffer = UnsafeMutableBufferPointer(start: &controlInputMessage, count: 1)
				let _ = data.copyBytes(to: CIMbuffer)

				let controlCar: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
					(node, NilLiteralConvertible) -> Void in
					if let car = node as? Car {
						if car.playerID == sender.playerID {
							car.thrustRatio = unpackage(data: controlInputMessage.thrustRatio, conversion: generalConversion)
							//car.steeringMagnitudeRatio = unpackage(data: controlInputMessage.steeringMagnitudeRatio, conversion: generalConversion)
							car.steeringAngle = unpackage(data: controlInputMessage.steeringAngle, conversion: generalConversion)
							car.steering = controlInputMessage.steering
						}
					}
				}
				
				self.enumerateChildNodes(withName: "^car$", using: controlCar)
				break
			case .ballUpdateMessage:
				var ballUpdateMessage = BallUpdateMessage()
				let BUMbuffer = UnsafeMutableBufferPointer(start: &ballUpdateMessage, count: 1)
				let _ = data.copyBytes(to: BUMbuffer)
				
				ball.position.x = unpackage(data: ballUpdateMessage.positionX, conversion: positionConversion)
				ball.position.y = unpackage(data: ballUpdateMessage.positionY, conversion: positionConversion)
				ball.physicsBody?.velocity.dx = unpackage(data: ballUpdateMessage.velocityX, conversion: positionConversion)
				ball.physicsBody?.velocity.dy = unpackage(data: ballUpdateMessage.velocityY, conversion: positionConversion)
				ball.physicsBody?.angularVelocity = unpackage(data: ballUpdateMessage.angularVelocity, conversion: generalConversion)

			case .carUpdateMessage:
				
				var carUpdateMessage = CarUpdateMessage()
				let CUMbuffer = UnsafeMutableBufferPointer(start: &carUpdateMessage, count: 1)
				let _ = data.copyBytes(to: CUMbuffer)
				
				let receiveCarUpdate: (SKNode?, UnsafeMutablePointer<ObjCBool>) -> Void = {
					(node, NilLiteralConvertible) -> Void in
					if let car = node as? Car {
						let intID = mergeU64From(lower: carUpdateMessage.lower32PlayerID, upper: carUpdateMessage.upper32PlayerID)
						let id = playerIDFrom(int: intID)
						if (car.playerID! == id) {
							car.position.x = unpackage(data: carUpdateMessage.positionX, conversion: positionConversion)
							car.position.y = unpackage(data: carUpdateMessage.positionY, conversion: positionConversion)
							car.physicsBody?.velocity.dx = unpackage(data: carUpdateMessage.velocityX, conversion: positionConversion)
							car.physicsBody?.velocity.dy = unpackage(data: carUpdateMessage.velocityY, conversion: positionConversion)
							car.physicsBody?.angularVelocity = unpackage(data: carUpdateMessage.angularVelocity, conversion: generalConversion)
							car.zRotation = unpackage(data: carUpdateMessage.zRotation, conversion: generalConversion)
							
						}
					}
				}
				
				self.enumerateChildNodes(withName: "^car$", using: receiveCarUpdate)

//				
//				localCar.position.x = unpackage(data: carUpdateMessage.positionX, conversion: positionConversion)
//				localCar.position.y = unpackage(data: carUpdateMessage.positionY, conversion: positionConversion)
//				localCar.physicsBody?.velocity.dx = unpackage(data: carUpdateMessage.velocityX, conversion: positionConversion)
//				localCar.physicsBody?.velocity.dy = unpackage(data: carUpdateMessage.velocityY, conversion: positionConversion)
				//localCar.physicsBody?.angularVelocity = unpackage(data: carUpdateMessage.angularVelocity, conversion: generalConversion)
				
			default:
				break
			}
			
			break
		case .paused:
			break
		case .ended:
			break
		default:
			print("Received message while game started that isn't relevant: \(messageType)")
			break
		}
	}
	
	//MARK: GKMatchDelegate Methods
	func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
		if (self.match != match) { return }
		
		switch (state) {
		case GKPlayerConnectionState.stateConnected:
			// handle new player connection
			print("Player, \(player.alias) connected")
			break
			
		case GKPlayerConnectionState.stateDisconnected:
			print("Player disconnected!")
			break
			
		case GKPlayerConnectionState.stateUnknown:
			print("Player connection state unknown")
			break
			
		}
		
	}
	
	func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
		if (self.match != match) { return }
		receiveMessage(data: data, forRecipient: recipient, fromRemotePlayer: player)
		//print("received data from \(player.alias) for \(recipient.alias)")
	}
	
	func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
		if (self.match != match) { return }
		receiveMessage(data: data, fromRemotePlayer: player)
		//print("recieved data from \(player.alias)")
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
