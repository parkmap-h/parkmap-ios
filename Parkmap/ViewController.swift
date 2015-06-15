//
//  ViewController.swift
//  Parkmap
//
//  Created by えいる on 2015/06/09.
//  Copyright (c) 2015年 Parkmap. All rights reserved.
//

import UIKit
import MapKit


struct Feature {
    let type: String
    let coordinate: CLLocationCoordinate2D
    static func decode(j: NSDictionary) -> Feature? {
        if let geometory = j["geometry"] as? NSDictionary,
        let coordinates = geometory["coordinates"] as? [NSNumber],
        let type = j["type"] as? String {
            return Feature(type: type, coordinate: CLLocationCoordinate2D(latitude: coordinates[1].doubleValue, longitude: coordinates[0].doubleValue))
        }
        return .None
    }
}

struct FeatureCollection {
    let type: String
    let features: [Feature]

    static func decode(j: NSDictionary) -> FeatureCollection? {
        if let type = j["type"] as? String,
        let j_features: [NSDictionary] = j["features"] as? [NSDictionary],
        // Haskellのsequence
        let features: [Feature] = j_features.reduce(Optional.Some([]), combine: { (acc,j_feature) in
            switch Feature.decode(j_feature) {
                case .None: return .None
                case .Some(let f): return acc.map { fs in var m = fs; m.append(f); return m }
            }
        }) {
            return FeatureCollection(type: type, features: features)
        }
        return .None
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 34.39091111111111, longitude: 132.4669333333333)
        mapView.region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        let url = NSURL(string: "http://localhost:3000/.json")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let params = [
            "distance":300,
            "longitude":132.465511,
            "latitude":34.393056,
            "start_at": "",
            "end_at":""]
        // set the header(s)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        if let d = data {
            let dict = NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
            print(dict)
            if let features = FeatureCollection.decode(dict) {
                for feature in features.features {
                    let annotation = MKPointAnnotation()
                    annotation.title = "title"
                    annotation.subtitle = "subtitle"

                    annotation.coordinate = feature.coordinate
                    mapView.addAnnotation(annotation)
                    print(feature.type)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

