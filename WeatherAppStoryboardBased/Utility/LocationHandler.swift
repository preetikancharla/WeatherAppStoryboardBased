//
//  LocationPermissionHandler.swift
//  WeatherAppStoryboardBased
//
//  Created by Preeti Kancharla on 5/19/23.
//

import Foundation
import CoreLocation

protocol LocationHandlerDelegate {
    func coordinatesUpdated()
}

class LocationHandler:  NSObject, CLLocationManagerDelegate {
    
    static var shared = LocationHandler()
    
    private var manager: CLLocationManager?
    private var coordinates: Coord?
    var delegate: LocationHandlerDelegate?
  
    private override init() {
        super.init()
        self.manager = CLLocationManager()
        self.manager?.delegate = self
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            self.manager?.requestLocation()
            break
        case .notDetermined:
            self.manager?.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedWhenInUse:
            self.manager?.requestLocation()
            break
        @unknown default:
            self.manager?.requestWhenInUseAuthorization()
            break
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.coordinates = Coord(lon: location.coordinate.longitude, lat: location.coordinate.latitude)
            self.delegate?.coordinatesUpdated()
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    // Public methods
    func requestPermission() {
        self.manager?.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> Coord? {
        return self.coordinates
    }
    
    func isCurrentLocationFetched() -> Bool {
        switch manager?.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            case .none:
                return false
            @unknown default:
                return false
        }
    }
    
    
    
}
