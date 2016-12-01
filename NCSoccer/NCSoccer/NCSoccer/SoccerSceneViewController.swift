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

// Global Variables
var screenSize: CGSize!
var gill: String = "Gill Sans"

var CAM_SCALE: CGFloat = 2.0
var CAM_ZOOM_FACTOR: CGFloat = 1.01

let findMatchNotificationKey = "findsoccermatch"
let gcNotEnabledKey = "gcNotEnabled"

	
class SoccerSceneViewController: UIViewController, GKMatchmakerViewControllerDelegate, GKMatchDelegate {

	// View Size
	var viewSize: CGSize!
	var gameCenterEnabled: Bool = false
	var match: GKMatch!
	var matchStarted: Bool = false

	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.addObservers()
		/*matchFinderVC.*/setLocalPlayerAuthenticator()

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
		
		print("loading view")
		let scene = MainMenuScene(size: viewSize)

		//let scene = MainMenuScene(size: CGSize(width: viewSize.height, height: viewSize.width))
		
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
	
	
	
	//MARK: - GKMatchDelegate Methods
	func match(_ match: GKMatch, didFailWithError error: Error?) {
		print("match failed with error: \(error)")
	}
	
	func match(_ match: GKMatch, didReceive data: Data, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
		print("data received from \(player.alias) for \(recipient.alias)")
	}
	
	func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
		print("recieved data from \(player)")
	}
	
	func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
		print("match should reinvite disconnected player: \(player.alias)")
		return false
	}
	
	func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
		print("NATHANSLAGER \(player.alias) changed state to: \(state)")
		if (match.expectedPlayerCount == 0) {
			print("NATHANSLAGER: Start match bih")
		}
	}
	
	
	
	//MARK: - GKMatchmakerViewControllerDelegate Methods
	func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
		print("matchmaker VC ws cancelled")
	}
	
	func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
		print("MMVC found match!")
		self.match = match
		match.delegate = self

		/*
		self.dismiss(animated: false, completion: nil)
		let skView = self.view as! SKView!
		let scene = SoccerScene(size: viewSize)
		//hideAds()
		let pushInDirection = SKTransition.push(with: SKTransitionDirection.left, duration: 0.4)
		skView?.presentScene(scene, transition:  pushInDirection)
*/
		
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
			NotificationCenter.default.post(name: Notification.Name(rawValue: gcNotEnabledKey), object: nil)

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
	
	func addObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(findMatch), name: NSNotification.Name(rawValue: findMatchNotificationKey), object: nil)
	}
	
	
}


