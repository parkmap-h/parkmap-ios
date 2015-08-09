//  Copyright (c) 2015年 Parkmap. All rights reserved.

import Foundation
import MapKit


struct Park {
    let id: NSNumber
    let name: String
    let distance: NSNumber
    let fee: NSNumber?
    let coordinate: CLLocationCoordinate2D
    let photoURLs: [NSURL?]
    let miniPhotoURLs: [NSURL?]
    let thumbPhotoURLs: [NSURL?]
    static func fromFeatrue(j: Feature) -> Park {
        func urls(key: String) -> [NSURL?] {
            return (j.properties[key] as! [String]).map({ n in NSURL(string: n) })
        }
        let id = j.properties["id"] as! NSNumber
        let name = j.properties["name"] as! String
        let distance = j.properties["distance"] as! NSNumber
        let fee = j.properties["calc_fee"] as? NSNumber
        let photoURLs = urls("photos")
        let miniPhotoURLs = urls("mini_photos")
        let thumbPhotoURLs = urls("thumb_photos")
        return Park(
            id: id,
            name: name,
            distance: distance,
            fee: fee,
            coordinate: j.coordinate,
            photoURLs: photoURLs,
            miniPhotoURLs: miniPhotoURLs,
            thumbPhotoURLs: thumbPhotoURLs
        )
    }
}

class ParkmapAPI {
    let operationQueue = NSOperationQueue()
    func search(params: NSDictionary, handler: (FeatureCollection) -> Void) -> Void {
        #if LOCAL
            let base_url = "http://localhost:3000/"
        #else
            let base_url = "http://parkmap.eiel.info/"
        #endif
        let url = NSURL(string: "\(base_url).json")
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