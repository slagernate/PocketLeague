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
	var stick: SKSpriteNode!
	var steeringAngle: CGFloat
	#if THROTTLE
	#else
	var steeringMagnitudeRatio: CGFloat
	#endif
	
	// Max distance joystick stick can deviate from base
	var stickLeash: CGFloat!

	init () {
		
		// Initialization
		#if THROTTLE
		#else
		steeringMagnitudeRatio = 0
		#endif
		steeringAngle = 0
		
		//let joystickTexture = SKTexture(imageNamed: "joyStick")
		//let joystickBaseTexture = SKTexture(imageNamed: "joyStickBase@3000x3000")
		let joystickBaseTexture = SKTexture(imageNamed: "joyStickBase2")
		let joystickBaseSize = CGSize(width: screenSize.height/7.5, height: screenSize.height/7.5)
		super.init(texture: joystickBaseTexture, color: UIColor.clear, size: joystickBaseSize)
		
		// Add stick on top of joystick base
		let joystickTexture = SKTexture(imageNamed: "joyStick@2000x2000")
		let joystickSize = CGSize(width: screenSize.height/6.0, height: screenSize.height/6.0)
		stick = SKSpriteNode(texture: joystickTexture, color: UIColor.clear, size: joystickSize)
		stick.position = self.position
		// Set stick on top of base
		stick.zPosition = self.zPosition + 1
		self.addChild(stick)
		
		// Set stick leash distance
		stickLeash = (stick.size.width/2) * 1.5
		
		self.name = "joystick"
		
	}
	
	
	func steerTowards(position: CGPoint) -> (mag: CGFloat, angle: CGFloat) {
		// Convert from absolute (soccer field) coordinates to coordinates relative to joystick base
		// E.g. if touch == self.position then stick.position = CGPoint(x: 0, y: 0) 
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
		
		var mag: CGFloat! = hypot(relativePosition.x, relativePosition.y)
		if (mag > stickLeash) {
			stick.position = CGPoint(x: (cos(angle)*stickLeash), y: (sin(angle)*stickLeash))
			mag = stickLeash
		} else {
			stick.position = relativePosition
		}
		
		//print(relativePosition.x)
		#if THROTTLE
		#else
		steeringMagnitudeRatio = (mag/stickLeash) * 2.5
		//print(steeringMagnitudeRatio)
		#endif
		
		//print("x: \(stick.position.x), y: \(stick.position.y)")
		//print("Steering angle: \(angle)")

		steeringAngle = angle
		
		return (steeringMagnitudeRatio, angle)
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

