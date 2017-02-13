//
//  SmithWaterman.swift
//  Gerald Scores
//
//  Created by Gerald Z on 22/12/16.
//  Copyright © 2016 Gerald Z. All rights reserved.
//
//  based on swa.py from Alex

import Foundation


var max1 = 0
var max2 = 0
let baseScore = 1
let penalty = 2
let threshold: Float = 0.95 // default 0.95

func reset() {
    max1 = 0
    max2 = 0
}

func all(v1: [Float], v2: [Float]) -> Bool {
    for i in 0...v1.count-1 {
        if (v1[i] != v2[i]) {return false}
    }
    return true
}

// notes by Alex: Seems to be faster for vectors of length 12 (Chromas). return 1.0 - cosine(v1, v2)
func cosine_similarity(v1: [Float], v2: [Float]) -> Float {
 
    var v1IsZero: Bool{
        for i in 0...v1.count-1 {
            if (v1[i] != 0) {return false}
        }
        return true
    }
    
    var v2IsZero: Bool{
        for i in 0...v2.count-1 {
            if (v2[i] != 0) {return false}
        }
        return true
    }
    
    if (v1IsZero && v2IsZero) {return 1.0}
    else if (v1IsZero) {return 0.0}
    else if (v2IsZero) {return 0.0}
    else {
        var multiples: [Float] = Array(repeating: 0.0, count: v1.count)
        for i in 0...v1.count-1{
            multiples[i] = v1[i] * v2[i]
        }
        var v1Norm: Float {
            var norm: Float = 0.0
            for i in 0...v1.count-1{
                norm = norm+v1[i]*v1[i]
            }
            return Float(sqrt(norm))
        }
        var v2Norm: Float {
            var norm:Float = 0.0
            for i in 0...v2.count-1{
                norm = norm+v2[i]*v2[i]
            }
            return Float(sqrt(norm))
        }
        return multiples.reduce(0, +)/v1Norm/v2Norm
        
    }
}

// only implemented one of many scoreFunctions by Alex
func scoreFunction(v1: [Float],v2: [Float])-> Float{
    let cosineSimilarity = cosine_similarity(v1: v1, v2: v2)
    if (threshold <= cosineSimilarity){
        return Float(baseScore) + cosineSimilarity
    }
    else {return Float(penalty)}
}

//  OnlineAlignment from swa.swa
public class OnlineAlignment {
    var n: Int
    var prevRow: [Float]
    var maxima: [Float] = []
    var maximaPositions: [Float] = []
    var positions: [Float] = []
    var refFeatures:[[Float]]
    var gapScore: Float
    
    init(refFeatures: [[Float]], gapScore: Float = -1) {
        reset()
        self.refFeatures = refFeatures
        self.gapScore = gapScore
        n = refFeatures.count
        prevRow = Array(repeating: 0.0, count: n+1)
        
    }
    
    func align(v: [Float]) -> Float {
        var nextRow: [Float] = Array(repeating: 0.0, count: self.n+1)
        var match: Float
        var delete: Float
        var insert: Float
        var maxPos: [Float] = []
        var maxValue: Float = 0.0
        var nextPos : Float

        
        for i in 1...self.n{  //indices here are a little bit iffy
            match = prevRow[i-1] + scoreFunction(v1: v, v2: refFeatures[i-1])
            delete = prevRow[i] + gapScore
            insert = nextRow[i-1] + gapScore
            
            nextRow[i] = max(0.0, match, delete, insert)
        }
        maxValue = nextRow.max()!
        maxima.append(nextRow.max()!)
        for i in 0...nextRow.count-1{
            if (nextRow[i]==maxValue){
                maxPos.append(Float(i))
                self.maximaPositions.append(Float(i))    // What is the difference between maxPos and maximaPositions?
            }
        }
        
        nextPos = maxPos[0] - 1 //Smith-Waterman Index -> Position
        self.positions.append(nextPos)
        
        prevRow = nextRow
        return nextPos
    }
}


/*
// from swacython.swa
public class OnlineAlignment {
    var n: Int
    var prevRow: [Float]
    var refFeatures:[[Float]]
    var gapScore: Float
    
    init(refFeatures: [[Float]], gapScore: Float = -1) {
        self.refFeatures = refFeatures
        self.gapScore = gapScore
        self.n = refFeatures.count
        prevRow = Array(repeating: 0.0, count: self.n+1)
        
    }
    
    func align(v: [Float]) -> Float {
        var nextRow: [Float] = Array(repeating: 0.0, count: self.n+1)
        var match: Float
        var delete: Float
        var insert: Float
        var maxValue: Float = 0.0
        var position = 0
        
        for i in 1...self.n {  //indices n is correct, in python range() doesnt count the last number
            match = self.prevRow[i-1] + scoreFunction(v1: v, v2: self.refFeatures[i-1])
            delete = self.prevRow[i] + self.gapScore
            insert = nextRow[i-1] + self.gapScore
            
            let val = max(0.0, match, delete, insert)
            if maxValue<val {
                position = i-1
                maxValue = val
            }
            nextRow[i] = val
        }
        self.prevRow = nextRow
        return Float(position)
    }
}
*/
