//
//  Chroma.swift
//  Gerald Scores
//
//  Created by Gerald Z on 18/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation
import Accelerate

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

var tempChromaKernel: [[Float]] = transpose(input: generate_chroma_kernel(N: 4097, fmin: 65.406, fmax: 20000, fs: 44100)) //Alex code for realFFT: N= N/2+1. My FFt doesnt compute in the same way
   // tempChromaKernel = transpose(input: tempChromaKernel)

public func fourier_chroma(x: Array<Float>, fmin: Float=65.406, fmax: Float=20000,fs: Float=44100, weights: FFTSetup?) -> [Float] {
    let N = x.count
    //let winFunc: [Float] = Array(repeating: 1.0, count: N)
    //var new_x = zip(winFunc, x).map(*)  //window*x
    
/*  in case the length of new_x is different to the length of fourier computation N
     signalEnergy = X from Alex´code
 */
    /*
    if x.count<N {
        var slice = x[0...N-1]
        x = Array(slice)
    }
    else if x.count>N {
        let restZeros: [Float] = Array(repeating: 0.0, count: N-x.count)
        x += restZeros
    }
 */
    var signalEnergy = fft(x, weights: weights)
    
    //print(tempChromaKernel)
    

    /*
    var chromaKernel: [Float] = dot(a: tempChromaKernel, b: signalEnergy)
    let constant = sqrt(Float(N))
    */
    var tempChromaKernel_p = UnsafeMutablePointer<UnsafeMutablePointer<Float>>.allocate(capacity: tempChromaKernel.count)
    for i in 0...tempChromaKernel.count-1{
        var temptempChromakernel_p = UnsafeMutablePointer<Float>.allocate(capacity: tempChromaKernel[0].count)
        for j in 0...tempChromaKernel[0].count-1 {
            temptempChromakernel_p[j] = tempChromaKernel[i][j]
        }
        tempChromaKernel_p[i] = temptempChromakernel_p
    }
    var signalEnergy_p = UnsafeMutablePointer<Float>.allocate(capacity: signalEnergy.count)
    for i in 0...signalEnergy.count-1 {
        signalEnergy_p[i] = signalEnergy[i]
    }

    
    var chromaKernel : [Float] = Array(repeating: 0.0, count: 12)
    var chromaKernel_p = dot_p(a: tempChromaKernel_p, b: signalEnergy_p)
    for i in 0...tempChromaKernel.count-1 {
            chromaKernel[i] = chromaKernel_p[i]
    }

    let constant = sqrt(Float(N))
    
    for i in 0...chromaKernel.count-1 {
        chromaKernel[i] = chromaKernel[i]/constant
    }
    
    return chromaKernel

}

