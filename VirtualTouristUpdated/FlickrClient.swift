//
//  FlickrClient.swift
//  VirtualTouristUpdated
//
//  Created by Rishabh on 19/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import Foundation

class FlickrClient{
    
    func searchPhotosFromFlickr(latitude: Double, longitude: Double, completionHandlerForSearchPhotos: @escaping (_ photoURLS: [String]?, _ error: NSError?) -> Void)
    {
        
        // Parameters adding
        
        let flickrParameters : [String : String?] = [
            FlickrConstants.ParameterKeys.Method : FlickrConstants.ParameterValues.SearchMethod,
            FlickrConstants.ParameterKeys.APIKey : FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.BBOX : FlickrHelper.sharedInstance().bboxString(latitude: latitude, longitude: longitude),
            FlickrConstants.ParameterKeys.SearchType : FlickrConstants.ParameterValues.SafeSearch,
            FlickrConstants.ParameterKeys.Extras : FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format : FlickrConstants.ParameterValues.JSONFormat,
            FlickrConstants.ParameterKeys.JSONCallback : FlickrConstants.ParameterValues.NoJSONCallback,FlickrConstants.ParameterKeys.Page : ("\(arc4random_uniform(15))" as AnyObject) as? String
        ]
        
        // Request Setup
        
        
        let getRequestSetup = FlickrHelper.sharedInstance().getBuildURL(parameters: flickrParameters as [String : AnyObject])
        
        
        let task = URLSession.shared.dataTask(with: getRequestSetup) {
            data , response , error in
            
            // if an error occurs, print it and re-enable the UI
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForSearchPhotos(nil, NSError(domain: "searchPhotosFromFlickr", code: 1, userInfo: userInfo))
            }
            
            
            // guard statements incoming
            
            guard let data = data else {
                sendError("no data was returned with request!")
                
                return
            }
            
            guard error == nil else {
                sendError("there was an error with your request: \(error)")
                return
            }
            // Status code msgs
            guard let statusCodes = (response as? HTTPURLResponse)?.statusCode , statusCodes >= 200 && statusCodes <= 299 else {
                sendError("wrong status code returned")
                return
            }
            
            var parsedResult : [String:AnyObject]?
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                
                
                
            } catch {
                sendError(" Catched Error in JSON serialization Json Object creation")
                
            }
            
            
            guard let photosDictionary = parsedResult?[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject],
                let photosArray = photosDictionary[FlickrConstants.ResponseKeys.Photo] as? [[String:AnyObject]]
                else {
                    print(" find \(FlickrConstants.ResponseKeys.Photos) and \(FlickrConstants.ResponseKeys.Photo) in \(parsedResult)")
                    return
            }
            
            guard photosArray.count > 0 else {
                print("photosarray is empty.")
                return
            }
            
            //Create the photoarraycount variable for easily traversing through the array index & print it.
            let photosArrayCount = photosArray.count-1
            print(photosArrayCount)
            
            var photoUrl : [String] = []
            
            for photoindex in 0...photosArrayCount {
                
                let photoDictionary = photosArray[photoindex] as [String:AnyObject]
                
                guard let imageURLString = photoDictionary[FlickrConstants.ResponseKeys.MediumURL] as? String else {
                    print("Unable to locate image URL in photo dictionary")
                    return
                }
                //                print(imageURLString)
                photoUrl.append(imageURLString)
                
                
            }
            completionHandlerForSearchPhotos(photoUrl, nil)
        }
        
        
        task.resume()
        
    }
    
    
    
    //MARK:- Download photos based on the provided photo URL.
    func downloadPhotos(photoURL:String, completionHandlerForDownloadPhotos: @escaping (_ image: NSData?, _ error: NSError?) -> Void)
    {
        let session = URLSession.shared
        let url = NSURL(string: photoURL)
        let request = URLRequest(url: url! as URL)
        
        let task = session.dataTask(with: request){ data, response, error in
            
            guard let data = data else
            {
                completionHandlerForDownloadPhotos(nil, NSError(domain: FlickrConstants.Error.Domain.DownloadMethod, code: 6001, userInfo: [NSLocalizedDescriptionKey: FlickrConstants.Error.Message.Download_Not_Possible]))
                return
            }
            completionHandlerForDownloadPhotos(data as NSData, nil)
        }
        task.resume()
    }
    
    
    //Convert Flickr URLs to  Image Data.
    func getImageDataFlickrURL (urlString : String) -> Data? {
        
        guard let url = URL(string: urlString),
            let imageData = try? Data(contentsOf: url) else {
                print("Error converting URL string to Image data")
                return nil
        }
        return imageData
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    
    
}
