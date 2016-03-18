//
//  ItunesSongs.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/14/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ItunesSongs {
    
    static let oneSession = ItunesSongs()
    
//    enum Error : ErrorType {
//        case InvalidJson
//        case KeyNotFound
//    }
    
    let baseUrl = "https://itunes.apple.com/lookup?id="
    let parms: [String : AnyObject] = [
        "entity": "song",
        "limit": "9"]
    
    
    var currentAlbum : Album?
    var collectionId : NSNumber = 111
    var listofSongs = [Song]()
    
    var songNoteArray = [SongNote]()
    
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
        }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
 
    func getSongsFromItunes(completionHandler: ( success: Bool, errorString: String) -> Void) {
    //func getSongsFromItunes () {
       
        //let urlPath = "https://itunes.apple.com/lookup?id=\(collectionId)&entity=song&limit=9"
        let urlPath = "\(baseUrl)\(collectionId)\(escapedParameters(parms))"

        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in

            guard error == nil
                else {completionHandler(success: false, errorString: error!.localizedDescription); return}
                //else {print("In Guard Error - ", error!.localizedDescription); return}
            
            // let theString:NSString = NSString(data: data!, encoding: NSASCIIStringEncoding)!
            // print(theString)
            
            do {
                // Try parsing some valid JSON
                guard let parsed = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject]
                    else {completionHandler(success: false, errorString: "error in NSJSONSerialization.JSONObjectWithData"); return}
                guard let results = parsed["results"] as? [[String : AnyObject]]
                    else {completionHandler(success: false, errorString: "error in converting the dictionary"); return}

                self.listofSongs.removeAll(keepCapacity: false)
                for result in results {
                    if let wrapperType = result["wrapperType"] as? String {
                     if wrapperType == "track" {
                        // print(result["trackName"]!)
                        dispatch_async(dispatch_get_main_queue()){
                            let newSong = Song(theDict: result, context: self.sharedContext)
                            newSong.album = self.currentAlbum
                            self.listofSongs.append(newSong)
                        }
                        dispatch_async(dispatch_get_main_queue()){
                            self.saveContext()
                        }
                        }
                    }
                }
                completionHandler(success: true, errorString: "No error")
            }
            catch let error as NSError {
                // Catch fires here, with an NSErrro being thrown from the JSONObjectWithData method
                print("A JSON parsing error occurred, here are the details:\n \(error)")
            }
        })
        
        // The task is just an object with all these properties set
        // In order to actually make the web request, we need to "resume"
        task.resume()
        
    }
    
    // URL Encoding a dictionary into a parameter string
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "&" : "") + urlVars.joinWithSeparator("&")
    }
    

}

