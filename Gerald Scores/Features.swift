//
//  Features.swift
//  Gerald Scores
//
//  Created by Gerald Z on 20/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation


/*    """Number of blocks for a given length, windowSize and windowOffset.
 
 Args:
 length:       Array length.
 windowSize:   Size of window.
 windowOffset: Size of window offset.
 
 Returns:
 Number of blocks for the given configuration.
 """
 */
func nr_of_blocks(length: Int, windowSize: Int, windowOffset: Int) -> Int {
    
    if windowSize<=windowOffset {return length/windowSize}
    else {
        var a = length/windowOffset
        while length<(a-1)*windowOffset+windowSize {
            a=a-1
        }
        return a
    }
}


/*
 """Number of blocks for a given length, windowSize and windowOffset.
 
 Args:
 length:       Array length.
 windowSize:   Size of window.
 windowOffset: Size of window offset.
 
 Returns:
 Number of blocks for the given configuration.
 """*/
public func extract_features(x: [Float], winSize: Int, winOffset: Int) -> [[Float]] {
    
    let nrOfBlocks = nr_of_blocks(length: x.count, windowSize: winSize, windowOffset: winOffset)
    let n = fourier_chroma(x: [Float](x[0...winSize])).count
    var ret: [[Float]] = Array(repeating: Array(repeating: 1.0, count: n), count: nrOfBlocks)
    var left: Int
    var right: Int
    
    for i in 0...nrOfBlocks-1 {
        left = i*winOffset
        right = left + winSize
        ret[i] = fourier_chroma(x: [Float](x[left...right]) )
    }
    return ret
}


// not for actual use. Only for testing
public func extract_dummy_features(x: [Float], winSize: Int, winOffset: Int) -> [[Float]] {
    
    let nrOfBlocks = nr_of_blocks(length: x.count, windowSize: winSize, windowOffset: winOffset)
    let n = fourier_chroma(x: [Float](x[0...winSize])).count
    var ret: [[Float]] = Array(repeating: Array(repeating: 1.0, count: n), count: nrOfBlocks)
    var left: Int
    var right: Int
    
    for i in 0...nrOfBlocks-1 {
        left = i*winOffset
        right = left + winSize
        ret[i] = fourier_chroma(x: [Float](x[left...right]))
        for j in 0...n-1{
            ret[i][j] = 365.0
        }
    }
    return ret
}
