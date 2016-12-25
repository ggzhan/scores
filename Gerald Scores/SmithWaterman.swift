//
//  SmithWaterman.swift
//  Gerald Scores
//
//  Created by Gerald Z on 22/12/16.
//  Copyright © 2016 Gerald Z. All rights reserved.
//

import Foundation


var max1 = 0
var max2 = 0

func reset() {
    max1 = 0
    max2 = 0
}

func cosine_similarity(v1: [Float], v2: [Float]) {
    var v1IsZero: [Bool]
    var v1IsZeroFunc: [Bool]{
        set{
            for i in v1 {
                if (i == 0) {v1IsZero.insert(true, at: Int(i))}
                v1IsZero.insert(false, at: Int(i))
            }
        }
        get{return v1IsZero}
    }
    
    var v2IsZero: [Bool]
    var v2IsZeroFunc: [Bool]{
        set{
            for i in v2 {
                if (i == 0) {v2IsZero.insert(true, at: Int(i))}
                v2IsZero.insert(false, at: Int(i))
            }
        }
        get{return v2IsZero}
    }
    
    for i in v1IsZero {
        //if (v1IsZero.index(before: i) && v2IsZero.index(before: i)) {
        
        }
    }
    
}
