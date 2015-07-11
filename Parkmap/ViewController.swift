//  Copyright (c) 2015年 Parkmap. All rights reserved.

import UIKit
import MapKit

class ParkAnnotation: MKPointAnnotation {
    let park: Park

    init(park: Park) {
        self.park = park
        super.init()
        super.coordinate = park.coordinate

        super.title = "title"
        if let fee = park.fee {
            super.subtitle = "\(fee)円"
        } else {
            super.subtitle = "料金情報なし"
        }
    }
}

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
            let annotation = ParkAnnotation(park: park)

            annotations.addObject(park.id)
            annotationDictionary.setObject(annotation, forKey: park.id)
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

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let park = (view.annotation as! ParkAnnotation).park
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ParkDetailViewController") as! UIViewController
        controller.loadView()
        presentViewController(controller, animated: true, completion: nil)
        NSLog("tapped annotation \(park.fee)")
    }

}
