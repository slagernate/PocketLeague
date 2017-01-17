//
//  Network.swift
//  NCSoccer
//
//  Created by Nathan Slager on 12/15/16.
//  Copyright © 2016 nathanslager. All rights reserved.
//


/* This file contains an assortment of structures and functions to help network */
import GameKit

enum MessageType {
	case randomNumberMessage
	case carUpdateMessage
	case ballUpdateMessage
	case controlInputMessage
	case invalid
}

// Used to randomly select host (ideally we'll use chooseBestHost(), but it wasn't working for me)
struct RandomNumberMessage {
	var messageType = MessageType.randomNumberMessage
	var randomNumber: UInt32 = 0
}

// No floats or vectors allowed (will crash program when sent over network)
struct CarUpdateMessage {
	var messageType = MessageType.carUpdateMessage
	var lower32PlayerID: UInt32 = 0
	var upper32PlayerID: UInt32 = 0
	var positionX: UInt32 = 0
	var positionY: UInt32 = 0
	var velocityX: UInt32 = 0
	var velocityY: UInt32 = 0
	var zRotation: UInt32 = 0
	var angularVelocity: UInt32 = 0
}

struct BallUpdateMessage {
	var messageType = MessageType.ballUpdateMessage
	var positionX: UInt32 = 0
	var positionY: UInt32 = 0
	var velocityX: UInt32 = 0
	var velocityY: UInt32 = 0
	var angularVelocity: UInt32 = 0
} 

struct ControlInputMessage {
	var messageType = MessageType.controlInputMessage
	
	var steeringMagnitudeRatio: UInt32 = 10
	var steeringAngle: UInt32 = 0
	var steering = false
}


func keyMinValue(dict: [String: UInt32]) -> String? {
	
	var winner: String?
	var winners = 0
	for (key, value) in dict {
		if value == dict.values.min() {
			winners = winners + 1
			winner = key
		}
	}
	
	if (winners == 1) {
		return winner!
	}
	
	return nil
}


let generalConversion = (CGFloat(-30), CGFloat(30))
let positionConversion = (-(FIELD_WIDTH+FIELD_WIDTH/10.0), (FIELD_WIDTH+FIELD_WIDTH/10.0))

// Usage:
// var nate: CGFloat = -3.0
// let conversion = (CGFloat(-3), CGFloat(3))
// var p = package(data: nate, conversion: conversion) // = CGFloat = 0
////sendOverNetwork()
// var res = unpackage(data: p, conversion: conversion) // = CGFloat = -3.0

func package(data: CGFloat, conversion: (lower: CGFloat, upper: CGFloat)) -> UInt32 {
	var val = data
	let lowerBound = conversion.lower
	let upperBound = conversion.upper
	
	if  val < lowerBound {
		val = lowerBound
	}
	
	if val > upperBound {
		val = upperBound
	}
	
	let granularity = (upperBound - lowerBound)/CGFloat(UINT32_MAX)
	val = val - lowerBound
	val = round(val/granularity)
	return UInt32(val)
}

func unpackage(data: UInt32, conversion: (lower: CGFloat, upper: CGFloat)) -> CGFloat {
	var val = CGFloat(data)
	let lowerBound = conversion.lower
	let upperBound = conversion.upper
	
	let granularity = (upperBound - lowerBound)/CGFloat(UINT32_MAX)
	val = val * granularity
	val = val + lowerBound
	
	if val < lowerBound {
		val = lowerBound
	}
	
	if val > upperBound {
		val = upperBound
	}
	
	return val
}

// Usage:
//let stringID = "G:" + String(UINT32_MAX)
//
//let intID: UInt64 = integerFrom(str: stringID)!
//
//let lower = lowerU32(int: intID)
//let upper = upperU32(int: intID)
//
//// sendOverNetwork()
//
//let mergedID: UInt64 = mergeU64From(lower: lower, upper: upper)
//
//let stringID2 = playerIDFrom(int: mergedID)


func playerIDFrom(int: UInt64) -> String {
	return "G:" + String(int)
}

func lowerU32(int: UInt64) -> UInt32 {
	return UInt32(int & 0xFFFFFFFF)
}

func upperU32(int: UInt64) -> UInt32 {
	return UInt32(int >> 32)
}

func mergeU64From(lower: UInt32, upper: UInt32) -> UInt64 {
	return (UInt64(upper) << 32) | UInt64(lower)
}

func integerFrom(str: String) -> UInt64? {
	
	var intArr = [Int]()
	
	for i in str.characters {
		let char = String(i)
		if let n = Int(char) {
			intArr += [n]
		}
	}
	
	var intID: UInt64 = 0
	var m: UInt64 = 1
	for digit in intArr.reversed() {
		intID = intID + (UInt64(digit) * m)
		m = m * 10
		if (m > (UINT64_MAX/10)) {
			return nil
		}
	}
	
	return intID
	
}

