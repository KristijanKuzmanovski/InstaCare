//
//  MapViewController.swift
//  InstaCare
//
//  Created by Dzin on 18.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import SideMenu
import MapKit
import CoreLocation
import FirebaseFirestore

class MapViewController: UIViewController, CLLocationManagerDelegate {

    var menu: SideMenuNavigationController?
    @IBOutlet weak var map: MKMapView!
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        menu = SideMenuNavigationController(rootViewController: (storyboard?.instantiateViewController(identifier: "SideMenu"))!)
        menu?.leftSide = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        map.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            //manager.stopUpdatingLocation()
            
            render(location)
        }
    }
    
    func render(_ location: CLLocation){
        let cor = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: cor, span: span)
        
        map.setRegion(region, animated: true)
        addStations()
    }
    func addStations(){
        Firestore.firestore().collection("locations").getDocuments(completion: {
            (res,err) in
            if err != nil && res?.count != 0{
                print("Error")
            }
            else{
                for doc in res!.documents {
                    let lon = CLLocationDegrees(doc.get("lon") as! String)
                    let lat = CLLocationDegrees(doc.get("lat") as! String)
                    let cor = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                    
                    let pin = MKPointAnnotation()
                    pin.coordinate = cor
                    pin.title = doc.get("name") as? String
                    self.map.addAnnotation(pin)
                    
                }
                
            }
        })
    }
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        present(menu!, animated: true)
    }
}
