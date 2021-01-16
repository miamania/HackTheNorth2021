//
//  RecordViewController.swift
//  RubberDuck
//
//  Created by Mia Berthier on 2021-01-15.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    //var numberOfRecords = 0
    
    @IBOutlet weak var buttonLabel: UIButton!
    
    @IBOutlet weak var playButtonLabel: UIButton!
    
    @IBOutlet weak var analyzeButtonLabel: UIButton!
    
    
    @IBAction func record(_ sender: Any) {
        //Check if we have active recorder
        if audioRecorder == nil {
            //numberOfRecords += 1
            //let fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            let fileName = getDirectory().appendingPathComponent(".m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start Audio recording
            do{
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                buttonLabel.setTitle("Stop Recording", for: .normal)
                
                
            } catch {
                displayAlert(title: "Oops!", message: "Recording failed.")
            }
            
        } else {
            //Stop Audio Recording
            audioRecorder.stop()
            audioRecorder = nil
            
            buttonLabel.setTitle("Start Recording", for: .normal)
            playButtonLabel.isHidden = false
            analyzeButtonLabel.isHidden = false
        }
        
        
    }
    
    @IBAction func playRecording(_ sender: Any) {
        let path = getDirectory().appendingPathComponent(".m4a")
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        }
        catch{
            displayAlert(title: "Oops", message: "Not playing recording")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission{
                print ("Accepted")
            }
        }
        
        playButtonLabel.isHidden = true
        analyzeButtonLabel.isHidden = true
    }
    
    
    //FUNCTION GET PATH TO DIR
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //FUNCTION DISPLAYS ALERT
    func displayAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
