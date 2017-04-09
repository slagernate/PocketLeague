//
//  EndGameScene.swift
//  NCSoccer
//
//  Created by Nathan Slager on 1/22/17.
//  Copyright © 2017 nathanslager. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene {
	
	var delayedExit: SKAction!
	
	init(size: CGSize, victory: Bool) {
		
		super.init(size: size)
		backgroundColor = UIColor.black
		
		let label = SKLabelNode(fontNamed: "Gill Sans Italic")
		if (victory) {
			label.fontColor = SKColor.blue
			label.text = "Victory"
		} else {
			label.fontColor = SKColor.red
			label.text = "Defeat"
		}
		
		label.fontSize = screenSize.width/10
		label.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
		addChild(label)
		
		let wait = SKAction.wait(forDuration: 4.0)
		let exitScene = SKAction.run(goToMainMenu)
		delayedExit = SKAction.sequence([wait, exitScene])
	}
	
	override func didMove(to view: SKView) {
		run(delayedExit)
	}
	
	func goToMainMenu() {
		let menuScene = MainMenuScene(size: screenSize)
		let menuTransition = SKTransition.fade(withDuration: 2.0)
		self.view?.presentScene(menuScene, transition: menuTransition)
	}
		
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
