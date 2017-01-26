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

public func fft(_ input: [Float]) -> [Float] {
    var real = [Float](input)
    var imaginary = [Float](repeating: 0.0, count: input.count)
    var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)
    
    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    vDSP_fft_zip(weights!, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
    
    var magnitudes = [Float](repeating: 0.0, count: input.count)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))
    
    var normalizedMagnitudes = [Float](repeating: 0.0, count: input.count)
    vDSP_vsmul(sqrt(magnitudes), 1, /*[2.0 / Float(input.count)]*/ [Float(1.0)], &normalizedMagnitudes, 1, vDSP_Length(input.count))  //Do I need to normalise this?
    
    vDSP_destroy_fftsetup(weights)
    
    return normalizedMagnitudes
}

public func sqrt(_ x: [Float]) -> [Float] {
    var results = [Float](repeating: 0.0, count: x.count)
    vvsqrtf(&results, x, [Int32(x.count)])
    
    return results
}
