//
//  HttpDownloader.swift
//  DocumentCodeUse
//
//  Created by Steven Hertz on 9/11/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import Foundation

/// A class dedicated to downloading files.
class HttpDownloader {
    
    class func loadFileSync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!, error:nil)
        } else if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path!)]")
                completion(path: destinationUrl.path!, error:nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(path: destinationUrl.path!, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(path: destinationUrl.path!, error:error)
        }
    }
    
    /**
    Downloads a file asyncronously
    
    - parameter url:         The url to download.
    - parameter completion:  Completion block to execute upon completion of the download. 
    
    - returns: The completion Block returns the path and the NSError.
    */
    class func loadFileAsync(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(path: destinationUrl.path!, error:nil)
        } else {
            // setup the session
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            // setup the request
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            // setup task, it executes dataTaskWithRequest a NSURLSession function, using the request
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    if let response = response as? NSHTTPURLResponse {
                        // print("response=\(response)")
                        if response.statusCode == 200 {
                            if data!.writeToURL(destinationUrl, atomically: true) {
                                print("file saved [\(destinationUrl.path!)]")
                                completion(path: destinationUrl.path!, error:error)
                            } else {
                                print("error saving file")
                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                completion(path: destinationUrl.path!, error:error)
                            }
                        }
                    }
                }
                else {
                    print("Failure: \(error!.localizedDescription)");
                    completion(path: destinationUrl.path!, error:error)
                }
            })
            task.resume()
        }
    }
    
    class func getYoutubeData(url: NSURL, completion:(path:String, error:NSError!) -> Void) {
        // let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        // let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        // if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            //print("file already exists [\(destinationUrl.path!)]")
            //completion(path: destinationUrl.path!, error:nil)
        //} else {
            // setup the session
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            // setup the request
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            // setup task, it executes dataTaskWithRequest a NSURLSession function, using the request
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
//                    if let items = jsonResult["items"] as? [AnyObject]? {
//                        println(items?[0]["statistics"])
//                      }

                    if let response = response as? NSHTTPURLResponse {
                        print("response=\(response)")
                        if response.statusCode == 200 {
                            print("goood")
                        }
                    }
                        
                }
      
            })
            task.resume()
        }
   
}
