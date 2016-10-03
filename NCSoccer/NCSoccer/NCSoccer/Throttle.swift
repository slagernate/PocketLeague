//
//  Throttle.swift
//  NCSoccer
//
//  Created by Nathan Slager on 10/1/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit



class Throttle: SKSpriteNode {

	var MAX_THROTTLE_POS: CGFloat!
	var MIN_THROTTLE_POS: CGFloat!
	
	var throttle: SKSpriteNode
	
	init () {
		
		// Initialization
		let throttleTexture = SKTexture(imageNamed: "throttle.png")
		let throttleSize = CGSize(width: screenSize.height/3.0, height: screenSize.height/6.0)
		let throttleBaseTexture = SKTexture(imageNamed: "throttle_base")
		throttle = SKSpriteNode(texture: throttleTexture, color: UIColor.clear, size: throttleSize)
		
		
		let throttleBaseSize = CGSize(width: screenSize.height/3.0, height: screenSize.height/3.0)
		super.init(texture: throttleBaseTexture, color: UIColor.clear, size: throttleBaseSize)
		
		
		// Define max and min for throttle position based on screen size
		MAX_THROTTLE_POS = throttleBaseSize.height * (34.2/138.0)
		MIN_THROTTLE_POS = throttleBaseSize.height * (-20.1/138.0)

		
		// Setup
		throttle.zPosition = self.zPosition + 2
		throttle.position = CGPoint(x: 0, y: MAX_THROTTLE_POS)
		self.addChild(throttle)

		
		self.name = "throttlebase"
		throttle.name = "throttle"
		
	}
	
	
	func moveTo(position: CGFloat) {
		
		var newpos = position - self.position.y
		if newpos > MAX_THROTTLE_POS {
			newpos = MAX_THROTTLE_POS
		}
		if newpos < MIN_THROTTLE_POS {
			newpos = MIN_THROTTLE_POS
		}
		
		throttle.position.y = newpos
	}
	
	func thrustRatio() -> CGFloat {
		// Return a ratio of throttle thrust to max throttle thrust
		// Note: Subtracted MIN_THROTTLE_POS to keep the ratio positive (MIN_THROTTLE_POS is negative)
		return (throttle.position.y - MIN_THROTTLE_POS) / (MAX_THROTTLE_POS - MIN_THROTTLE_POS)
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

