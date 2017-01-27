//
//  SwaBackEnd.swift
//  Gerald Scores
//
//  Created by Gerald Z on 27/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation
import Accelerate
import AVFoundation

// http://technology.meronapps.com/2016/09/27/swift-3-0-unsafe-world-2/

class Swa {

  
  let fs = 44100
  let windowSize = 4096
  let chromaLength = 12
  let fmin: Float = 65.406
  let fmax: Float = 20000
  let alpha = powf(2.0, 1/12.0)
  let fLow: Float
  let fHigh: Float
  let fft_length: UInt
  let weights: FFTSetup?
  var recordings: [URL]
  let chromaKernel: UnsafeMutablePointer<UnsafeMutablePointer<Float>>
  //var chromaKernel = UnsafeMutablePointer<UnsafeMutablePointer<Float>>.allocate(capacity: 0)
  let radix = FFTRadix(kFFTRadix2)
  

  init(recordings: [URL]) {
    fLow = (fmin + fmin / alpha) / 2.0
    fHigh = (fmax + fmax * alpha) / 2.0
    fft_length = vDSP_Length(floor(log2(Float(windowSize))))
    weights = vDSP_create_fftsetup(fft_length, radix)
    self.recordings = recordings
    //chromaKernel.deallocate(capacity: 0)
    chromaKernel = UnsafeMutablePointer<UnsafeMutablePointer<Float>>.allocate(capacity: windowSize)
    for i in 0...chromaLength-1 {
      chromaKernel[i] = UnsafeMutablePointer<Float>.allocate(capacity: chromaLength)
    }
    generate_chroma_kernel()
  }
  deinit {
    for i in 0...chromaLength-1 {
      chromaKernel[i].deallocate(capacity: chromaLength)
    }
    chromaKernel.deallocate(capacity: windowSize)
  }


  static func loadAudioSignal(audioURL: URL) -> [Float] {
    let file = try! AVAudioFile(forReading: audioURL as URL!)
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
    let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
    try! file.read(into: buf) // maybe need better error handling
    let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
    return floatArray
  }

  func frequency_to_midi(f: Float) -> Int {
    return Int(round(69+12*log2(f/440.0)))
  }
  
  /*
   Creates a Nx12 matrix for converting a frequency vector of size N into a
   Chroma Vector. fmin denotes the minimal frequency, fmax the maximal
   frequency and fs the sampling rate.
   */
  private func generate_chroma_kernel() {
    var frequencies: [Float] = Array(repeating: 0.0, count: windowSize/2)
    let margin = Int(fs)/windowSize     //margin= nyquist/(N/2)
    for index in 0...windowSize/2-1 {        // couldnt find a better way to do this....
      frequencies[index] =  Float(index*margin)
    }
    for index in 0..<windowSize/2 {
      let element = frequencies[index]
      if element == 0 {
        continue
      }
      if (fLow <= element) && (element <= fHigh) {
        let pitchClass = frequency_to_midi(f: element)%12
        chromaKernel[pitchClass][index] = 1.0
      }
    }

  }  
  private func fourier_chroma(x: [Float]) -> [Float] {   //Computes a chroma vector from x via FFT
    var signalEnergy = fft(x, weights: self.weights)
    let chromaVector = dot_p(a: chromaKernel, b: &signalEnergy) //transpose and dot in one
    let constant = sqrt(Float(windowSize))
    for i in 0...chromaLength-1 {
      chromaVector[i] = chromaVector[i]/constant
    }
    return Array(UnsafeBufferPointer(start: chromaVector, count: self.chromaLength))
  }
  
  public func extract_features(x: [Float]) -> [[Float]] {
    let n = x.count
    let nrOfBlocks = Int(n/windowSize)
    //var ret: [[Float]] = Array(repeating: Array(repeating: 0.0, count: n), count: nrOfBlocks)
    var ret: [[Float]] = Array(repeating: Array(repeating: 0.0, count: chromaLength), count: nrOfBlocks)
    var left: Int
    var right: Int
    
    for i in 0...nrOfBlocks-1 {  //in cases where x.count is multiple of window size, index out of range for nrOfBlocks-1
      left = i*windowSize
      right = left + windowSize-1
      let signalSplice = [Float](x[left...right]) //needs to convert ArraySplice to Array
      ret[i] = fourier_chroma(x: signalSplice)
    }
    return ret
    }
  }
  
