//
//  Song.swift
//  Itunes Manager
//
//  Created by Steven Hertz on 10/14/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import Foundation
import CoreData

// available to Objective-C code
@objc(Song)


class Song : NSManagedObject{
    @NSManaged var kind: String
    @NSManaged var collectionId: NSNumber
    @NSManaged var trackId: NSNumber
    @NSManaged var trackName: String
    @NSManaged var trackViewUrl: String
    @NSManaged var previewUrl: String
    @NSManaged var artworkUrl30: String
    @NSManaged var album: Album?

    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    
    init(theDict: [String: AnyObject ], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Song", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.kind = theDict["kind"] as! String
        self.collectionId = theDict["collectionId"] as! Int
        self.trackId = theDict["trackId"] as! Int
        self.trackName = theDict["trackName"] as! String
        self.trackViewUrl = theDict["trackViewUrl"] as! String
        self.previewUrl = theDict["previewUrl"] as! String
        self.artworkUrl30 = theDict["artworkUrl30"] as! String
}

}
