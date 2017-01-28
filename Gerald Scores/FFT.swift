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
     /*
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    */
    vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Float](repeating: 0.0, count: inputCount)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(inputCount))
    
    var normalizedMagnitudes = [Float](repeating: 0.0, count: inputCount)
    vDSP_vsmul(sqrt(magnitudes), 1, /*[2.0 / Float(length)]*/ [Float(1.0)], &normalizedMagnitudes, 1, vDSP_Length(inputCount))  //Do I need to normalise this?
 
    //vDSP_destroy_fftsetup(weights)
    
    return normalizedMagnitudes
}

func fft_p(_ input: UnsafeMutablePointer<Float>, length: Int, weights: FFTSetup?) -> UnsafeMutablePointer<Float> {
    let real = input
    let imaginary = UnsafeMutablePointer<Float>.allocate(capacity: length)
    for i in 0...length-1 {
        imaginary[i] = 0
    }
    var splitComplex = DSPSplitComplex(realp: real, imagp: imaginary)
    
    let length_fft = vDSP_Length(floor(log2(Float(length))))
    vDSP_fft_zip(weights!, &splitComplex, 1, length_fft, FFTDirection(FFT_FORWARD))
    
    let magnitudes = UnsafeMutablePointer<Float>.allocate(capacity: length)
    vDSP_zvmags(&splitComplex, 1, magnitudes, 1, vDSP_Length(length))
    
    vDSP_vsmul(sqrt_p(magnitudes, length: length), 1, /*[2.0 / Float(length)]*/ [Float(1.0)], magnitudes, 1, vDSP_Length(length))  //Do I need to normalise this?
    
    //vDSP_destroy_fftsetup(weights)
    
 return magnitudes
}



public func sqrt(_ x: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}

public func sqrt_p(_ x: UnsafeMutablePointer<Float>, length: Int) -> UnsafeMutablePointer<Float> {
    let results = UnsafeMutablePointer<Float>.allocate(capacity: length)
    vvsqrtf(results, x, [Int32(length)])
    
    return results
}
