//
//  RecordViewController.swift
//  RubberDuck
//
//  Created by Mia Berthier on 2021-01-15.
//

import UIKit
import AVFoundation
import FirebaseStorage

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
            
            convertAudio(getDirectory().appendingPathComponent(".m4a"), outputURL: getDirectory().appendingPathComponent(".wav"))
            uploadToCloud()
            
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
    
    //upload function
    func uploadToCloud(){
        let storage = Storage.storage()
        let metadata = StorageMetadata()
        metadata.contentType = ".wav file"
        let storeRef = storage.reference()
        let fileRef = storeRef.child("audiofile.wav")
        let fileName = getDirectory().appendingPathComponent(".wav")
        
        fileRef.putFile(from: fileName, metadata: metadata){
            (metadata, err) in
            guard let metadata = metadata else{
                print(err?.localizedDescription)
                return
            }
            print("Uploaded")
        }
    }
    
    
    //convert to wav
    func convertAudio(_ url: URL, outputURL: URL) {
        var error : OSStatus = noErr
        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile : ExtAudioFileRef? = nil

        var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()

        ExtAudioFileOpenURL(url as CFURL, &sourceFile)

        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))

        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)

        dstFormat.mSampleRate = 44100  //Set sample rate
        dstFormat.mFormatID = kAudioFormatLinearPCM
        dstFormat.mChannelsPerFrame = 1
        dstFormat.mBitsPerChannel = 16
        dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked |
        kAudioFormatFlagIsSignedInteger

        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            kAudioFileWAVEType,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)
        print("Error 1 in convertAudio: \(error.description)")

        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 2 in convertAudio: \(error.description)")

        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 3 in convertAudio: \(error.description)")

        let bufferByteSize : UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: 32768)
        var sourceFrameOffset : ULONG = 0

        while(true){
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames : UInt32 = 0

            if(dstFormat.mBytesPerFrame > 0){
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }

            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            print("Error 4 in convertAudio: \(error.description)")

            if(numFrames == 0){
                error = noErr;
                break;
            }

            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            print("Error 5 in convertAudio: \(error.description)")
        }

        error = ExtAudioFileDispose(destinationFile!)
        print("Error 6 in convertAudio: \(error.description)")
        error = ExtAudioFileDispose(sourceFile!)
        print("Error 7 in convertAudio: \(error.description)")
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
