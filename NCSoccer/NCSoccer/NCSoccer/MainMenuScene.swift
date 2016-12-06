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
	
	var playLabel: SKLabelNode!
	var howtoLabel: SKLabelNode!
	var adjustedSize: CGFloat!
	let gcNotEnabled = SKLabelNode(fontNamed: gill)
	
	// Preloaded Sound
	//var playMenuSound: SKAction!
	
	override init(size: CGSize) {
		
		super.init(size: size)
		
		//showAds()
		
		// Load sound
		//playMenuSound = SKAction.playSoundFileNamed("menu.mp3", waitForCompletion: true)

		adjustedSize = CGFloat((screenSize.width + screenSize.height)/2.0)
		
		backgroundColor = UIColor.white
		
		// Add a title
		let titleLabel = SKLabelNode(fontNamed: gill)
		titleLabel.text = "NC Soccer"
		titleLabel.fontSize = screenSize.width/10
		titleLabel.fontColor = UIColor.black
		titleLabel.position = CGPoint(x: size.width/2, y: size.height*3/4)
		addChild(titleLabel)
		
		// Add a find match label/button
		playLabel = SKLabelNode(fontNamed: gill)
		playLabel.text = "Find Match"
		playLabel.fontSize = screenSize.width/14
		playLabel.fontColor = UIColor.black
		playLabel.position = CGPoint(x: size.width/2, y: size.height*1/2)
		addChild(playLabel)
		
		// Add a "Game center not enabled"
		gcNotEnabled.text = "Game Center not enabled"
		gcNotEnabled.fontSize = screenSize.width/40
		gcNotEnabled.fontColor = UIColor.black
		gcNotEnabled.position = CGPoint(x: size.width/2, y: size.height*3.5/8)
		
		// Slap an skspitenode (button) on top of the play label
		let playNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width/8, height: size.height/8.0))
		playNode.position = CGPoint(x: 0, y: screenSize.height/27)
		playNode.name = "playButton"
		playLabel.addChild(playNode)
		
		// Add a how-to label/button
		howtoLabel = SKLabelNode(fontNamed: gill)
		howtoLabel.text = "How To Play"
		howtoLabel.fontSize = screenSize.width/14
		howtoLabel.fontColor = UIColor.black
		howtoLabel.position = CGPoint(x: size.width/2, y: size.height*1/4)
		addChild(howtoLabel)
		
		// Slap an skspitenode (button) on top of the howto label
		let howNode = SKSpriteNode(color: UIColor.clear, size: CGSize(width: size.width*4/10, height: size.height/8.0))
		howNode.position = CGPoint(x: 0, y: screenSize.height/27)
		howNode.name = "howTo"
		howtoLabel.addChild(howNode)
		
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for Touch in touches {
			if self.atPoint(Touch.location(in: self)) is SKSpriteNode {
				let testNode = self.atPoint(Touch.location(in: self)) as! SKSpriteNode
				if testNode.name! == "playButton" {
					playLabel.alpha = 0.7
					//runAction(playMenuSound)
				} else if testNode.name! == "howTo" {
						howtoLabel.alpha = 0.7
    					//runAction(playMenuSound)
				}
			}
		}
	}
	
	func showAds() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "showBanner"), object: nil)
	}
	
	func hideAds() {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "hideBanner"), object: nil)
	}
	
	override func update(_ currentTime: TimeInterval) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: "checkBanner"), object: nil)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for Touch in touches {
			if self.atPoint(Touch.location(in: self)) is SKSpriteNode {
				let testNode = self.atPoint(Touch.location(in: self)) as! SKSpriteNode
				if testNode.name! != "playButton" {
					playLabel.alpha = 1.0
				}
				if testNode.name! != "howTo" {
					howtoLabel.alpha = 1.0
				}
			} else {
				playLabel.alpha = 1.0
				howtoLabel.alpha = 1.0
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for Touch in touches {
			if self.atPoint(Touch.location(in: self)) is SKSpriteNode {
				let testNode = self.atPoint(Touch.location(in: self)) as! SKSpriteNode
				if testNode.name! == "playButton" {
					NotificationCenter.default.post(name: Notification.Name(rawValue: findMatchNotificationKey), object: nil)

				} /*else if testNode.name! == "howTo" {
					let scene = InstructionsScene(size: self.view!.bounds.size)
					hideAds()
					let downDirection = SKTransitionDirection.Down
					let revealDown = SKTransition.revealWithDirection(downDirection, duration: 0.5)
					skView.presentScene(scene, transition: revealDown)
				}*/
			}
		}
	}
	

	func revealGCNotEnabled() {
		self.addChild(gcNotEnabled)
	}
	
	func addObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(revealGCNotEnabled), name: NSNotification.Name(rawValue: gcNotEnabledKey), object: nil)
	}
}










