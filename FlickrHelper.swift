//
//  FlickrHelper.swift
//  VirtualTouristUpdated
//
//  Created by Rishabh on 19/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation
import MapKit

class FlickrHelper{
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrHelper {
        struct Singleton {
            static var sharedInstance = FlickrHelper()
        }
        return Singleton.sharedInstance
    }
    
    
    func bboxString( latitude : Double , longitude : Double ) -> String {
        
        // Checking Valid Map Coordinates
        if(latitude == 0.0 && longitude == 0.0) {
            return "0,0,0,0"
        }
        
        let minimumLon = max ( longitude - FlickrConstants.SearchBBoxHalfWidth , FlickrConstants.SearchLonRange.0)
        let minimumLat = max ( latitude - FlickrConstants.SearchBBoxHalfHeight , FlickrConstants.SearchLatRange.0)
        let maximumLon = max ( longitude - FlickrConstants.SearchBBoxHalfWidth , FlickrConstants.SearchLonRange.1)
        let maximumLat = max ( latitude - FlickrConstants.SearchBBoxHalfHeight , FlickrConstants.SearchLatRange.1)
        
        return "\(minimumLon) , \(minimumLat) , \(maximumLon) , \(maximumLat) "
        
    }
    
    
    // Build URL & return the request.
    
    func getBuildURL(parameters : [String:AnyObject]) -> URLRequest {
        
        // Building URL Components
        var components = URLComponents()
        components.scheme = FlickrConstants.APIScheme
        components.host   = FlickrConstants.APIHost
        components.path   = FlickrConstants.APIPath
        
        components.queryItems = [URLQueryItem]()
        
        for (keys , values) in parameters {
            let queryItem = URLQueryItem(name: keys, value: values as? String)
            components.queryItems?.append(queryItem)
        }
        
        if  components.url == nil
        {
            print("Error in URL Creation")
        }
        
        guard let urlrequested = components.url else {
            print("Error in URL Creation")
            let url2 = NSURL(string: "https://www.flickr.com/photos/flickr/30709520093/in/feed")
            let url = URLRequest.init(url: url2 as! URL)
            return url
        }
        
        
        let request = URLRequest(url: urlrequested)
        return request
        
        
    }
    
    //Mark : This method will convert a Pin into MKPointAnnotation
    static func toMKAnnotation(_ pin: Pin) -> MKPointAnnotation
    {
        let toAnnotation = MKPointAnnotation()
        toAnnotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude), CLLocationDegrees(pin.longitude))
        return toAnnotation
    }
    
    //Mark : This method will convert MKAnnotation into Pin
    static func toPin (_ annotation:MKAnnotation, _ pin:Pin) -> Pin
    {
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        return pin
    }
    


}
