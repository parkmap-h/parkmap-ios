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
    let properties: NSDictionary
    static func decode(j: NSDictionary) -> Feature? {
        if let geometory = j["geometry"] as? NSDictionary,
            coordinates = geometory["coordinates"] as? [NSNumber],
            properties = j["properties"] as? NSDictionary,
            type = j["type"] as? String {
                return Feature(type: type, coordinate: CLLocationCoordinate2D(latitude: coordinates[1].doubleValue, longitude: coordinates[0].doubleValue), properties: properties)
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
    let annotations = NSMutableOrderedSet()
    let annotationDictionary = NSMutableDictionary()

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
            "distance":200,
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
                if let features = FeatureCollection.decode(dict) {
                    self.addAnntations(features)
                }
            }
        })
    }

    func addAnntations(features: FeatureCollection) {
        let sorted = features.features.sorted({(feature1, feature2) in
            let distance1 = feature1.properties["distance"] as! NSNumber
            let distance2 = feature2.properties["distance"] as! NSNumber
            return distance1.doubleValue < distance2.doubleValue
        })
        for feature in sorted {
            let annotation = MKPointAnnotation()
            annotation.title = "title"
            if let fee = feature.properties["calc_fee"] as? NSNumber {
                annotation.subtitle = "\(fee)円"
            } else {
                annotation.subtitle = "料金情報なし"
            }
            let id = feature.properties["id"] as! NSNumber

            annotation.coordinate = feature.coordinate
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
