//
//  MatchFinderViewController.swift
//  NCSoccer
//
//  Created by Nathan Slager on 11/24/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//
/*
import SpriteKit
import GameKit



class MatchFinderViewController : UIViewController, GKMatchmakerViewControllerDelegate {
	
	// View Size
	//var viewSize: CGSize!
	var gameCenterEnabled: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/*
		
		viewSize = view.bounds.size
		
		screenSize = viewSize
		
		// Switch dimensions if needed
		if viewSize.height < viewSize.width {
			let tempHeight = viewSize.height		// Flip width and height properties of viewSize
			viewSize.height = viewSize.width
			viewSize.width = tempHeight
		}
		
		
		print("loading view")
		let scene = MainMenuScene(size: CGSize(width: viewSize.height, height: viewSize.width))
		
		// Configure the view.
		let skView = self.view as! SKView
		skView.showsFPS = true
		skView.showsNodeCount = true
		
		// Physics Debug
		skView.showsPhysics = true
		
		/* Sprite Kit applies additional optimizations to improve rendering performance */
		skView.ignoresSiblingOrder = true
		
		/* Set the scale mode to scale to fit the window */
		scene.scaleMode = .aspectFill
		
		print("about to present game scene")
		skView.presentScene(scene)

*/
		
	}
	
	// MARK: - GKMatchmakerViewControllerDelegate Methods

	func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
		print("matchmaker VC ws cancelled")
	}
	
	func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
		print("MMVC found match!")
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
	func findMatch() {
		if (gameCenterEnabled) {
			
			let matchRequest = GKMatchRequest()
			matchRequest.defaultNumberOfPlayers = 2
			matchRequest.maxPlayers = 2
			matchRequest.minPlayers = 2
			
			let matchVC = GKMatchmakerViewController(matchRequest: matchRequest)
			matchVC?.matchmakerDelegate = self
			self.present(matchVC!, animated: false, completion: nil)
			
			
		} else {
			print("gameCenterNotEnabled!")
		}
		
		
	}
	
	func setLocalPlayerAuthenticator() {
		let localPlayer = GKLocalPlayer.localPlayer()
		localPlayer.authenticateHandler = {(viewController : UIViewController?, error : Error?) -> Void in
			if ((viewController) != nil) {
				self.show(viewController!, sender: self)
			} else if (localPlayer.isAuthenticated) {
				print("Local p authenticated")
				self.gameCenterEnabled = true
			} else {
				print("local p not authenticated!")
				self.gameCenterEnabled = false
				// Turn off gamecenter
			}
			
			if (error != nil) {
				print("Authentication error: \(error)")
			}
		}
	}
	

		/*
		// Methods from SoccerSceneViewController
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
*/
	
}
*/

