//
//  Follower.swift
//  Gerald Scores
//
//  Created by Gerald Z on 19/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation
import AVFoundation

func evaluate_OnlineAlignment(testFeatures: [[Float]], oa: OnlineAlignment) -> ( [Float], [Float], [Float]) {
 let n = testFeatures.count
 var predictedPosition: [Float] = Array(repeating: 0.0, count: n)
 var actualPosition: [Float] = Array(repeating: 0.0, count: n)
 
 let startTime = DispatchTime.now()
 
 for (i,chroma) in testFeatures.enumerated(){
  predictedPosition[i] = oa.align(v: chroma)
  actualPosition[i] =  Float(i%n) //TODO
 }
 let endTime = DispatchTime.now()
 print(endTime.uptimeNanoseconds-startTime.uptimeNanoseconds)
 
 let errors = zip(actualPosition, predictedPosition).map(-)
 
 return (predictedPosition, actualPosition, errors)
}

public func follower(soundFileURL: [URL]) {
 let refURL = Bundle.main.url(forResource: "acknowledge1", withExtension: "wav", subdirectory: "/Users/geraldz/Documents/scores-app/Musicr")
 let SwaInstance = Swa(recordings: soundFileURL)
 let refSoundFile = Swa.loadAudioSignal(audioURL: refURL!)
 let testSoundFile = Swa.loadAudioSignal(audioURL: soundFileURL[0])
 let refFeatures = SwaInstance.extract_features(x: refSoundFile)
 let testFeatures = SwaInstance.extract_features(x: testSoundFile)
 let onlineAlignment = OnlineAlignment(refFeatures: refFeatures)

 let (predictedPosition, actualPosition, errors) = evaluate_OnlineAlignment(testFeatures: testFeatures, oa: onlineAlignment)
 
 /*
  print(refFeatures)
  print(testFeatures)
  */
 
 print(errors)
 print(predictedPosition)
 print(actualPosition)
 
}

func loadAudioSignal(audioURL: URL) -> [Float] {
 let file = try! AVAudioFile(forReading: audioURL as URL!)
 let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
 let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
 try! file.read(into: buf) // maybe need better error handling
 let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
 return floatArray
}

func getURL() {
 let refURL = Bundle.main.url(forResource: "acknowledge1", withExtension: "wav", subdirectory: "/Users/geraldz/Documents/scores-app/Musicr")
}
