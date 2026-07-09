import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    @Published var currentLocation: CLLocation?
    @Published var permissionText = "Location permission not requested"
    @Published var isLocationAllowed = false
    @Published var accuracyText = "Accuracy unknown"
    
    private let manager = CLLocationManager()
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        let status = manager.authorizationStatus
        
        if status == .notDetermined {
            permissionText = "Requesting location permission..."
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            isLocationAllowed = true
            permissionText = "Finding accurate location..."
            manager.startUpdatingLocation() // Starts tracking if already allowed
        } else {
            isLocationAllowed = false
            permissionText = "Location permission denied"
        }
    }
    
    // This watches for the user tapping "Allow" on the popup window!
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAllowed = true
            permissionText = "Finding accurate location..."
            manager.startUpdatingLocation() // FIX: Forces the physical phone GPS to wake up immediately
            
        case .denied, .restricted:
            isLocationAllowed = false
            currentLocation = nil
            permissionText = "Location permission denied"
            
        case .notDetermined:
            isLocationAllowed = false
            permissionText = "Location permission not requested"
            
        @unknown default:
            isLocationAllowed = false
            permissionText = "Location permission unavailable"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Make sure the timestamp isn't old cached hardware data
        let locationAge = abs(location.timestamp.timeIntervalSinceNow)
        guard locationAge < 30 else { return }
        guard location.horizontalAccuracy > 0 else { return }
        
        currentLocation = location
        accuracyText = "Accuracy: about \(Int(location.horizontalAccuracy))m"
        
        if location.horizontalAccuracy <= 100 {
            permissionText = "Location ready"
        } else {
            permissionText = "Location is approximate"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with error: \(error.localizedDescription)")
        permissionText = "Could not get current location"
        accuracyText = "Accuracy unknown"
    }
}
