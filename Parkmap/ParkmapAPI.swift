//  Copyright (c) 2015年 Parkmap. All rights reserved.

import Foundation
import MapKit


struct Park {
    let id: NSNumber
    let distance: NSNumber
    let fee: NSNumber?
    let coordinate: CLLocationCoordinate2D
    static func fromFeatrue(j: Feature) -> Park {
        let id = j.properties["id"] as! NSNumber
        let distance = j.properties["distance"] as! NSNumber
        let fee = j.properties["calc_fee"] as? NSNumber
        return Park(id: id, distance: distance, fee: fee, coordinate: j.coordinate)
    }
}

class ParkmapAPI {
    let operationQueue = NSOperationQueue()
    func search(params: NSDictionary, handler: (FeatureCollection) -> Void) -> Void {
        let url = NSURL(string: "http://localhost:3000/.json")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // set the header(s)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue, completionHandler: {(response, data, error) in
            if let d = data {
                let dict = NSJSONSerialization.JSONObjectWithData(d, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                if let features = FeatureCollection.decode(dict) {
                    handler(features)
                }
            }
        })
    }
}