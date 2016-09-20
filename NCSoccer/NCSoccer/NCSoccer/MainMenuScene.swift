//
//  MainMenuView.swift
//  Champ Archer
//
//  Created by Nathan Slager on 8/24/15.
//  Copyright (c) 2015 nathanslager. All rights reserved.
//

import SpriteKit


class MainMenuScene: SKScene {
	
	var playLabel: SKLabelNode!
	var howtoLabel: SKLabelNode!
	var adjustedSize: CGFloat!
	
	// Preloaded Sound
	//var playMenuSound: SKAction!
	
	override init(size: CGSize) {
		
		super.init(size: size)
		
		//showAds()
		
		// Load sound
		//playMenuSound = SKAction.playSoundFileNamed("menu.mp3", waitForCompletion: true)

		adjustedSize = CGFloat((screenSize.width + screenSize.height)/2.0)
		
		backgroundColor = UIColor.blackColor()
		
		// Add a "champion archer title"
		let titleLabel = SKLabelNode(fontNamed: gill)
		titleLabel.text = "NC Soccer"
		titleLabel.fontSize = screenSize.width/10
		titleLabel.fontColor = UIColor.whiteColor()
		titleLabel.position = CGPoint(x: size.width/2, y: size.height*3/4)
		addChild(titleLabel)
		
		// Add a play label/button
		playLabel = SKLabelNode(fontNamed: gill)
		playLabel.text = "Play"
		playLabel.fontSize = screenSize.width/14
		playLabel.fontColor = UIColor.whiteColor()
		playLabel.position = CGPoint(x: size.width/2, y: size.height*1/2)
		addChild(playLabel)
		
		// Slap an skspitenode (button) on top of the play label
		let playNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: size.width/8, height: size.height/8.0))
		playNode.position = CGPoint(x: 0, y: screenSize.height/27)
		playNode.name = "playButton"
		playLabel.addChild(playNode)
		
		// Add a how-to label/button
		howtoLabel = SKLabelNode(fontNamed: gill)
		howtoLabel.text = "How To Play"
		howtoLabel.fontSize = screenSize.width/14
		howtoLabel.fontColor = UIColor.whiteColor()
		howtoLabel.position = CGPoint(x: size.width/2, y: size.height*1/4)
		addChild(howtoLabel)
		
		// Slap an skspitenode (button) on top of the howto label
		let howNode = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: size.width*4/10, height: size.height/8.0))
		howNode.position = CGPoint(x: 0, y: screenSize.height/27)
		howNode.name = "howTo"
		howtoLabel.addChild(howNode)
		
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for Touch in touches {
			if self.nodeAtPoint(Touch.locationInNode(self)) is SKSpriteNode {
				let testNode = self.nodeAtPoint(Touch.locationInNode(self)) as! SKSpriteNode
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
		NSNotificationCenter.defaultCenter().postNotificationName("showBanner", object: nil)
	}
	
	func hideAds() {
		NSNotificationCenter.defaultCenter().postNotificationName("hideBanner", object: nil)
	}
	
	override func update(currentTime: NSTimeInterval) {
		NSNotificationCenter.defaultCenter().postNotificationName("checkBanner", object: nil)
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for Touch in touches {
			if self.nodeAtPoint(Touch.locationInNode(self)) is SKSpriteNode {
				let testNode = self.nodeAtPoint(Touch.locationInNode(self)) as! SKSpriteNode
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
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for Touch in touches {
			if self.nodeAtPoint(Touch.locationInNode(self)) is SKSpriteNode {
				let testNode = self.nodeAtPoint(Touch.locationInNode(self)) as! SKSpriteNode
				if testNode.name! == "playButton" {
					let skView = self.view as SKView!
					let scene = SoccerScene(size: size)
					//hideAds()
					let pushInDirection = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 0.4)
					skView.presentScene(scene, transition:  pushInDirection)
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
}

	

	
	
	
	
	
	

