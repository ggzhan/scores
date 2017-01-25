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
public func fourier_chroma(x: [Float], fmin: Float=65.406, fmax: Float=200000,fs: Float=44100) -> [Float] {
    let N = x.count
    let winFunc: [Float] = Array(repeating: 1.0, count: N)
    
    
    var tempChromaKernel: [[Float]] = generate_chroma_kernel(N: N, fmin: fmin, fmax: fmax, fs: fs) //Alex code for realFFT: N= N/2+1. My FFt doesnt compute in the same way
    var new_x = zip(winFunc, x).map(*)  //window*x
    
/*  in case the length of new_x is different to the length of fourier computation N
     signalEnergy = X from Alex´code
 */
    if new_x.count<N {
        let slice = new_x[0...N-1]
        new_x = Array(slice)
    }
    else if new_x.count>N {
        let restZeros: [Float] = Array(repeating: 0.0, count: N-new_x.count)
        new_x += restZeros
    }
    let signalEnergy = fft(new_x)
    
    tempChromaKernel = transpose(input: tempChromaKernel)
    var chromaKernel: [Float] = dot(a: tempChromaKernel, b: signalEnergy)
    let constant = sqrt(Float(N))
    
    for i in 0...chromaKernel.count-1 {
        chromaKernel[i] = chromaKernel[i]/constant
    }
    
    return chromaKernel

}

