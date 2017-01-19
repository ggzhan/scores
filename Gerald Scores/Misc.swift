//
//  Misc.swift
//  Gerald Scores
//
//  Created by Gerald Z on 19/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation


public func transpose<T>(input: [[T]]) -> [[T]] {
    if input.isEmpty { return [[T]]() }
    let count = input[0].count
    var out = [[T]](repeating: [T](), count: count)
    for outer in input {
        for (index, inner) in outer.enumerated() {
            out[index].append(inner)
        }
    }
    
    return out
}

public func dot(a:[[Float]], b: [Float]) -> [Float] {
    
    let dimx = a.count
    let dimy = b.count
    var temp: [[Float]] = Array(repeating: Array(repeating: 0.0, count: dimy), count: dimx)
    var result: [Float] = Array(repeating: 0.0, count: dimy)
    
    for index in 0...dimx-1 {
        for indexy in 0...dimy-1 {
            temp[index][indexy] = a[index][indexy]*b[indexy]
        }
    }
    for i in 0...dimy-1 {
        result[i] = temp[i].reduce(0,+)
    }
    
    return result
}
