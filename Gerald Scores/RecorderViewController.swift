//
//  ViewController.swift
//  Gerald Scores
//
//  Created by Gerald Z on 12/12/16.
//  Copyright © 2016 Gerald Z. All rights reserved.
//

import UIKit
import Darwin
import AVFoundation

/**
 
 Uses AVAudioRecorder to record a sound file and an AVAudioPlayer to play it back.
 
 
 
 */
class RecorderViewController: UIViewController {
 
 var recorder: AVAudioRecorder!
 
 var player:AVAudioPlayer!
 
 @IBOutlet var recordButton: UIButton!
 
 @IBOutlet var stopButton: UIButton!
 
 @IBOutlet var playButton: UIButton!
 
 @IBOutlet var statusLabel: UILabel!
 
 
 var meterTimer:Timer!
 
 var soundFileURL:URL!
 
 override func viewDidLoad() {
  super.viewDidLoad()
  
  stopButton.isEnabled = false
  playButton.isEnabled = false
  setSessionPlayback()
  askForNotifications()
  checkHeadphones()
  listRecordings()
  
 }
 
 public var recordings = [URL]()
 
 func listRecordings() {
  
  let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  do {
   let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
   recordings = urls.filter( { (name: URL) -> Bool in
    return name.lastPathComponent.hasSuffix("m4a")
   })
   
  } catch let error as NSError {
   print(error.localizedDescription)
  } catch {
   print("something went wrong listing recordings")
  }
  
 }
 
 
 func updateAudioMeter(_ timer:Timer) {
  
  if recorder.isRecording {
   let min = Int(recorder.currentTime / 60)
   let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
   let s = String(format: "%02d:%02d", min, sec)
   statusLabel.text = s
   recorder.updateMeters()
   // if you want to draw some graphics...
   //var apc0 = recorder.averagePower(forChannel: 0)
   //var peak0 = recorder.peakPower(forChannel:0)
  }
 }
 
 
 override func didReceiveMemoryWarning() {
  super.didReceiveMemoryWarning()
  recorder = nil
  player = nil
 }
 
 @IBAction func removeAll(_ sender: AnyObject) {
  deleteAllRecordings()
 }
 
 @IBAction func record(_ sender: UIButton) {
  
  if player != nil && player.isPlaying {
   player.stop()
  }
  
  if recorder == nil {
   print("recording. recorder nil")
   recordButton.setTitle("Pause", for:UIControlState())
   playButton.isEnabled = false
   stopButton.isEnabled = true
   recordWithPermission(true)
   return
  }
  
  if recorder != nil && recorder.isRecording {
   print("pausing")
   recorder.pause()
   recordButton.setTitle("Continue", for:UIControlState())
   
  } else {
   print("recording")
   recordButton.setTitle("Pause", for:UIControlState())
   playButton.isEnabled = false
   stopButton.isEnabled = true
   //            recorder.record()
   recordWithPermission(false)
  }
 }
 
 @IBAction func stop(_ sender: UIButton) {
  print("stop")
  
  recorder?.stop()
  player?.stop()
  
  meterTimer.invalidate()
  
  recordButton.setTitle("Record", for:UIControlState())
  let session = AVAudioSession.sharedInstance()
  do {
   try session.setActive(false)
   playButton.isEnabled = true
   stopButton.isEnabled = false
   recordButton.isEnabled = true
  } catch let error as NSError {
   print("could not make session inactive")
   print(error.localizedDescription)
  }
  
  //recorder = nil
 }
 
 @IBAction func play(_ sender: UIButton) {
  setSessionPlayback()
  play()
 }
 
 func play() {
  
  var url:URL?
  if self.recorder != nil {
   url = self.recorder.url
  } else {
   url = self.soundFileURL!
  }
  print("playing \(url)")
  
  do {
   self.player = try AVAudioPlayer(contentsOf: url!)
   stopButton.isEnabled = true
   player.delegate = self
   player.prepareToPlay()
   player.volume = 1.0
   player.play()
  } catch let error as NSError {
   self.player = nil
   print(error.localizedDescription)
  }
  
 }
 
 
 func setupRecorder() {
  let format = DateFormatter()
  format.dateFormat="yyyy-MM-dd-HH-mm-ss"
  let currentFileName = "recording-\(format.string(from: Date())).m4a"
  print(currentFileName)
  
  let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
  print("writing to soundfile url: '\(soundFileURL!)'")
  
  if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
   // probably won't happen. want to do something about it?
   print("soundfile \(soundFileURL.absoluteString) exists")
  }
  
  
  let recordSettings:[String : AnyObject] = [
   AVFormatIDKey:             NSNumber(value: kAudioFormatAppleLossless),
   AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
   AVEncoderBitRateKey :      NSNumber(value:320000),
   AVNumberOfChannelsKey:     NSNumber(value:2),
   AVSampleRateKey :          NSNumber(value:44100.0)
  ]
  
