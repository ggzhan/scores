//
//  Chroma.swift
//  Gerald Scores
//
//  Created by Gerald Z on 18/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation

/*
fourier_chroma: Computes a chroma vector from x via FFT.

Params:
- x: Input array

Keyword Arguments:
- fmin:    Lowest considered frequency
- fmax:    Highest considered frequency
- N:       Length of fourier computation (N=None -> N=len(x))
- fs:      Samplingrate.
- winFunc: Window function
*/
public func fourier_chroma(x: [Float], fmin: Float=65.406, fmax: Float=200000, N: Int?=nil, fs: Float=44100, winFunc: [Float]? = nil) -> [Float] {
    if (N == nil) {let N = x.count}
    else {let N = N}
    if (winFunc == nil) {let winFunc: [Float] = Array(repeating: 1.0, count: N!)}
    else {let winFunc: [Float] = winFunc!}
    
    var tempChromaKernel: [[Float]] = generate_chroma_kernel(N: N!/2+1, fmin: fmin, fmax: fmax, fs: fs) // =generate_chroma_kernel
    var new_x = zip(winFunc!, x).map(*)
    var chromaKernel: [Float]
    
/*  in case the length of new_x is different to the length of fourier computation N
     signalEnery = X from Alex´code
 */
    if new_x.count<N! {
        let slice = new_x[0...N!-1]
        new_x = Array(slice)
    }
    else if new_x.count>N! {
        let restZeros: [Float] = Array(repeating: 0.0, count: N!-new_x.count)
        new_x += restZeros
    }
    let signalEnergy = fft(new_x)
    
    tempChromaKernel = transpose(input: tempChromaKernel)
    chromaKernel = dot(a: tempChromaKernel, b: signalEnergy)
    let constant = sqrt(Float(N!))
    
    for i in 0...chromaKernel.count-1 {
        chromaKernel[i] = chromaKernel[i]/constant
    }
    
    return chromaKernel

}

