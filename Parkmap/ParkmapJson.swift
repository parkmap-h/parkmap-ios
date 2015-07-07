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