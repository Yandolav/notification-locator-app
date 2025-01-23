import UIKit
import CoreLocation

// MARK: - LocationManager

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Singleton
    
    static let shared = LocationManager()
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private let maxRegions = 20
    var notes = [Note]()
    var currentLocation: CLLocation?
    
    // MARK: - Initialization
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Public Methods
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func updateMonitoredRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }

        for note in notes.prefix(maxRegions) {
            let region = CLCircularRegion(center: note.coordinate,
                                          radius: 100,
                                          identifier: note.id.uuidString)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("Разрешение на геолокацию предоставлено всегда.")
            notes = NotesStore.shared.load()
            updateMonitoredRegions()
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("Разрешение на геолокацию предоставлено при использовании приложения.")
        case .denied, .restricted:
            print("Разрешение на геолокацию не предоставлено.")
        case .notDetermined:
            print("Статус авторизации не определен.")
        @unknown default:
            print("Неизвестный статус авторизации.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if let region = region {
            print("Ошибка мониторинга региона \(region.identifier): \(error.localizedDescription)")
        } else {
            print("Ошибка мониторинга региона: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Начат мониторинг региона: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let note = notes.first(where: { $0.id.uuidString == region.identifier }) else { return }
        print("Вход в геозону: \(region.identifier)")
        NotificationManager.shared.sendNotificationEnter(for: note)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Выход из геозоны: \(region.identifier)")
        NotificationManager.shared.sendNotificationExit()
    }
}
