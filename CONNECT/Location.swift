//
//  Location.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Location {
    @Attribute(.unique) var id: UUID
    var name: String
    var address: String?
    var city: String
    var country: String
    var latitude: Double
    var longitude: Double
    var placeType: String? // e.g., "restaurant", "park", "venue"
    var createdAt: Date
    
    // Relationships - Simplified to avoid circular references
    @Relationship(deleteRule: .cascade)
    var moments: [Moment] = []
    
    @Relationship(deleteRule: .cascade)
    var events: [Event] = []
    
    init(
        name: String,
        address: String? = nil,
        city: String,
        country: String,
        latitude: Double,
        longitude: Double,
        placeType: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.placeType = placeType
        self.createdAt = Date()
    }
    
    convenience init(from clLocation: CLLocation, name: String, city: String, country: String) {
        self.init(
            name: name,
            city: city,
            country: country,
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude
        )
    }
}

// MARK: - Location Extensions
extension Location {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var fullAddress: String {
        var components: [String] = []
        
        if let address = address {
            components.append(address)
        }
        components.append(city)
        components.append(country)
        
        return components.joined(separator: ", ")
    }
    
    var shortAddress: String {
        if let address = address {
            return "\(address), \(city)"
        }
        return "\(city), \(country)"
    }
    
    func distance(from location: CLLocation) -> CLLocationDistance {
        return clLocation.distance(from: location)
    }
    
    func distanceString(from location: CLLocation) -> String {
        let distance = distance(from: location)
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.maximumFractionDigits = 1
        
        if distance < 1000 {
            return formatter.string(from: Measurement(value: distance, unit: UnitLength.meters))
        } else {
            return formatter.string(from: Measurement(value: distance / 1000, unit: UnitLength.kilometers))
        }
    }
} 