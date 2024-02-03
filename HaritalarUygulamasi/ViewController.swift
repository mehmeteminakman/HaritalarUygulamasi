//
//  ViewController.swift
//  HaritalarUygulamasi
//
//  Created by mehmet emin akman on 30.01.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    @IBOutlet weak var yerIsmiTextField: UITextField!
    @IBOutlet weak var yerNotuTextField: UITextField!
    @IBOutlet weak var kaydetButton: UIButton!
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var secilenIsim = ""
    var secilenId : UUID?
    var annotatioanTitle = String()
    var annotationSubTitle = String()
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // en keskin konumu al
        locationManager.requestWhenInUseAuthorization() // uygulama çalıştığında konum izni al
        locationManager.startUpdatingLocation() // konumu güncelleştirmeye başla
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer: )))
        mapView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 3
        kaydetButton.isEnabled=false
        if secilenIsim != ""{
            if let uuidString = secilenId?.uuidString{
                
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appdelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString) // uuidString ile filtreleme işlemi
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let veriler = try context.fetch(fetchRequest)
                    for veri in veriler as! [NSManagedObject]{
                        if let isim = veri.value(forKey: "isim") as? String{
                            annotatioanTitle=isim
                            if let not = veri.value(forKey: "not") as? String{
                                annotationSubTitle = not
                                if let latitude = veri.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    if let longitude = veri.value(forKey: "longitude") as? Double{
                                        annotationLongitude = longitude
                                        
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotatioanTitle
                                        annotation.subtitle = annotationSubTitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        
                                        yerIsmiTextField.text = annotatioanTitle
                                        yerNotuTextField.text = annotationSubTitle
                                        
                                        // kullanıcının yer için seçtiği enlem ve boylamı haritaya uygulamamız gerekiyor
                                        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta:0.3 )
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                }catch{
                    print("hata")
                }
                
                
                
                
                
                
            }
            
        }else{
            
        }
        
    }
    
    
    @objc func konumSec(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let dokunulanNokta = gestureRecognizer.location(in: mapView) // dokunulan yer tespit edildi
            let dokunulanNoktaKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView) // dokunulan noktayı koordinata çevirdik
            latitude = dokunulanNoktaKoordinat.latitude // caredataya kaydetmek için latitude değerini global değere atadık
            longitude = dokunulanNoktaKoordinat.longitude //
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanNoktaKoordinat
            annotation.title = yerIsmiTextField.text
            annotation.subtitle = yerNotuTextField.text
            mapView.addAnnotation(annotation)
            if yerIsmiTextField.text != ""{
                if yerNotuTextField.text != ""{
                    kaydetButton.isEnabled = true
                }
                
            }
            
        }
    }
    
    // konum pinine ekstra bilgi gösterme
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if  annotation is MKUserLocation {
            return nil
        }
        let identifier = "Capital"
        var pinView1 = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if pinView1 == nil {
            pinView1 = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView1?.canShowCallout = true
            pinView1?.tintColor = .red

            let btn = UIButton(type: .detailDisclosure)
            pinView1?.rightCalloutAccessoryView = btn
            
        } else {

            pinView1?.annotation = annotation
        }

        return pinView1
    }
    
    // konumda gösterdiğimiz info button tıklandığında haritalara git
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarkDizisi, hata in
                if let placemarks = placemarkDizisi{
                    if placemarks.count > 0 {
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark : yeniPlacemark)
                        item.name = self.annotatioanTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { // bu fonsiyon lokasyon her güncellendiğinde lokasyonları locations isimli diziyi döndürür
        //print(locations[0].coordinate.latitude) // lokasyonun enlemini göster
        //print(locations[0].coordinate.longitude) // lokasyonun boylamını göster
        if secilenIsim == ""{ // eğer kullanıcı yeni yer eklemeye tıklarsa lokasyonu kullonıcıya göre güncelle
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude) // enlem ve boylam vererek bir lokasyon oluşturduk
            let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3) // bölgenin ne kadar dar ve ya uzak olacağını belirledik
            let region = MKCoordinateRegion(center: location, span: span) // bölgeyi oluşturduk
            mapView.setRegion(region, animated: true) // bölgeyi haritaya setledik
        }
        
    }
    
    @IBAction func kaydetButtonTiklandi(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        yeniYer.setValue(yerIsmiTextField.text, forKey: "isim")
        yeniYer.setValue(yerNotuTextField.text, forKey: "not")
        yeniYer.setValue(latitude, forKey: "latitude")
        yeniYer.setValue(longitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Kayıt edildi")
        }catch{
            print("HATA")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
        navigationController?.popViewController(animated: true)
        
        
        
    }
    
    
    


}

