//
//  FlickrConstants.swift
//  VirtualTouristUpdated
//
//  Created by Rishabh on 19/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation
class FlickrConstants {
    
    
    
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
    
    // Latitude & Longitude Square Box Constants
    static let SearchBBoxHalfWidth = 1.0
    static let SearchBBoxHalfHeight = 1.0
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)
    
    
    
    // Parameter Keys
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Format = "format"
        static let JSONCallback = "nojsoncallback"
        static let Extras = "extras"
        static let Text = "text"
        static let Page = "page"
        static let BBOX = "bbox"
        static let SearchType = "safe_search"
        
        
        
    }
    
    
    // Parameter Values
    
    struct ParameterValues {
        static let APIKey = "4024badb263a65733a93d4c597da1e07"
        static let SearchMethod = "flickr.photos.search"
        static let JSONFormat = "json"
        static let NoJSONCallback = "1"
        static let MediumURL = "url_m"
        static let SafeSearch = "1"
        
        
        
    }
    
    // Response Keys
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
        
        
    }
    //MARK:- Flockr Error messages
    struct Error
    {
        struct Domain
        {
            static let SearchMethod="VT.SEARCH_PHOTOS"
            static let DownloadMethod="VT.DOWNLOAD_PHOTOS"
        }
        
        struct Message
        {
            static let Error_Occurred = "Error occurrred in API response."
            static let Invalid_Response = "API response is not parsable for necessary information."
            static let Download_Not_Possible = "Unable to download pic."
        }
    }


}
