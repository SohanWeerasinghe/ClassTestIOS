import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    @Published var currentLocation: CLLocation?
    @Published var permissionText = "Location permission not requested"
    
    private let manager = CLLocationManager()
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            manager.requestLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionText = "Location permission allowed"
            manager.requestLocation()
        case .denied, .restricted:
            permissionText = "Location permission denied"
        case .notDetermined:
            permissionText = "Location permission not requested"
        @unknown default:
            permissionText = "Location permission unavailable"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        permissionText = "Could not get current location"
    }
}
