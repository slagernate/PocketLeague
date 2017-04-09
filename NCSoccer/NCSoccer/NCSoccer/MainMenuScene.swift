//
//  MainMenuView.swift
//  Champ Archer
//
//  Created by Nathan Slager on 8/24/15.
//  Copyright (c) 2015 nathanslager. All rights reserved.
//

import SpriteKit
import GameKit

class MainMenuScene: SKScene {
	
	var singlesLabel: SKLabelNode!
	var doublesLabel: SKLabelNode!
	var howtoLabel: SKLabelNode!
	var adjustedSize: CGFloat!
	let gcNotEnabled = SKLabelNode(fontNamed: gill)
	
	// Preloaded Sound
	//var playMenuSound: SKAction!
	
	override init(size: CGSize) {
		
		super.init(size: size)
		
		addObservers()
		
		// Load sound
		//playMenuSound = SKAction.playSoundFileNamed("menu.mp3", waitForCompletion: true)

		adjustedSize = CGFloat((screenSize.width + screenSize.height)/2.0)
		
		backgroundColor = UIColor.white
		
		// Add a title
		let titleLabel = SKLabelNode(fontNamed: gill)
		titleLabel.text = "Pocket League"
		titleLabel.fontSize = screenSize.width/10
		titleLabel.fontColor = UIColor.black
		titleLabel.position = CGPoint(x: size.width/2, y: size.height*3/4)
		addChild(titleLabel)
		
		// Add a find singles match label/button
		singlesLabel = SKLabelNode(fontNamed: gill)
		singlesLabel.text = "Singles Match"
		singlesLabel.fontSize = screenSize.width/14
		singlesLabel.fontColor = UIColor.black
		singlesLabel.position = CGPoint(x: size.width/2, y: size.height*1/2)
		addChild(singlesLabel)
		
		// Add a find doubles match label/button
		doublesLabel = SKLabelNode(fontNamed: gill)
		doublesLabel.text = "Doubles Match"
		doublesLabel.fontSize = screenSize.width/14
		doublesLabel.fontColor = UIColor.black
		doublesLabel.position = CGPoint(x: size.width/2, y: size.height*1/4)
		addChild(doublesLabel)
		
		// Add a "Game center not enabled"
		gcNotEnabled.text = "Game Center not enabled"
		gcNotEnabled.fontSize = screenSize.width/40
		gcNotEnabled.fontColor = UIColor.black
		gcNotEnabled.position = CGPoint(x: size.width/2, y: size.height*3.5/8)
		
		// Slap an skspitenode (button) on top of the play singles label
		let singlesNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width/2, height: size.height/8.0))
		singlesNode.position = CGPoint(x: 0, y: screenSize.height/27)
		singlesNode.name = "singlesButton"
		singlesLabel.addChild(singlesNode)
	
		let doublesNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width/2, height: size.height/8.0))
		doublesNode.position = CGPoint(x: 0, y: screenSize.height/27)
		doublesNode.name = "doublesButton"
		doublesLabel.addChild(doublesNode)
		
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for Touch in touches {
			if self.atPoint(Touch.location(in: self)) is SKSpriteNode {
				let testNode = self.atPoint(Touch.location(in: self)) as! SKSpriteNode
				if testNode.name! == "singlesButton" {
					singlesLabel.alpha = 0.7
				} else {
					singlesLabel.alpha = 1.0
				}
				if testNode.name! == "doublesButton" {
					doublesLabel.alpha = 0.7
				} else {
					doublesLabel.alpha = 1.0
				}
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		var s = 0
		var d = 0
		for Touch in touches {
			if self.atPoint(Touch.location(in: self)) is SKSpriteNode {
				let testNode = self.atPoint(Touch.location(in: self)) as! SKSpriteNode
				if testNode.name! == "singlesButton" {
					s += 1
				}
				if testNode.name! != "doublesButton" {
					d += 1
				}
			}
		}
		
		if (s == 0) {
			singlesLabel.alpha = 1.0
		}
		if (d == 0) {
			doublesLabel.alpha = 1.0
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for Touch in touches {
			if self.atPoint(Touch.location(in: self)) is SKSpriteNode {
				let testNode = self.atPoint(Touch.location(in: self)) as! SKSpriteNode
				if testNode.name! == "singlesButton" {
					NotificationCenter.default.post(name: Notification.Name(rawValue: findMatchNotificationKey), object: nil, userInfo: ["players": 2])
				} else if (testNode.name! == "doublesButton") {
					NotificationCenter.default.post(name: Notification.Name(rawValue: findMatchNotificationKey), object: nil, userInfo: ["players": 4])
				}
			}
		}
	}
	
	func revealGCNotEnabled() {
		self.addChild(gcNotEnabled)
		singlesLabel.alpha = 1.0
	}
	
	func addObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(revealGCNotEnabled), name: NSNotification.Name(rawValue: gcNotEnabledKey), object: nil)
	}
}










