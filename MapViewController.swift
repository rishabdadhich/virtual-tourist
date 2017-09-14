//
//  MapViewController.swift
//  VirtualTouristUpdated
//
//  Created by Rishabh on 20/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var deletionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!

    var checkPinEdit: Bool = false
    var pins = [Pin]()
    var selectedPin: Pin? = nil
    //MARK:- Variables
    let stack = coreDataStack.sharedInstance()
    var centerCoordinate: CLLocationCoordinate2D?
    var centerCoordinateLongitude: CLLocationDegrees?
    var centerCoordinateLatitude: CLLocationDegrees?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self;
        addGestureRecognizer()
        loadPinsFromDatabase()

        // change text of deletion label
        deletionLabel.text = "Hold press to drop Pin or delete Existinng Pin"

        // Do any additional setup after loading the view.
    }

    //MARK:- Add Getusre recornizer to Mapview to dectect hold and drop
    func addGestureRecognizer(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.addPinAnnotationToMap(gestureRecognizer:)))
        gesture.minimumPressDuration = 0.5
        gesture.delegate = self
        self.mapView.addGestureRecognizer(gesture)
    }
    
    //MARK:- Add pin to the Map as annotation
    func addPinAnnotationToMap(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            let point = gestureRecognizer.location(in: mapView)
            
            // Get the coordinates from the touch point.
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            print ("Coordinates of the Pin [LAT LONG] : \(latitude) \(longitude)")
            
            //Initialize Pin.
            let pin = Pin(context: stack.persistentContainer.viewContext)
            pin.latitude = latitude
            pin.longitude = longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            stack.saveContext()
        }
    }


   //Mark: edit action
    @IBAction func editAction(_ sender: Any) {
        if checkPinEdit {
            checkPinEdit = false
            editButton.title = "Edit"
            // after deletion give info
            deletionLabel.text = "Create New Pin Or Select Pin For Photos"
           
        }else {
            checkPinEdit = true
            editButton.title = "Done"
           deletionLabel.text = "Touch Pins to Delete"
        }

    }

    @IBAction func mapSegment(_ sender: UISegmentedControl) {
        
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }

    }
    //MARK:- Mapview delegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil
        {
            // Force Initialize pinView.
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else
        {
            pinView!.annotation = annotation
        }
        pinView!.pinTintColor = UIColor.red
        pinView?.animatesDrop = true
        pinView?.isDraggable = true
        return pinView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        
        guard let annotation = view.annotation else { /* no annotation */ return }
        if checkPinEdit {
            mapView.deselectAnnotation(annotation, animated: true)
            let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
            do {
                //go get the results
                let searchResults = try stack.persistentContainer.viewContext.fetch(fetchRequest)
                for pin in searchResults {
                    if annotation.coordinate.latitude == pin.latitude && annotation.coordinate.longitude == pin.longitude {
                        
                        selectedPin = pin
                        print("Deleting pin - verify core data is deleting as well")
                        stack.persistentContainer.viewContext.delete(selectedPin!)
                        
                        // Deleting selected pin on map
                        mapView.removeAnnotation(annotation)
                        
                        // Save the chanages to core data
                        stack.saveContext()
                    }
                }
            } catch {
                print("Error with request: \(error)")
            }
            
        } else {
            mapView.selectAnnotation(annotation, animated: true)
            performSegue(withIdentifier: "showAlbum", sender: annotation )
            
            //Deselect the annotation here so that it's again selectable when we return from the album view:
            mapView.deselectAnnotation(annotation, animated: true)
        }
        
    }
    //MARK:- FetchPinsFromData
    func loadPinsFromDatabase()
    {
        var annotations = [MKAnnotation]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        do
        {
            let results = try stack.persistentContainer.viewContext.fetch(fetchRequest)
            if let results = results as? [Pin]
            {
                pins = results
                print("Number of Pins : \(pins.count)")
            }
        }
        catch
        {
            print("Couldn't find any Pins")
        }
        
        for (_,item) in pins.enumerated()
        {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(item.latitude),longitude: CLLocationDegrees(item.longitude))
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showAlbum"
        {
            // First find the selected Pin in Core Data, if found send the associated Pin annotation to PhotoViewController.
            var pin: Pin!
            do
            {
                let pinAnnotation = sender as! MKAnnotation
                
                let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
                let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pinAnnotation.coordinate.latitude, pinAnnotation.coordinate.longitude])
                fetchRequest.predicate = predicate
                let pins = try stack.persistentContainer.viewContext.fetch(fetchRequest)
                
                pin = pins[0]
            }
            catch let error as NSError
            {
                print("failed to get pin by object id")
                print(error.localizedDescription)
                return
            }
            
            let photosVC = segue.destination as! PhotoAlbumViewController
            photosVC.pin = FlickrHelper.toPin(sender as! MKAnnotation, pin)
        }
    }
 

    
}
