//
//  ViewController.swift
//  Parkmap
//
//  Created by えいる on 2015/06/09.
//  Copyright (c) 2015年 Parkmap. All rights reserved.
//

import UIKit
import MapKit

func sequence<T>(xs: [T?]) -> [T]? {
    var result: [T]? = []
    for optX in xs {
        if let x = optX {
            result?.append(x)
        } else {
            return nil
        }
    }
    return result
}

struct Feature {
    let type: String
    let coordinate: CLLocationCoordinate2D
    static func decode(j: NSDictionary) -> Feature? {
        if  let geometory = j["geometry"] as? NSDictionary,
            let coordinates = geometory["coordinates"] as? [NSNumber],
            let type = j["type"] as? String {
                return Feature(type: type, coordinate: CLLocationCoordinate2D(latitude: coordinates[1].doubleValue, longitude: coordinates[0].doubleValue))
        }
        return nil
    }
}

struct FeatureCollection {
    let type: String
    let features: [Feature]

    static func decode(j: NSDictionary) -> FeatureCollection? {
        if  let type = j["type"] as? String,
            let j_features: [NSDictionary] = j["features"] as? [NSDictionary],
            let features: [Feature] = sequence(j_features.map { f in Feature.decode(f) }) {
                return FeatureCollection(type: type, features: features)
        }
        return nil
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let operationQueue = NSOperationQueue()

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
        let url = NSURL(string: "http://localhost:3000/.json")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params = [
            "distance":500,
            "longitude":mapView.centerCoordinate.longitude,
            "latitude":mapView.centerCoordinate.latitude,
            "start_at": "",
            "end_at":""]
        // set the header(s)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue, completionHandler: {(response, data, error) in
            if let d = data {
                let dict = NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                print(dict)
                if let features = FeatureCollection.decode(dict) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ self.addAnntations(features) })
                }
            }
        })
    }

    func addAnntations(features: FeatureCollection) {
        let old_annotations = mapView.annotations
        for feature in features.features {
            let annotation = MKPointAnnotation()
            annotation.title = "title"
            annotation.subtitle = "subtitle"

            annotation.coordinate = feature.coordinate
            mapView.addAnnotation(annotation)
        }
        mapView.removeAnnotations(old_annotations)
    }

    // MARK: - MKMapViewDelegate
    func mapViewWillStartLoadingMap(mapView: MKMapView!) {
        search()
    }

}
