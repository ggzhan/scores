//
//  SpectralViewController.swift
//  Gerald Scores
//
//  Created by Gerald Z on 14/12/16.
//  Copyright © 2016 Gerald Z. All rights reserved.
//

import UIKit
import AVFoundation

class SpectralViewController: UIViewController {
    
    var soundFileURL: URL!
    var spectralView: SpectralView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spectralView = SpectralView(frame: self.view.bounds)
        spectralView.backgroundColor = UIColor.black
        self.view.addSubview(spectralView)
        
        //let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
        //    self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        //}
        
        //audioInput.startRecording()
    }
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: 44100.0)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        
        // Interpoloate the FFT data so there's one band per pixel.
        let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
        fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: Int(screenWidth))
        
        tempi_dispatch_main { () -> () in
            self.spectralView.fft = fft
            self.spectralView.setNeedsDisplay()
        }
    }
    
    func tempi_dispatch_main(closure:@escaping ()->()) {
        DispatchQueue.main.async {
            closure()
        }
    }
    
    override func didReceiveMemoryWarning() {
        NSLog("*** Memory!")
        super.didReceiveMemoryWarning()
    }
}
