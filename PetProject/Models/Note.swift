import Foundation
import CoreLocation

struct Note: Codable, Equatable {
    var id: UUID
    var title: String
    var body: String
    var latitude: Double
    var longitude: Double

    init(id: UUID = UUID(),
         title: String,
         body: String,
         latitude: Double,
         longitude: Double) {
        self.id = id
        self.title = title
        self.body = body
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
