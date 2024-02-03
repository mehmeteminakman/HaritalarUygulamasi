//
//  DetailsViewController.swift
//  HaritalarUygulamasi
//
//  Created by mehmet emin akman on 30.01.2024.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var coreIsimDizi = [String]()
    var coreIdDizi = [UUID]()
    var secilenYerIsmi = ""
    var secilenId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ekleTiklandi))
        verileriAl()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "yeniYerOlusturuldu" ), object: nil)
    }
    
    
    @objc func verileriAl(){
        
        coreIdDizi.removeAll(keepingCapacity: false)
        coreIsimDizi.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        request.returnsObjectsAsFaults = false
        
        do{
            let veriler = try context.fetch(request)
            if veriler.count > 0{
                for veri in veriler as! [NSManagedObject]{
                    if let isim = veri.value(forKey: "isim") as? String{
                        coreIsimDizi.append(isim)
                    }
                    if let id = veri.value(forKey: "id") as? UUID{
                        coreIdDizi.append(id)
                    }
                }
                tableView.reloadData()
            }
            
           
        }catch{
            print("Veri cekme hatasi")
        }
        
        
    }
    
    @objc func ekleTiklandi(){
        secilenYerIsmi = ""
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreIsimDizi.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text=coreIsimDizi[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerIsmi = coreIsimDizi[indexPath.row]
        secilenId = coreIdDizi[indexPath.row]
        performSegue(withIdentifier: "toDetailsVc", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVc"{
            let destinationVc = segue.destination as! ViewController
            destinationVc.secilenIsim = secilenYerIsmi
            destinationVc.secilenId = secilenId
        }
    
    }

   

}
