//  Copyright (c) 2015年 Parkmap. All rights reserved.

import Foundation
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