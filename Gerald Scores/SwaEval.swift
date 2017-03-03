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
        /* not working yet
         let predictedPositionRegression = linearRegression(predictedPosition) //Regression used for testing. introduced an offset, which wasn`t good
        
         let predictedPositionSmooth = smooth(predictedPosition)
        //printing out the array
        for i in 0..<predictedPositionRegression.count {
            print(predictedPositionSmooth[i])
        }
         */
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
    
    func average(_ input: [Float]) -> Float {
        return input.reduce(0, +) / Float(input.count)
    }
    
    func average(_ input: [Int]) -> Float {
        return Float(input.reduce(0, +)) / Float(input.count)
    }
    
    // Muss das wirklich sein....
    func multiply(_ a: [Float], _ b: [Int]) -> [Float] {
        var ret: [Float] = []
        for i in 0..<a.count {
            ret.append(a[i] * Float(b[i]))
        }
        return ret
    }
    
    func multiply(_ a: [Float], _ b: [Float]) -> [Float] {
        return zip(a,b).map(*)
    }
    
    func linearRegression(_ posX: [Float]) -> [Float] {
        let posY = Array(0...posX.count)
        let sum1 = average(multiply(posX, posY)) - average(posX) * average(posY)
        let sum2 = average(zip(posX, posX).map(*)) - powf(average(posX), 2)
        let slope = sum1 / sum2
        let intercept = average(posY) - slope * average(posX)
        var ret: [Float] = []
        for i in 0..<posX.count {
            ret.append((Float(posY[i])-intercept) / slope)
        }
        return ret
    }
    
    func derivitave(_ input: [Float]) -> [Float] {
        var ret: [Float] = []
        for i in 0..<input.count-1 {
            ret.append(input[i+1]-input[i])
        }
        return ret
    }
    
    
    //Counter system not working. Need to implement a gaussian smoothing beforehand. And a segmentation algorithm together with slope as a condition would be much better.
    func smooth(_ input: [Float]) -> [Float] {
        let threshold: Float = 150
        let d_input = derivitave(input)
        var jumpCounter: Int = 0
        var ret = input
        var leftValue: [Float] = [] //random wrong number for debugging
        var rightValue: [Float] = [] //random wrong number for debugging
        var leftIndex: [Int] = []
        var rightIndex: [Int] = []
        
        
        //find the points before and after the jumps
        for i in 5..<d_input.count {
            if abs(d_input[i]) > threshold && d_input[i] > 0 && jumpCounter == 0 {   //positive jump
                jumpCounter += 1
                leftValue.append(input[i])
                leftIndex.append(i)
            }
            if abs(d_input[i]) > threshold && d_input[i] < 0 && jumpCounter > 0 {   //negative jump after pos jump
                jumpCounter -= 1
                rightValue.append(input[i+1])
                rightIndex.append(i)
            }
            if abs(d_input[i]) > threshold && d_input[i] < 0 && jumpCounter == 0 {   //negative jump
                jumpCounter -= 1
                leftValue.append(input[i])
                leftIndex.append(i)
            }
            if abs(d_input[i]) > threshold && d_input[i] > 0 && jumpCounter < 0 {   //positive jump after neg jump
                jumpCounter += 1
                rightValue.append(input[i+1])
                rightIndex.append(i)
            }
        }
        
        //smooth the jumps
        for i in 0..<min(leftIndex.count, rightIndex.count) {
            var slope: Float = 1
            var offset: Float = 0
            if leftValue[i]==rightValue[i] {
                slope = 1
                offset = leftValue[i]
            } else {
                slope = Float(rightIndex[i] - leftIndex[i]) / (rightValue[i] - leftValue[i])
                offset = Float(leftIndex[i]) - slope*leftValue[i]
            }
            for j in leftIndex[i]...rightIndex[i] {
                ret[j] = (Float(j) - offset) / slope
                print("j: ", j)
            }
        }
        return ret
    }
    
    
}
