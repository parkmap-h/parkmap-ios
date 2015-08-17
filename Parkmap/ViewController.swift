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

class ParkAnnotationView: MKAnnotationView {
    var _label: UILabel!
    var label: UILabel! {
        get {
            return _label
        }
        set(newValue) {
            if _label != nil {
                _label.removeFromSuperview()
            }
            _label = newValue
            addSubview(newValue)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
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
            "distance":500,
            "longitude":mapView.centerCoordinate.longitude,
            "latitude":mapView.centerCoordinate.latitude,
            "start_at":"",
            "end_at":""]
        api.search(params, handler: {(features) in
            self.addAnntations(features)
        })
    }

    func addAnntations(features: FeatureCollection) {
        for feature in features.features {
            let park = Park.fromFeatrue(feature)
            let annotation = ParkAnnotation(park: park)
            if annotationDictionary.objectForKey(park.id) == nil {
                annotationDictionary.setObject(annotation, forKey: park.id)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.mapView.addAnnotation(annotation)
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
        var myAnnotation = mapView.dequeueReusableAnnotationViewWithIdentifier(myIdentifier) as! ParkAnnotationView!
        if myAnnotation == nil {
            myAnnotation = ParkAnnotationView(annotation: annotation, reuseIdentifier: myIdentifier)
            let view = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 80,height: 20)))
            view.center = CGPoint(x: 0, y: 0)
            view.font = UIFont.boldSystemFontOfSize(12)
            view.adjustsFontSizeToFitWidth = true
            view.textAlignment = .Center
            view.textColor = UIColor.whiteColor()
            view.backgroundColor = UIColor(hue: 0, saturation: 0.8, brightness: 0.7, alpha: 0.8)
            myAnnotation.label = view
        }
        myAnnotation.label.text = annotation.subtitle
        myAnnotation.annotation = annotation
        return myAnnotation
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let park = (view.annotation as! ParkAnnotation).park
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ParkDetailViewController") as! ParkDetailViewController
        controller.park = park
        presentViewController(controller, animated: true, completion: nil)
        NSLog("tapped annotation \(park.fee)")
    }

}
