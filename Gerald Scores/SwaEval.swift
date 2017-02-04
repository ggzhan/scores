//
//  Eval.swift
//  Gerald Scores
//
//  Created by Gerald Z on 20/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation
import AVFoundation

class SwaEval {
    let refURL = Bundle.main.url(forResource: "Ravel-Tzigane", withExtension: "wav")
    let fs: Float = 44100
    let windowSize: Float = 4096
    let soundFileURL: [URL]
    let predictedBarPositions: [Int]
    
    //URL of recording, could be URL instead of [URL]. Would need to change the recording selection function
    init(soundFileURL: [URL]) {
        self.soundFileURL = soundFileURL
        predictedBarPositions = findBars(soundFileURL: soundFileURL)
    }
    
    /*  //Don´t need for now
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
    */
    /* //Don´t need for now
    public func follower(soundFileURL: [URL]) {
        
        let SwaInstance = SwaBackEnd(recordings: soundFileURL)
        let refSoundFile = SwaBackEnd.loadAudioSignal(audioURL: soundFileURL[1])
        let testSoundFile = SwaBackEnd.loadAudioSignal(audioURL: soundFileURL[0])
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
    */
    func findBars(soundFileURL: [URL]) -> [Int] {
        let refURL = Bundle.main.url(forResource: "Ravel - Tzigane", withExtension: "wav")
        let SwaInstance = SwaBackEnd(recordings: soundFileURL)
        let refSoundFile = SwaBackEnd.loadAudioSignal(audioURL: refURL!)
        let testSoundFile = SwaBackEnd.loadAudioSignal(audioURL: soundFileURL[0])
        let refFeatures = SwaInstance.extract_features(x: refSoundFile)
        let testFeatures = SwaInstance.extract_features(x: testSoundFile)
        let onlineAlignment = OnlineAlignment(refFeatures: refFeatures)
        var predictedPosition: [Float] = Array(repeating: 0.0, count: testFeatures.count)
        for (i,chroma) in testFeatures.enumerated(){
            predictedPosition[i] = onlineAlignment.align(v: chroma)
        }
        //let predictedPositionInSeconds = predictedPosition.map{$0 / 10.8}
        
        let predictedBarPositions = timeToBar(predictedPositionInSeconds: positionToTime(position: predictedPosition))
        return predictedBarPositions
    }
    
    //convert aligned position to time
    //input: aligned position
    //output: time in audio file
    func positionToTime(position: [Float]) -> [Float] {
        let seconds: [Float] = position.map{$0 / (fs/windowSize)} //fs/winSize = number of blocks
        return seconds
    }
    
    //convert time to bar
    //maps aligned testSample time to bars from refSample
    func timeToBar(predictedPositionInSeconds: [Float]) -> [Int] {
        let refTime = extractRefTime()
        var predictedBarPositions = Array(repeating: 0, count: refTime.count)
        for i in 0..<predictedBarPositions.count {
            for j in 0..<refTime.count-1 {
                if (predictedPositionInSeconds[i] > refTime[j]) && (predictedPositionInSeconds[i] < refTime[j+1]) {
                    continue
                } else {
                    predictedBarPositions[i] = j
                }
            }
        }
        return predictedBarPositions
    }
    
    //convert bar to referenceFile time from JSON
    //outputs the refTime that is stored in the JSON file
    func extractRefTime() -> [Float] {
        var refTime: [Float] = []
        var jsonObj: [String: Float]!
        if let path = Bundle.main.path(forResource: "Tzigane_mapping", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Float]
                for i in 1...jsonObj.count {
                    refTime.append(jsonObj[String(i)]!) // refTime[1]: 3.234
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        return refTime
    }
    
    //play soundfile from bar
    func playFromBar(bar: Int) {
        let predictedBarPositions = findBars(soundFileURL: <#T##[URL]#>)//get the array
        let startTime = predictedBarPositions[bar]
        soundFileURL[0].seek  //TODO let audio play from startTime
    }
    
}
