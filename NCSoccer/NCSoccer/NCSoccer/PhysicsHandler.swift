//
//  PhysicsHandler.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/31/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
	static let None			: UInt32 = 0x0
	static let All			: UInt32 = UInt32.max
	static let Ball			: UInt32 = 0x1 << 0
	static let Boards		: UInt32 = 0x1 << 1
	static let Car			: UInt32 = 0x1 << 2
}

class PhysicsHandler: NSObject, SKPhysicsContactDelegate {

	override init() {
		
	}
	
	
}