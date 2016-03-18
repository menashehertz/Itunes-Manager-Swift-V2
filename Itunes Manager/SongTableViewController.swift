//
//  SongTableViewController.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/14/15.
//  Copyright © 2015 Steven Hertz. All rights reserved.


import UIKit
import CoreData

class SongTableViewController: UITableViewController {
    
    var messageFromCallingScreen = "Was not updated"
    var collectionId : NSNumber = 0
    var album: Album!
    
    var itunesOne = ItunesSongs.oneSession

    func displayError(errorString: String?) {
        if let errorString = errorString {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                let action = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {(paramAction:UIAlertAction!) in print("The Done button was tapped - " + paramAction.title!)})
                
                alertController.addAction(action)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }

    // MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if album.songs.isEmpty {
            
            // do not get new pictures if there are saved old ones
            
            ItunesSongs.oneSession.getSongsFromItunes({ (success, errorString) in
                if success {
                    print("Getting songs was success")
                    dispatch_async(dispatch_get_main_queue()){
                        self.tableView.reloadData()
                    }
                } else {
                    self.displayError(errorString)
                    print("From button - didn't get song data")
                }
            })
        } else {
            print("did not have to get songs")
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(messageFromCallingScreen)
        print("This is from ItunesController \(ItunesSongs.oneSession.collectionId)")
        print("From SongtableViewController about to call the itunesSong to get the songs")
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - CoreData Convinience
    
    lazy var sharedContext: NSManagedObjectContext = {
       return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return album.songs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songIdentifier", forIndexPath: indexPath)
        
        let currentRow = album.songs[indexPath.row]
        cell.textLabel?.text = currentRow.trackName


        // Configure the cell...

        return cell
    }

 
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let song = album.songs[indexPath.row]
            song.album = nil
            // album.songs.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            sharedContext.deleteObject(song)
            saveContext()
            
        default:
            break
        }
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            itunesOne.listofSongs.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "MasterToDetail" {
            let songDetailViewController = segue.destinationViewController as! SongDetailViewController
            print("in prepare for segue")
            

            
            let selectedRow = self.tableView.indexPathForSelectedRow
            let song = album.songs[selectedRow!.row]

            songDetailViewController.song = song
//            ItunesSongs.oneSession.collectionId  = currentRow.collectionId
//            ItunesSongs.oneSession.currentAlbum = currentRow
            
            // songTableViewController.navigationItem.title = currentRow.collectionName
        }
    }
    

}
