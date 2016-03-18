//
//  ItunesTableViewController.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/13/15.
//  Copyright © 2015 Steven Hertz. All rights reserved.
//

import UIKit
import CoreData

class ItunesTableViewController: UITableViewController, AlbumPickerViewControllerDelegate {
    

    var musicAlbumArray = [Album]()
    var albums = [Album]()
    var itunesOne = ItunesAlbums.oneSession
   
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func fetchAllAlbums() -> [Album] {
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Album")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Album]
        } catch  let error as NSError {
            print("Error in fetchAllAlbums(): \(error)")
            return [Album]()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.tableView.rowHeight = 85.0
        print("In viewDidLoad")
        albums = fetchAllAlbums()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addAlbum")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("willappear")
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func addAlbum() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AlbumPickerViewController") as! AlbumPickerViewController
        controller.delegate = self
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    // MARK: - Album Picker Delegate
    
    func albumPicker(albumPicker: AlbumPickerViewController, didPickAlbum album: Album?) {
        print("returned from picker with album")
        
        if let newAlbum = album {
            
            // Debugging output
            print("picked Album with name: \(newAlbum.collectionName),  id: \(newAlbum.collectionId)")
            
            // Check to see if we already have this Album. If so, return.
            for a in albums {
                if a.collectionId == newAlbum.collectionId {
                    print("It is already added - don't add it again")
                    return
                }
            }

            let dictionary: [String : AnyObject] = [
                "collectionId" : newAlbum.collectionId,
                "collectionName" : newAlbum.collectionName,
                "artworkUrl60" : newAlbum.artworkUrl60 ,
                "artworkUrl100" : newAlbum.artworkUrl100,
                "collectionViewUrl" : newAlbum.collectionViewUrl
            ]
            
            let albumToBeAdded = Album(theDict: dictionary, context: sharedContext)
           
            self.albums.append(albumToBeAdded)

            CoreDataStackManager.sharedInstance().saveContext()

            tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albums.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let currentRow = albums[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("customCell", forIndexPath: indexPath) as! AlbumTableViewCell
        cell.nameLabel.text = currentRow.collectionName
        cell.albumImageView.image = UIImage(named: "Blank52")

        let imageURL = NSURL(string: currentRow.artworkUrl60)
        if let imageData = NSData(contentsOfURL: imageURL!) {
            cell.albumImageView.image = UIImage(data: imageData)
        }
        return cell
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("We selected a row, Great! Row clicked was \(indexPath.row)")
        
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch (editingStyle) {
        case .Delete:
            let album = albums[indexPath.row]
            
            // Remove the actor from the array
            albums.removeAtIndex(indexPath.row)
            
            // Remove the row from the table
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // Remove the actor from the context
            sharedContext.deleteObject(album)
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            break
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "getTheDetail" {
            let songTableViewController = segue.destinationViewController as! SongTableViewController
            print("in prepare for segue")
            let selectedRow = self.tableView.indexPathForSelectedRow
            let currentRow = albums[selectedRow!.row]
            songTableViewController.messageFromCallingScreen = currentRow.collectionName
            songTableViewController.collectionId = currentRow.collectionId
            songTableViewController.album = currentRow

            ItunesSongs.oneSession.collectionId  = currentRow.collectionId
            ItunesSongs.oneSession.currentAlbum = currentRow
            
            songTableViewController.navigationItem.title = currentRow.collectionName
        }
    }
    


}