/*
  func evaluate_OnlineAlignment(testFeatures: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, length: Int, oa: OnlineAlignment_p) -> ( [Float], [Float], [Float]) {
    var predictedPosition: [Float] = Array(repeating: 0.0, count: length)
    var actualPosition: [Float] = Array(repeating: 0.0, count: length)
    
    let startTime = DispatchTime.now()
    
    for i in 0...length-1 {
      predictedPosition[i] = oa.align(v: testFeatures[i])
      actualPosition[i] = Float(i%length)
    }
    
    let endTime = DispatchTime.now()
    print(endTime.uptimeNanoseconds-startTime.uptimeNanoseconds)
    
    let errors = zip(actualPosition, predictedPosition).map(-)
    
    return (predictedPosition, actualPosition, errors)
  }
  
  func follower() {
    
    let (refFeatures, testFeatures) = getFeatures(recordings: self.recordings)
    let onlineAlignment = OnlineAlignment_p(refFeatures: refFeatures, length: getSoundFile(soundFileURL: recordings[1]).length)
    
    let (predictedPosition, actualPosition, errors) = evaluate_OnlineAlignment(testFeatures: testFeatures, length: getSoundFile(soundFileURL: recordings[0]).length, oa: onlineAlignment)
    /*
     print(refFeatures)
     print(testFeatures)
     */
    print(errors)
    print(predictedPosition)
    print(actualPosition)
    
  }
  
}
*/
//   let refFeatures: [[Float]] =  extract_features(x: loadAudioSignal[recordings[1]], winSize: windowSize, winOffset: windowSize)
//let testFeatures: [[Float]] =  extract_features(x: loadAudioSignal[recordings[0]], winSize: windowSize, winOffset: windowSize)

// from swacython.swa
class OnlineAlignment_p {
  
  
  var max1 = 0
  var max2 = 0
  let maxEuclideanDistance: Float = sqrt(12)
  let baseScore = 1
  let penalty = 2
  let threshold: Float = 0.95 // default 0.95
  
  var n: Int
  var prevRow: UnsafeMutablePointer<Float>
  var refFeatures: UnsafeMutablePointer<UnsafeMutablePointer<Float>>
  var gapScore: Float
  
  init(refFeatures: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, length: Int, gapScore: Float = -1) {
    self.refFeatures = refFeatures
    self.gapScore = gapScore
    self.n = length
    prevRow = UnsafeMutablePointer<Float>.allocate(capacity: n+1)
    
  }
  
  func reset() {
    max1 = 0
    max2 = 0
  }
  
  func all(v1: [Float], v2: [Float]) -> Bool {
    for i in 0...v1.count-1 {
      if (v1[i] != v2[i]) {return false}
    }
    return true
  }
  
  // notes by Alex: "Seems to be faster for vectors of length 12 (Chromas). return 1.0 - cosine(v1, v2)"
  func cosine_similarity(v1: UnsafeMutablePointer<Float>, v2: UnsafeMutablePointer<Float>) -> Float {
    let n = 12 // chromavectors always have size 12
    var v1IsZero: Bool{
      for i in 0...n-1 {
        if (v1[i] != 0) {return false}
      }
      return true
    }
    
    var v2IsZero: Bool{
      for i in 0...n-1 {
        if (v2[i] != 0) {return false}
      }
      return true
    }
    
    if (v1IsZero && v2IsZero) {return 1.0}
    else if (v1IsZero) {return 0.0}
    else if (v2IsZero) {return 0.0}
      
      
    else {
      var multiples: [Float] = Array(repeating: 0.0, count: n)
      for i in 0...n-1{
        multiples[i] = v1[i] * v2[i]
      }
      var v1Norm: Float {
        var norm: Float = 0.0
        for i in 0...n-1{
          norm = norm+v1[i]*v1[i]
        }
        return Float(sqrt(norm))
      }
      var v2Norm: Float {
        var norm:Float = 0.0
        for i in 0...n-1{
          norm = norm+v2[i]*v2[i]
        }
        return Float(sqrt(norm))
      }
      return multiples.reduce(0, +)/v1Norm/v2Norm
      
    }
  }
  
  // only implemented one of many scoreFunctions by Alex
  func scoreFunction(v1: UnsafeMutablePointer<Float>, v2: UnsafeMutablePointer<Float>)-> Float{
    let cosineSimilarity = cosine_similarity(v1: v1, v2: v2)
    if (threshold <= cosineSimilarity){
      return Float(baseScore) + cosineSimilarity
    }
    else {return Float(penalty)}
  }
  
  
  
  
  func align(v: UnsafeMutablePointer<Float>) -> Float {
    let nextRow = UnsafeMutablePointer<Float>.allocate(capacity: n+1)
    for i in 0...n {
      nextRow[i] = 0.0
    }
    var match: Float
    var delete: Float
    var insert: Float
    var maxValue: Float = 0.0
    var position = 0
    
    for i in 1...self.n {  //indices n is correct, in python range() doesnt count the last number
      match = self.prevRow[i-1] + scoreFunction(v1: v, v2: refFeatures[i-1])
      delete = self.prevRow[i] + self.gapScore
      insert = nextRow[i-1] + self.gapScore
      
      let val = max(0.0, match, delete, insert)
      if maxValue<val {
        position = i-1
        maxValue = val
      }
      nextRow[i] = val
    }
    self.prevRow = nextRow
    return Float(position)
    
  }
}

