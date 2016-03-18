//
//  SongDetailViewController.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/19/15.
//  Copyright © 2015 Steven Hertz. All rights reserved.


import UIKit
import MediaPlayer
import AVKit

class SongDetailViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate, AVAudioPlayerDelegate {

    var song: Song!
    var songNote: SongNote!
    var songNoteArray : [SongNote]!
    var indexIntoArray : Int?
    var likeLevel: Int!
    var pickerSelection : Int = 0
    let pickerData = ["No Opinion", "Pretty Bad","Weak","Average","Not bad","Pretty Good", "Great", "Superb"]    
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var myPicker: UIPickerView!
    @IBOutlet weak var playButton: UIButton!
    
    /* The delegate - finished playing an audio file */
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
            playButton.enabled = true
            print("Finished playing the song")
    }
    
    @IBAction func preViewTheSong(sender: AnyObject) {
        (sender as! UIButton).enabled = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let url = NSURL(string: song.previewUrl)
        
        HttpDownloader.loadFileAsync(url!, completion:{(pathToFile: String, error:NSError!)
            in
            print("file downloaded: \(pathToFile)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            let dispatchQueue =
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            dispatch_async(dispatchQueue, {
                let fileData = NSData(contentsOfFile: pathToFile)
                
                do {
                    /* Start the audio player */
                    self.audioPlayer = try AVAudioPlayer(data: fileData!)
                    
                    guard let player = self.audioPlayer else{
                        print("Could not setup the music player")
                        return
                    }
                    
                    player.delegate = self
                    if player.prepareToPlay() && player.play(){
                        /* Successfully started playing */
                    } else {
                        print("Could not play the file")
                    }
                } catch{
                    print("Could not instantiate the audio play")
                    self.audioPlayer = nil
                    return
                }
            })
        })

    }
    
    //MARK: - Delegates and data sources for PickerView

    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelection = [row][0]
        likeLevel = [row][0]
        print(pickerSelection)
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
           
            let hue = CGFloat(row)/CGFloat(pickerData.count)
            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .Center
        
        return pickerLabel
        
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }

    //MARK: - Life Cycle functions

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        myPicker.selectRow(likeLevel as Int, inComponent: 0, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPicker.delegate = self
        myPicker.dataSource = self
        

        notesText.layer.cornerRadius = 8.0
        notesText.layer.masksToBounds = true
        notesText.layer.borderColor = UIColor.grayColor().CGColor
        notesText.layer.borderWidth = 2.0
        
        // Unarchive the graph when the list is first shown
        self.songNoteArray = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [SongNote] ?? [SongNote]()
        
        trackNameLabel.text = song.trackName
        let indexOfDictTrkValue = (songNoteArray.map({$0.trackId})).indexOf(song.trackId)
        
        if let indexOfDictTrkValue = indexOfDictTrkValue {
            notesText.text = songNoteArray[indexOfDictTrkValue].note
            indexIntoArray = indexOfDictTrkValue
            songNote = songNoteArray[indexOfDictTrkValue]
            likeLevel = songNote.likeLevel as Int
        } else {
            likeLevel = 0
        }
        print("this is likelevel in viewdidload", likeLevel)

        notesText.becomeFirstResponder()
  
    }

    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
            self.audioPlayer = nil
        }
        
        if (self.isMovingFromParentViewController()){
            
            if let indexIntoArray = indexIntoArray {
                songNoteArray.removeAtIndex(indexIntoArray)
            }

            let sn1 = SongNote(trackId: song.trackId, note: notesText.text!, likeLevel: likeLevel as NSNumber)
            songNoteArray.append(sn1)
            
            // Archive the graph any time this list of actors is displayed.
            NSKeyedArchiver.archiveRootObject(songNoteArray, toFile: filePath)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    
    // MARK: -  Helper.
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("notesArray").path!
    }
    


}
