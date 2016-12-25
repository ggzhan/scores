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
let maxEuclideanDistance: Float = sqrt(12)
let baseScore = 1
let penalty = 2
let threshold: Float = 0.95

func reset() {
    max1 = 0
    max2 = 0
}

// notes by Alex: Seems to be faster for vectors of length 12 (Chromas). return 1.0 - cosine(v1, v2)
func cosine_similarity(v1: [Float], v2: [Float]) -> Float {
    var v1IsZero: Bool = false
    var v1IsZeroFunc: Bool{
        for i in v1 {
            if (i != 0) {return false}
        }
        return true
    }
    
    var v2IsZero: Bool = false
    var v2IsZeroFunc: Bool{
        for i in v2 {
            if (i != 0) {return false}
        }
        return true
    }
    
    if (v1IsZero && v2IsZero) {return 1.0}
    else if (v1IsZero) {return 0.0}
    else if (v2IsZero) {return 0.0}
    else {
        var multiples: [Float] = Array(repeating: 0.0, count: v1.count)
        for i in 0...v1.count{
            multiples[i] = v1[i] * v2[i]
        }
        var v1Norm: Float {
            var norm: Float = 0.0
            for i in 0...v1.count{
                norm = norm+sqrt(v1[i]*v1[i])
            }
            return Float(norm)
        }
        var v2Norm: Float {
            var norm:Float = 0.0
            for i in 0...v2.count{
                norm = norm+sqrt(v2[i]*v2[i])
            }
            return Float(norm)
        }
        return multiples.reduce(0, +)/v1Norm/v2Norm
        
    }
}

func euclidean_similarity(v1: [Float],v2: [Float]) -> Float {
    var d: Float {
        var ret: Float = 0.0
        for i in 0...v1.count{
            ret = ret+sqrt((v2[i]-v1[i])*(v2[i]-v1[i]))
        }
        return ret
    }
    return 1.0-d/maxEuclideanDistance
}


// only implemented one of many scoreFunctions by Alex
func scoreFunction(v1: [Float],v2: [Float])-> Float{
    let cosineSimilarity = cosine_similarity(v1: v1, v2: v2)
    if (threshold <= cosineSimilarity){
        return Float(baseScore) + cosineSimilarity
    }
    else {return Float(penalty)}
}






