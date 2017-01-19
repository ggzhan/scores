//
//  Kernels.swift
//  Gerald Scores
//
//  Created by Gerald Z on 18/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation



var chromaKernelCash = Array<[Float]>(repeating: Array(repeating: 0.0, count: 0), count: 0)  //does this initialze work?


struct chromaKernelKey {
    var N: Int
    var fmin: Float
    var fmax: Float
    var fs: Float
}


func frequency_to_midi(f: Float) -> Int {
    return Int(round(69+12*log2(f/440.0)))
}

/*
Creates a Nx12 matrix for converting a frequency vector of size N into a
Chroma Vector. fmin denotes the minimal frequency, fmax the maximal
frequency and fs the sampling rate.
*/
func generate_chroma_kernel(N: Int, fmin: Float, fmax: Float, fs: Float) -> [[Float]] {
    let alpha = powf(2.0, 1/12.0)
    let fLow = (fmin + fmin / alpha) / 2.0
    let fHigh = (fmax + fmax * alpha) / 2.0
    var frequencies: [Float] = []
    let margin = Int(fs)/2/N
    for index in 0...N {        // couldnt find a better way to do this....
        frequencies[index] =  Float(index*margin)
    }
    
    var kernel = Array<[Float]>(repeating: Array(repeating: 0.0, count: 12), count: N)          //tested in Playground, should be working correctly
    for (index, element) in frequencies.enumerated() {
        if element == 0 {
            continue
        }
        if (fLow <= element) && (element <= fHigh) {
            let pitchClass = frequency_to_midi(f: element)%12
            kernel[index][pitchClass] = 1.0
        }
    }
    return kernel
}

/* don´t need this apparently
// Cashing wrapper for generate_chroma_kernel
func chroma_kernel(N: Int, fmin: Float, fmax: Float, fs: Float) {
    let k = chromaKernelKey(N: N, fmin: fmin, fmax: fmax, fs: fs)
    if !(chromaKernelCash.contains(k.N) {
        chromaKernelCash(k) = generate_chroma_kernel(k)           // not sure if this works. Can a function run using a struct as params?
    }
}
*/
