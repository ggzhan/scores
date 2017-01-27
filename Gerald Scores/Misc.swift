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
        for (index, inner) in outer.enumerated() {  // really really slow
            out[index].append(inner)

        }
    }
    
    return out
}

public func dot(a:[[Float]], b: [Float]) -> [Float] {
    
    let dimx = a.count
    let dimy = b.count
    if a[0].count != b.count {
        print("Dimensions of arrays not correct!")
        return [0]
    }
    //var temp: [[Float]] = Array(repeating: Array(repeating: 0.0, count: dimy), count: dimx)
    var result: [Float] = Array(repeating: 0.0, count: dimx)
    
    for index in 0...dimx-1 {
        var vec:[Float] = a[index]
        for indexy in 0...dimy-1 {
           result[index] += vec[indexy] * b[indexy]
        }
    }
    
    return result
}

public func dot_p(a:UnsafeMutablePointer<UnsafeMutablePointer<Float>>, b: UnsafeMutablePointer<Float>) -> UnsafeMutablePointer<Float> {
    
    let dimx = 12
    let dimy = 4096
    //var temp: [[Float]] = Array(repeating: Array(repeating: 0.0, count: dimy), count: dimx)
    let result = UnsafeMutablePointer<Float>.allocate(capacity: 12)
    let vec = UnsafeMutablePointer<Float>.allocate(capacity: 4096)
    for index in 0...dimx-1 {
        for indexy in 0...dimy-1 {
            result[index] = result[index] + vec[indexy]*b[indexy]
        }
    }
    
    return result
}
