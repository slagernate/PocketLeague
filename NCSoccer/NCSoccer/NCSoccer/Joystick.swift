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
	
	// Max distance joystick lever can deviate from base
	var leverLeash: CGFloat!

	init () {
		
		//let joystickTexture = SKTexture(imageNamed: "joyStick")
		//let joystickBaseTexture = SKTexture(imageNamed: "joyStickBase@3000x3000")
		let joystickBaseTexture = SKTexture(imageNamed: "joyStickBase2")
		let joystickBaseSize = CGSize(width: screenSize.height/10.0, height: screenSize.height/10.0)
		super.init(texture: joystickBaseTexture, color: UIColor.clear, size: joystickBaseSize)
		
		// Add lever on top of joystick base
		let joystickTexture = SKTexture(imageNamed: "joyStick@2000x2000")
		let joystickSize = CGSize(width: screenSize.height/8.0, height: screenSize.height/8.0)
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
		let relativePosition = CGPoint(x: position.x - self.position.x, y: position.y - self.position.y)
		let hype = hypot(relativePosition.x, relativePosition.y)
		if ( hype > leverLeash ) {
			var angle = atan(relativePosition.y/relativePosition.x)
			if (relativePosition.x < 0) {
				angle += CGFloat(M_PI)
			}
			lever.position = CGPoint(x: (cos(angle)*leverLeash), y: (sin(angle)*leverLeash))
		} else {
			lever.position = relativePosition
		}
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

