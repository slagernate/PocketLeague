//
//  PhysicalObject.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/31/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

class PhysicalObject: SKSpriteNode {

	override init(texture: SKTexture!, color: UIColor, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
		self.name = "physicalObject"
		
		//Physics setup
		physicsBody?.usesPreciseCollisionDetection = true
		physicsBody?.affectedByGravity = false
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

	
