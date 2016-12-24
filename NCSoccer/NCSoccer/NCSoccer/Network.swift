//
//  Network.swift
//  NCSoccer
//
//  Created by Nathan Slager on 12/15/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//
/*
import Foundation
import GameKit




class Network: NSObject, GKMatchDelegate {

	var buffers = [UnsafeMutableBufferPointer<Any>]()
	
	init(match: GKMatch) {
		self.match = match
	}
	
	

}

*/

enum MessageType {
	case randomNumberMessage
	case hostIdentifierSuggestion
	case hostIdentifier
	case hostAcknowledged
	case startGame
	case invalid
}

struct HostSuggestionMessage {
	var messageType = MessageType.hostIdentifierSuggestion
	var hostID: String?
}

struct RandomNumberMessage {
	var messageType = MessageType.randomNumberMessage
	var randomNumber: UInt32!
}

struct MessageFromHost {
	var messageType = MessageType.hostIdentifier
}


struct HostAcknowledgedMessage {
	var messageType = MessageType.hostAcknowledged
}

struct StartGameMessage {
	var messageType = MessageType.startGame
}

struct GameStateMessage {
	//var messageHeader: MessageHeader
	var messageType: MessageType
	var gameState: GameState
}
