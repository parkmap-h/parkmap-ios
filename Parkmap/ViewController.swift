//
//  ViewController.swift
//  Parkmap
//
//  Created by えいる on 2015/06/09.
//  Copyright (c) 2015年 Parkmap. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        }
        
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 34.39091111111111, longitude: 132.4669333333333)
        mapView.region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let annotation = MKPointAnnotation()
        annotation.title = "title"
        annotation.coordinate = mapView.centerCoordinate
            mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

