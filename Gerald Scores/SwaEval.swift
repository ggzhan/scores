//
//  Eval.swift
//  Gerald Scores
//
//  Created by Gerald Z on 20/01/17.
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

 let SwaInstance = Swa(recordings: soundFileURL)
 let refSoundFile = Swa.loadAudioSignal(audioURL: soundFileURL[1])
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

func findBars(soundFileURL: [URL]) {
    let refURL = Bundle.main.url(forResource: "Ravel - Tzigane", withExtension: "wav")
    let SwaInstance = Swa(recordings: soundFileURL)
    let refSoundFile = Swa.loadAudioSignal(audioURL: refURL!)
    let testSoundFile = Swa.loadAudioSignal(audioURL: soundFileURL[0])
    let refFeatures = SwaInstance.extract_features(x: refSoundFile)
    let testFeatures = SwaInstance.extract_features(x: testSoundFile)
    let onlineAlignment = OnlineAlignment(refFeatures: refFeatures)
    var predictedPosition: [Float] = Array(repeating: 0.0, count: testFeatures.count)
    for (i,chroma) in testFeatures.enumerated(){
        predictedPosition[i] = onlineAlignment.align(v: chroma)
    }
    let predictedPositionInSeconds = predictedPosition.map{$0 / 10.8}
    
    var refPositions: [Float] = []
    var jsonObj: [String: Float]!
    if let path = Bundle.main.path(forResource: "Tzigane_mapping", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Float]
            for i in 1...jsonObj.count {
                refPositions.append(jsonObj[String(i)]!) // "1": 3.234, "2": 5.342
            }
        } catch let error {
            print(error.localizedDescription)
        }
    } else {
        print("Invalid filename/path.")
    }
    
    var predictedBarPositions = Array(repeating: 0, count: predictedPositionInSeconds.count)
    for i in 0..<predictedBarPositions.count {
        for j in 0..<refPositions.count-1 {
            if (predictedPositionInSeconds[i] > refPositions[j]) && (predictedPositionInSeconds[i] < refPositions[j+1]) {
                continue
            } else {
                predictedBarPositions[i] = j
            }
        }
            
    }
    
}


