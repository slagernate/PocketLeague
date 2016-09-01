//
//  SoccerSceneViewController.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

import UIKit
import SpriteKit

// Global Screen Size variable
var screenSize: CGSize!

// Global Font Variable
var gill: String = "Gill Sans"

class SoccerSceneViewController: UIViewController {

	// View Size
	var viewSize: CGSize!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		viewSize = view.bounds.size

		screenSize = viewSize
		
		// Switch dimensions if needed
		if viewSize.height < viewSize.width {
			let tempHeight = viewSize.height		// Flip width and height properties of viewSize
			viewSize.height = viewSize.width
			viewSize.width = tempHeight
		}
		
		
		print("loading view")
		let scene = MainMenuScene(size: CGSizeMake(viewSize.height, viewSize.width))
		
		// Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
	
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
		
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
		
		print("about to present game scene")
		skView.presentScene(scene)
		
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
