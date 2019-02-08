

import UIKit
import Firebase
import CoreLocation
import MapKit

class ViewController: UIViewController {


    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var shareLocationLabel: UILabel!
    //to access location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.stopUpdatingLocation()
      
        
        FirService.sharedInstance.authenticateWithFirebase { (user) in
            self.setupLocationManager()
        }
       
      
    }
}

//MARK - Location extension
    
extension ViewController : CLLocationManagerDelegate {
    
    
    //MARK: - Location related methods
    
    func setupLocationManager() {
        
        if FirService.sharedInstance.getLocation() == nil {
            self.isAuthorizedtoGetUserLocation()
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                self.locationManager.startUpdatingLocation() //this will invoke the didUpdateLocations method
            }
        }
        
    }
    
    func isAuthorizedtoGetUserLocation() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region  = MKCoordinateRegionMake(myLocation, span)
        self.mapView.setRegion(region, animated: true)
        
        //if location.horizontalAccuracy > 0 {
          //  locationManager.stopUpdatingLocation() //got the location and now we can stop updating location.
        //}
       FirService.sharedInstance.setUserLocation(location: location)
         mapView.showsUserLocation = true
  //      DispatchQueue.main.async {
            self.locationLabel.text = "\(location.coordinate.latitude) : \(location.coordinate.longitude)"
    //     }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location \(error)")
    }
    
    @IBAction func shareLcoationSwitchAction(_ sender: UISwitch) {
        shareLocationLabel.text = sender.isOn ? "share location" : "Stop Sharing location"
        
        if sender.isOn {
            userStartedLocationSharing()
        }
        else {
            userStoppedLocationSharing()
        }
        
        //nicknameTextField.resignFirstResponder()
    }
    
    func userStartedLocationSharing() {
        FirService.sharedInstance.authenticateWithFirebase{ (user) in
            self.setupLocationManager()
        }
        locationManager.startUpdatingLocation()
        locationLabel.text! = "\(locationManager.location!.coordinate.latitude) \(locationManager.location!.coordinate.longitude)"
    }
    
    
    //Send message to server that user stopped sharing location
    func userStoppedLocationSharing() {
    locationManager.stopUpdatingLocation()
    }

}
