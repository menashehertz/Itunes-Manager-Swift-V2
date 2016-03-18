//
//  AlbumPickerViewController.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/15/15.
//  Copyright © 2015 Steven Hertz. All rights reserved.
//

import UIKit


protocol AlbumPickerViewControllerDelegate {
    func albumPicker(albumPicker: AlbumPickerViewController, didPickAlbum album: Album?)
}

class AlbumPickerViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var itunesOne = ItunesAlbums.oneSession
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    
    
    // The delegate will typically be a view controller, waiting for the Actor Picker
    // to return an actor
    var delegate: AlbumPickerViewControllerDelegate?
    

    // The most recent data download task. We keep a reference to it so that it can
    // be canceled every time the search text changes
    var searchTask: NSURLSessionDataTask?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar.becomeFirstResponder()
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        self.delegate?.albumPicker(self, didPickAlbum: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Search Bar Delegate
    
    // Each time the search text changes we want to cancel any current download and start a new one
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Cancel the last task
        if let task = searchTask {
            print("cancelling task")
            task.cancel()
        }
        
        // If the text is empty we are done
        if searchText == "" {
            itunesOne.listofAlbums = [Album]()
            tableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        // Get the albums
        searchTask = ItunesAlbums.oneSession.getAlbumsFromItunes(searchText, completionHandler: { (success, errorString) in
            if success {
                print(" Got the albums")
                dispatch_async(dispatch_get_main_queue()){
                    self.tableView.reloadData()
                }
            } else {
                print(errorString)
                if errorString != "cancelled - error in datatask" {
                    self.displayError(errorString)
                }
            }
        })
        
    }
    

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

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    
    //MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itunesOne.listofAlbums.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuse", forIndexPath: indexPath) as UITableViewCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        let currentRow = itunesOne.listofAlbums[indexPath.row]
        cell.textLabel?.text = currentRow.collectionName

        return cell
    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("In album Picker did select row at index path")
        let album = itunesOne.listofAlbums[indexPath.row]
        
        // Alert the delegate
        delegate?.albumPicker(self, didPickAlbum: album)
        
        itunesOne.listofAlbums.removeAll()
        self.dismissViewControllerAnimated(true, completion: nil)
 
    }
    
}
