//
//  Field.swift
//  NCSoccer
//
//  Created by Nathan Slager on 11/7/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//


import SpriteKit


let FIELD_SCALE:		CGFloat = 2.0
let FIELD_HEIGHT:		CGFloat = 1000 * FIELD_SCALE
let FIELD_WIDTH:		CGFloat = 1600 * FIELD_SCALE
let VERT_FIELD_ELEMS:	CGFloat = 5
let HORIZ_FIELD_ELEMS:	CGFloat = 8

// fieldElemSize should be square (e.g. width = height)
let fieldElemSize = CGSize(width: FIELD_WIDTH/HORIZ_FIELD_ELEMS, height: FIELD_HEIGHT/VERT_FIELD_ELEMS)
let cornerTexture = SKTexture(imageNamed: "corner2")
let edgeTexture = SKTexture(imageNamed: "edge2")
let goalTexture = SKTexture(imageNamed: "goal")

class Field: PhysicalObject {
	
	
	override init(texture: SKTexture!, color: UIColor, size: CGSize) {
		super.init(texture: texture, color: UIColor.clear, size: size)
		self.name = "physicalObject"
		
		// By default, physics objects collide with everything
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}


class Corner: Field {


	init(spawnPosition: CGPoint) {
		
		
		super.init(texture: cornerTexture, color: UIColor.clear, size: fieldElemSize)
		
		self.position = spawnPosition
		self.name = "corner"
		
		let path = UIBezierPath(arcCenter: CGPoint(x: -fieldElemSize.width/2.0, y: -fieldElemSize.height/2.0),
			radius: fieldElemSize.width * 0.9, startAngle: 0, endAngle: CGFloat(M_PI/2.0), clockwise: true)

		physicsBody = SKPhysicsBody(edgeChainFrom: path.cgPath)
		physicsBody?.isDynamic = false
		
		
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

class Edge: Field {
	
	

	init(spawnPosition: CGPoint) {
		
		super.init(texture: edgeTexture, color: UIColor.clear, size: fieldElemSize)
		self.name = "edge"
		self.position = spawnPosition
		
		self.physicsBody = SKPhysicsBody(texture: edgeTexture, alphaThreshold: 0.5, size: fieldElemSize)
		physicsBody?.isDynamic = false

		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

class Goal: Field {
	
	
	init(spawnPosition: CGPoint) {
		
		super.init(texture: goalTexture, color: UIColor.clear, size: fieldElemSize)
		self.name = "goal"
		self.position = spawnPosition
		
		self.physicsBody = SKPhysicsBody(texture: goalTexture, alphaThreshold: 0.5, size: fieldElemSize)
		physicsBody?.isDynamic = false

		
	}
	

	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
