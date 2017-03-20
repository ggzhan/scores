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
    let fs: Float = 44100
    let windowSize: Float = 4096
    let SwaInstance: SwaBackEnd
    let refSoundFile: [Float]
    let testSoundFile: [Float]
    let refFeatures: [[Float]]
    let testFeatures: [[Float]]
    //let onlineAlignment: OnlineAlignment
    let onlineAlignment: COnlineAlignment
    var predictedPosition: [Float] = []
    var predictedBarPositions: [Float] = []
    private var refTime: [Float] = []
    
    //URL of recording, could be URL instead of [URL]. Would need to change the recording selection function
    init(soundFileURL: URL) {
        SwaInstance = SwaBackEnd()
        refSoundFile = SwaBackEnd.loadAudioSignal(audioURL: refURL!)
        testSoundFile = SwaBackEnd.loadAudioSignal(audioURL: soundFileURL)
        refFeatures = SwaInstance.extract_features(x: refSoundFile)
        testFeatures = SwaInstance.extract_features(x: testSoundFile)
        //onlineAlignment = OnlineAlignment(refFeatures: refFeatures)
        onlineAlignment = COnlineAlignment(refFeatures: refFeatures)
        //predictedPosition = UnsafeMutablePointer.allocate(capacity: testFeatures.count)
        extractRefTime()
        predictedBarPositions = Array(repeating: -1, count: refTime.count)  //-1 means there is no sound for the given bar
        findBars()
        
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
    func findBars(){
        for i in 0..<testFeatures.count {
            predictedPosition.append(onlineAlignment.align(v: testFeatures[i]))
        }
        print(predictedPosition)

        let predictedPositionInSeconds = positionToTime(position: predictedPosition)
      
        for i in 0..<predictedPositionInSeconds.count {
            var min: Float = 100
            //var bar: Int = -1
            //print("I: ", i)
            for j in 0..<refTime.count {
                if (min > abs(predictedPositionInSeconds[i] - refTime[j])) {
                    //print(abs(predictedPositionInSeconds[i] - refTime[j]), "  ", min)
                    min = abs(predictedPositionInSeconds[i] - refTime[j])
                }
            }
        }
        for i in 0..<refTime.count {
            var min: Float = 100
            //print("I: ", i)
            for j in 0..<predictedPositionInSeconds.count {
                //print("J: ", j)
                if (min > abs(predictedPositionInSeconds[j] - refTime[i])) {
                    //print(abs(predictedPositionInSeconds[j] - refTime[i]), "  ", min)
                    min = abs(predictedPositionInSeconds[j] - refTime[i])
                    predictedBarPositions[i] = testFileTime(j)          //not robust against jumps in positions
                }
            }
            print(predictedBarPositions[i])
        }
    }
    
    //convert aligned position to time
    //input: aligned position
    //output: time in audio file
    func positionToTime(position:  [Float]) -> [Float] {
        var seconds: [Float] = Array(repeating: 0.0, count: testFeatures.count)
        for i in 0..<position.count {
            seconds[i] = position[i]/(fs/windowSize) //fs/winSize = number of blocks
        }
        return seconds
    }
    
    
    //convert bar to referenceFile time from JSON
    //outputs the refTime that is stored in the JSON file
    private func extractRefTime() {
        var jsonObj: [String: AnyObject]!
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
    }
    
    func testFileTime(_ pos: Int) -> Float {
        let seconds = Float(pos)/(fs/windowSize)
        return seconds
    }

    
}