  do {
   recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
   recorder.delegate = self
   recorder.isMeteringEnabled = true
   recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
  } catch let error as NSError {
   recorder = nil
   print(error.localizedDescription)
  }
  
 }
 
 func recordWithPermission(_ setup:Bool) {
  let session:AVAudioSession = AVAudioSession.sharedInstance()
  // ios 8 and later
  if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
   AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
    if granted {
     print("Permission to record granted")
     self.setSessionPlayAndRecord()
     if setup {
      self.setupRecorder()
     }
     self.recorder.record()
     self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                            target:self,
                                            selector:#selector(RecorderViewController.updateAudioMeter(_:)),
                                            userInfo:nil,
                                            repeats:true)
    } else {
     print("Permission to record not granted")
    }
   })
  } else {
   print("requestRecordPermission unrecognized")
  }
 }
 
 func setSessionPlayback() {
  let session:AVAudioSession = AVAudioSession.sharedInstance()
  
  do {
   try session.setCategory(AVAudioSessionCategoryPlayback)
  } catch let error as NSError {
   print("could not set session category")
   print(error.localizedDescription)
  }
  do {
   try session.setActive(true)
  } catch let error as NSError {
   print("could not make session active")
   print(error.localizedDescription)
  }
 }
 
 func setSessionPlayAndRecord() {
  let session = AVAudioSession.sharedInstance()
  do {
   try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
  } catch let error as NSError {
   print("could not set session category")
   print(error.localizedDescription)
  }
  do {
   try session.setActive(true)
  } catch let error as NSError {
   print("could not make session active")
   print(error.localizedDescription)
  }
 }
 
 func deleteAllRecordings() {
  let docsDir =
   NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  
  let fileManager = FileManager.default
  
  do {
   let files = try fileManager.contentsOfDirectory(atPath: docsDir)
   var recordings = files.filter( { (name: String) -> Bool in
    return name.hasSuffix("m4a")
   })
   for i in 0 ..< recordings.count {
    let path = docsDir + "/" + recordings[i]
    
    print("removing \(path)")
    do {
     try fileManager.removeItem(atPath: path)
    } catch let error as NSError {
     NSLog("could not remove \(path)")
     print(error.localizedDescription)
    }
   }
   
  } catch let error as NSError {
   print("could not get contents of directory at \(docsDir)")
   print(error.localizedDescription)
  }
  
 }
 
 func askForNotifications() {
  
  NotificationCenter.default.addObserver(self,
                                         selector:#selector(RecorderViewController.background(_:)),
                                         name:NSNotification.Name.UIApplicationWillResignActive,
                                         object:nil)
  
  NotificationCenter.default.addObserver(self,
                                         selector:#selector(RecorderViewController.foreground(_:)),
                                         name:NSNotification.Name.UIApplicationWillEnterForeground,
                                         object:nil)
  
  NotificationCenter.default.addObserver(self,
                                         selector:#selector(RecorderViewController.routeChange(_:)),
                                         name:NSNotification.Name.AVAudioSessionRouteChange,
                                         object:nil)
 }
 
 func background(_ notification:Notification) {
  print("background")
 }
 
 func foreground(_ notification:Notification) {
  print("foreground")
 }
 
 
 func routeChange(_ notification:Notification) {
  print("routeChange \((notification as NSNotification).userInfo)")
  
  if let userInfo = (notification as NSNotification).userInfo {
   //print("userInfo \(userInfo)")
   if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
    //print("reason \(reason)")
    switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
    case AVAudioSessionRouteChangeReason.newDeviceAvailable:
     print("NewDeviceAvailable")
     print("did you plug in headphones?")
     checkHeadphones()
    case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
     print("OldDeviceUnavailable")
     print("did you unplug headphones?")
     checkHeadphones()
    case AVAudioSessionRouteChangeReason.categoryChange:
     print("CategoryChange")
    case AVAudioSessionRouteChangeReason.override:
     print("Override")
    case AVAudioSessionRouteChangeReason.wakeFromSleep:
     print("WakeFromSleep")
    case AVAudioSessionRouteChangeReason.unknown:
     print("Unknown")
    case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
     print("NoSuitableRouteForCategory")
    case AVAudioSessionRouteChangeReason.routeConfigurationChange:
     print("RouteConfigurationChange")
     
    }
   }
  }
 }
 
 func checkHeadphones() {
  // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
  let currentRoute = AVAudioSession.sharedInstance().currentRoute
  if currentRoute.outputs.count > 0 {
   for description in currentRoute.outputs {
    if description.portType == AVAudioSessionPortHeadphones {
     print("headphones are plugged in")
     break
    } else {
     print("headphones are unplugged")
    }
   }
  } else {
   print("checking headphones requires a connection to a device")
  }
 }
 
 // turning audio file into float array: http://stackoverflow.com/questions/34751294/how-can-i-generate-an-array-of-floats-from-an-audio-file-in-swift
 func loadAudioSignal(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int) {
  let file = try! AVAudioFile(forReading: audioURL as URL!)
  let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
  let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
  try! file.read(into: buf) // maybe need better error handling
  let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
  return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
 }
 
 
 
 
 @IBOutlet weak var fourierB: UIButton!
 
 @IBAction func fourierB(_ sender: Any) {
  if recordings.count < 1
  {
   print("no recordings!")
  } else
  {
   
      
   follower(soundFileURL: recordings)
  }
 }
}




// MARK: AVAudioRecorderDelegate
extension RecorderViewController : AVAudioRecorderDelegate {
 
 func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                      successfully flag: Bool) {
  print("finished recording \(flag)")
  stopButton.isEnabled = false
  playButton.isEnabled = true
  recordButton.setTitle("Record", for:UIControlState())
  
  // iOS8 and later
  let alert = UIAlertController(title: "Recorder",
                                message: "Finished Recording",
                                preferredStyle: .alert)
  alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: {action in
   print("keep was tapped")
   self.recorder = nil
  }))
  alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in
   print("delete was tapped")
   self.recorder.deleteRecording()
  }))
  self.present(alert, animated:true, completion:nil)
 }
 
 func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                       error: Error?) {
  
  if let e = error {
   print("\(e.localizedDescription)")
  }
 }
 
}

// MARK: AVAudioPlayerDelegate
extension RecorderViewController : AVAudioPlayerDelegate {
 func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
  print("finished playing \(flag)")
  recordButton.isEnabled = true
  stopButton.isEnabled = false
 }
 
 func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
  if let e = error {
   print("\(e.localizedDescription)")
  }
  
 }
}

