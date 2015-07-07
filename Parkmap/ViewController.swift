//  Copyright (c) 2015年 Parkmap. All rights reserved.

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let annotations = NSMutableOrderedSet()
    let annotationDictionary = NSMutableDictionary()
    let api = ParkmapAPI()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 34.39091111111111, longitude: 132.4669333333333)
        mapView.region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func search() {
        let params = [
            "distance":200,
            "longitude":mapView.centerCoordinate.longitude,
            "latitude":mapView.centerCoordinate.latitude,
            "start_at":"",
            "end_at":""]
        api.search(params, handler: {(features) in
            self.addAnntations(features)
        })
    }

    func addAnntations(features: FeatureCollection) {
        let parks = features.features.map({ (feature) in return Park.fromFeatrue(feature) })
        let sorted = parks.sorted({(park1, park2) in
            let distance1 = park1.distance
            let distance2 = park2.distance
            return distance1.doubleValue < distance2.doubleValue
        })
        for park in sorted {
            let annotation = MKPointAnnotation()
            annotation.title = "title"
            if let fee = park.fee {
                annotation.subtitle = "\(fee)円"
            } else {
                annotation.subtitle = "料金情報なし"
            }
            let id = park.id

            annotation.coordinate = park.coordinate
            annotations.addObject(id)
            annotationDictionary.setObject(annotation, forKey: id)
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.mapView.addAnnotation(annotation)
            })
            var count = annotations.count
            while true {
                if (count < 200) { break }
                count--
                let removeId = annotations.objectAtIndex(0) as! NSNumber
                annotations.removeObjectAtIndex(0)
                let removeAnnotation = annotationDictionary.objectForKey(removeId) as! MKAnnotation
                annotationDictionary.removeObjectForKey(removeId)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.mapView.removeAnnotation(removeAnnotation)
                })
            }
        }

    }

    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        search()
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let myIdentifier = "park"
        var myAnnotation: MKAnnotationView!
        if myAnnotation == nil {
            myAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: myIdentifier)
        }
        let view = UILabel(frame: CGRect(origin: CGPoint(x: -20, y: -6), size: CGSize(width: 60,height: 12)))
        view.font = UIFont.systemFontOfSize(12)
        view.text = annotation.subtitle
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = .Center
        view.backgroundColor = UIColor.whiteColor()
        myAnnotation.addSubview(view)
        myAnnotation.annotation = annotation
        return myAnnotation
    }
}
