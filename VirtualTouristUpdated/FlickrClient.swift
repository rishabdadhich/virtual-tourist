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
            
            
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult?[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find keys '\(FlickrConstants.ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[FlickrConstants.ResponseKeys.Pages] as? Int else {
                sendError("Cannot find key '\(FlickrConstants.ResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            
            let photoArrayString : [String] = self.displayImageFromFlickrBySearch(methodParameters: flickrParameters as [String : AnyObject], withPageNumber: randomPage)
          completionHandlerForSearchPhotos(photoArrayString, nil)
        }

        
        task.resume()

    }
    
    // FIX: For Swift 3, variable parameters are being depreciated. Instead, create a copy of the parameter inside the function.
    
    private func displayImageFromFlickrBySearch(methodParameters: [String: AnyObject], withPageNumber: Int) -> [String] {
        
        var photoUrl : [String] = []
    
        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[FlickrConstants.ParameterKeys.Page] = withPageNumber as AnyObject?
        
        // Request Setup
        
        
        let getRequestSetup = FlickrHelper.sharedInstance().getBuildURL(parameters: methodParameters as [String : AnyObject])
        
        // create network request
        let task = URLSession.shared.dataTask(with: getRequestSetup) { (data, response, error) in
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
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
            
//            var photoUrl : [String] = []
            
            for photoindex in 0...photosArrayCount {
                
                let photoDictionary = photosArray[photoindex] as [String:AnyObject]
                
                guard let imageURLString = photoDictionary[FlickrConstants.ResponseKeys.MediumURL] as? String else {
                    print("Unable to locate image URL in photo dictionary")
                    return
                }
                print(imageURLString)
                photoUrl.append(imageURLString)
            
            }
       
        }
        
        task.resume()
        return photoUrl
    }
    ////
    
    
    
    
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
