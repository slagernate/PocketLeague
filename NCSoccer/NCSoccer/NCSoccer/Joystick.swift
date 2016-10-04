//
//  Joystick.swift
//  NCSoccer
//
//  Created by Nathan Slager on 9/24/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

class Joystick: SKSpriteNode {
	
	var touching: Bool = false
	var lever: SKSpriteNode!
	var steeringAngle: CGFloat
	
	// Max distance joystick lever can deviate from base
	var leverLeash: CGFloat!

	init () {
		
		// Initialization
		steeringAngle = 0
		
		//let joystickTexture = SKTexture(imageNamed: "joyStick")
		//let joystickBaseTexture = SKTexture(imageNamed: "joyStickBase@3000x3000")
		let joystickBaseTexture = SKTexture(imageNamed: "joyStickBase2")
		let joystickBaseSize = CGSize(width: screenSize.height/7.5, height: screenSize.height/7.5)
		super.init(texture: joystickBaseTexture, color: UIColor.clear, size: joystickBaseSize)
		
		// Add lever on top of joystick base
		let joystickTexture = SKTexture(imageNamed: "joyStick@2000x2000")
		let joystickSize = CGSize(width: screenSize.height/6.0, height: screenSize.height/6.0)
		lever = SKSpriteNode(texture: joystickTexture, color: UIColor.clear, size: joystickSize)
		lever.position = self.position
		// Set lever on top of base
		lever.zPosition = self.zPosition + 1
		self.addChild(lever)
		
		// Set lever leash distance
		leverLeash = lever.size.width/2
		
		self.name = "joystick"

	}
	
	
	func steerTowards(position: CGPoint) {
		// Convert from absolute (soccer field) coordinates to coordinates relative to joystick base
		// E.g. if touch == self.position then lever.position = CGPoint(x: 0, y: 0) 
		// -Child node position is relative to parent node
		//print("input pos x: \(position.x) y: \(position.y)")
		let relativePosition = CGPoint(x: position.x - self.position.x, y: position.y - self.position.y)
		//print("relative pos x: \(relativePosition.x) y: \(relativePosition.y)")
		//print("\(relativePosition.x)")
		let angle = atan2(relativePosition.y, relativePosition.x)
		/*
		if angle < 0 {
			angle += CGFloat(M_PI * 2)
		}
		*/
		let hype = hypot(relativePosition.x, relativePosition.y)
		if ( hype > leverLeash ) {
			lever.position = CGPoint(x: (cos(angle)*leverLeash), y: (sin(angle)*leverLeash))
		} else {
			lever.position = relativePosition
		}
		
		//print("x: \(lever.position.x), y: \(lever.position.y)")
		//print("Steering angle: \(angle)")

		steeringAngle = angle
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

