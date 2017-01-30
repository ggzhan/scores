//
//  FFT.swift
//  Gerald Scores
//
//  Created by Gerald Z on 16/12/16.
//  Copyright © 2016 Gerald Z. All rights reserved.
//
// https://github.com/mattt/Surge/blob/master/Source/FFT.swift

import Accelerate

// MARK: Fast Fourier Transform

func fft(_ input: UnsafeMutablePointer<Float>, inputCount: Int, weights: FFTSetup?) -> [Float] {
    var real = input
    //let real = UnsafeMutablePointer<Float>.init(from: input)
    //let imaginary = UnsafeMutablePointer<Float>.allocate(capacity: input.count)
    var imaginary = Array<Float>(repeating: 0.0, count: inputCount)
    var splitComplex = DSPSplitComplex(realp: real, imagp: &imaginary)
 
    let length = vDSP_Length(floor(log2(Float(inputCount))))
    vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Float](repeating: 0.0, count: inputCount)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(inputCount))
    
    var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
    vDSP_vsmul(sqrt(magnitudes), 1, /*[2.0 / Float(length)]*/ [Float(1.0)], &normalizedMagnitudes, 1, vDSP_Length(inputCount))  //Do I need to normalise this?
 
    //vDSP_destroy_fftsetup(weights)
    
    return normalizedMagnitudes
}

public func sqrt(_ x: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}

