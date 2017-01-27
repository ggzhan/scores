//
//  Follower.swift
//  Gerald Scores
//
//  Created by Gerald Z on 19/01/17.
//  Copyright © 2017 Gerald Z. All rights reserved.
//

import Foundation

public func follower(soundFileURL: [URL]) {
    let fs = 44100
    let windowSize = 8192/2
    let windowOffset = 4096
    let refSoundFile = RecorderViewController().loadAudioSignal(audioURL: soundFileURL[1])
    let testSoundFile = RecorderViewController().loadAudioSignal(audioURL: soundFileURL[0])

    let refFeatures = extract_features(x: refSoundFile.signal, winSize: windowSize, winOffset: windowOffset)
    let testFeatures = extract_features(x: testSoundFile.signal, winSize: windowSize, winOffset: windowOffset)

    let onlineAlignment = OnlineAlignment(refFeatures: refFeatures)

    let (predictedPosition, actualPosition, errors) = evaluate_OnlineAlignment(testFeatures: testFeatures, oa: onlineAlignment)
    /*
    print(refFeatures)
    print(testFeatures)
     */
    print(refSoundFile.frameCount)
    print(errors)
    print(predictedPosition)
    print(actualPosition)
    
}

public func follower_p(soundFileURL: [URL]) {
    let fs = 44100
    let windowSize = 8192/2
    let windowOffset = 4096
 
    let swa = Swa(recordings: soundFileURL)
    
    let (refFeatures, testFeatures) = swa.getFeatures(recordings: soundFileURL)
    let onlineAlignment = OnlineAlignment_p(refFeatures: refFeatures, length: swa.getSoundFile(soundFileURL: soundFileURL[1]).length)
    
    let (predictedPosition, actualPosition, errors) = swa.evaluate_OnlineAlignment(testFeatures: testFeatures, length: swa.getSoundFile(soundFileURL: soundFileURL[0]).length, oa: onlineAlignment)

    /*
     print(refFeatures)
     print(testFeatures)
     */
 
    print(errors)
    print(predictedPosition)
    print(actualPosition)
    
}
