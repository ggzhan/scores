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
    //let refURL = Bundle.main.url(forResource: "Ravel-Tzigane", withExtension: "wav")
    let fs: Float = 44100
    let windowSize: Float = 4096
    //let predictedBarPositions = findBars(soundFileURL: soundFileURL)
    let SwaInstance: SwaBackEnd
    let refSoundFile: [Float]
    let testSoundFile: [Float]
    let refFeatures: [[Float]]
    let testFeatures: [[Float]]
    let onlineAlignment: OnlineAlignment
    var predictedPosition: UnsafeMutablePointer<Float>
    
    //URL of recording, could be URL instead of [URL]. Would need to change the recording selection function
    init(soundFileURL: URL) {
        SwaInstance = SwaBackEnd()
        refSoundFile = SwaBackEnd.loadAudioSignal(audioURL: refURL!)
        testSoundFile = SwaBackEnd.loadAudioSignal(audioURL: soundFileURL)
        refFeatures = SwaInstance.extract_features(x: refSoundFile)
        testFeatures = SwaInstance.extract_features(x: testSoundFile)
        onlineAlignment = OnlineAlignment(refFeatures: refFeatures)
        predictedPosition = UnsafeMutablePointer.allocate(capacity: testFeatures.count)
    }
    
    deinit {
        predictedPosition.deallocate(capacity: testFeatures.count)
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
    func findBars(soundFileURL: URL) -> [Float] {
        /*for (i,chroma) in testFeatures.enumerated(){            // this part is really slow
            predictedPosition[i] = onlineAlignment.align(v: chroma)
        }
        */
        for i in 0..<testFeatures.count {
            predictedPosition[i] = onlineAlignment.align(v: testFeatures[i])
        }
        
        let predictedBarPositions = timeToBar(predictedPositionInSeconds: positionToTime(position: predictedPosition))
        return predictedBarPositions
    }
    
    //convert aligned position to time
    //input: aligned position
    //output: time in audio file
    func positionToTime(position:  UnsafeMutablePointer<Float>) -> [Float] {
        var seconds: [Float] = Array(repeating: 0.0, count: testFeatures.count)
        for i in 0..<testFeatures.count {
            seconds[i] = position[i]/(fs/windowSize) //fs/winSize = number of blocks/chromavectors
        }
        return seconds
    }
    
    //convert time to bar
    //maps aligned testSample time to bars from refSample
    func timeToBar(predictedPositionInSeconds: [Float]) -> [Float] {
        let refTime = extractRefTime()
        var predictedBarPositions: [Float] = Array(repeating: -1, count: refTime.count)  //-1 means there is no sound for the given bar
        for i in 0..<predictedBarPositions.count {
            for j in 0..<refTime.count-1 {
                if (predictedPositionInSeconds[i] > Float(refTime[j])) && (predictedPositionInSeconds[i] < Float(refTime[j+1])) {
                    continue
                } else {
                    predictedBarPositions[i] = predictedPositionInSeconds[i]
                }
            }
        }
        return predictedBarPositions
    }
    
    //convert bar to referenceFile time from JSON
    //outputs the refTime that is stored in the JSON file
    func extractRefTime() -> [Float] {
        var jsonObj: [String: AnyObject]!
        var refTime: [Float] = []
        if let path = Bundle.main.path(forResource: "Tzigane_mapping", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                for i in 1...jsonObj.count {
                    refTime.append(jsonObj[String(i)]! as! Float)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        return refTime
    }
    
    
}
