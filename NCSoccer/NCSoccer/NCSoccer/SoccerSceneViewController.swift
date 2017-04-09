//
//  SoccerSceneViewController.swift
//  NCSoccer
//
//  Created by Nathan Slager on 8/29/16.
//  Copyright (c) 2016 nathanslager. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

//var gameState = GameState.findingHost

// Global Variables
var screenSize: CGSize!
var gill: String = "Gill Sans"

var CAM_SCALE: CGFloat = 5.0
var CAM_ZOOM_FACTOR: CGFloat = 1.01

let findMatchNotificationKey = "findMatch"
let gcNotEnabledKey = "gcNotEnabled"

var gameCenterEnabled: Bool = false

class SoccerSceneViewController: UIViewController, GKMatchmakerViewControllerDelegate {

	// View Size
	var viewSize: CGSize!
	var soccerScene: SoccerScene!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.addObservers()
		setLocalPlayerAuthenticator()

		viewSize = view.bounds.size

		screenSize = viewSize
		
		/*
		// Switch dimensions if needed
		if viewSize.height < viewSize.width {
			let tempHeight = viewSize.height		// Flip width and height properties of viewSize
			viewSize.height = viewSize.width
			viewSize.width = tempHeight
		}
		*/
		
		let scene = MainMenuScene(size: viewSize)

		//let scene = MainMenuScene(size: CGSize(width: viewSize.height, height: viewSize.width))
		
		// Configure the view.
        let skView = self.view as! SKView
		skView.showsFPS = true
		//skView.showsNodeCount = true
		
		// Physics Debug
		//skView.showsPhysics = true
	
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
		
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .resizeFill
		
		//skView.presentScene(scene)
		skView.presentScene(scene)
		
    }
	
	override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
	
	
	//MARK: - GKMatchmakerViewControllerDelegate Methods
	func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
		/* Return to main menu scene */
		self.dismiss(animated: true, completion: nil)
	}
	
	func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
		print("MMVC found match!")
		soccerScene = SoccerScene(size: viewSize)
		soccerScene.match = match
		match.delegate = soccerScene

		if (match.expectedPlayerCount == 0) {
			print("Ready to start game!")
			self.dismiss(animated: false, completion: nil)
			let skview = self.view as! SKView
			soccerScene.scaleMode = .resizeFill
			skview.presentScene(soccerScene)
		}
	}
	
	func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
		print("VC failed with error \(error)")
	}
	
	func matchmakerViewController(_ viewController: GKMatchmakerViewController, hostedPlayerDidAccept player: GKPlayer) {
		print("MMVC hostedPlayer did accept")
	}
	
	func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFindHostedPlayers players: [GKPlayer]) {
		print("MMVC did find hosted players")
	}
	
	//MARK: - Custom match finding methods
	func findMatch(_ notification: NSNotification) {
		if (gameCenterEnabled) {
			let matchRequest = GKMatchRequest()
			
			var p = 4
			if let c = notification.userInfo?["players"] as? Int {
				p = c
			}
			
			matchRequest.defaultNumberOfPlayers = p
			matchRequest.maxPlayers = p
			matchRequest.minPlayers = p
			
			let matchVC = GKMatchmakerViewController(matchRequest: matchRequest)
			matchVC?.matchmakerDelegate = self
			self.present(matchVC!, animated: false, completion: nil)
			
			
		} else {
			print("gameCenterNotEnabled!")
			NotificationCenter.default.post(name: Notification.Name(rawValue: gcNotEnabledKey), object: nil)

		}
	}
	
	
	/* Called when the button "find match" is pressed in MainMenuScene */
	func startMatch(withHost: GKPlayer?) {
		let skView = self.view as! SKView!
		//hideAds()
		let pushInDirection = SKTransition.push(with: SKTransitionDirection.left, duration: 0.4)
		skView?.presentScene(soccerScene, transition:  pushInDirection)
		
	}
	

	func setLocalPlayerAuthenticator() {
		let localPlayer = GKLocalPlayer.localPlayer()
		/* Setting authenticateHandler immediately spawns a background thread that attempts 
			to authenticate the local player. This thread calls "localPlayer.authenticateHandler"
			when it finishes its attempt at authenticating the local player */
		localPlayer.authenticateHandler = {(viewController : UIViewController?, error : Error?) -> Void in
			/* Local player not authenticated, show gamecenter login viewController */
			if ((viewController) != nil) {
				self.show(viewController!, sender: self)
			} else if (localPlayer.isAuthenticated) {
				print("Local player authenticated")
				gameCenterEnabled = true
			} else {
				print("gamecenter not enabled. Local player not authenticated!")
				gameCenterEnabled = false
				// Turn off gamecenter
			}
			
			if (error != nil) {
				print("Authentication error: \(error)")
			}
			
			
		}
	}
	
	func addObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(findMatch(_:)), name: NSNotification.Name(rawValue: findMatchNotificationKey), object: nil)
	}
	
	
}


