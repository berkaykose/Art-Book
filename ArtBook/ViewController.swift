//
//  ViewController.swift
//  ArtBook
//
//  Created by Berkay Köse on 24.06.2019.
//  Copyright © 2019 Berkay Köse. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var paintingArray = [UIImage]()
    var nameArray = [String]()
    var artistArray = [String]()
    var yearArray = [Int]()
    var selectedPainting = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        getInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.getInfo), name: NSNotification.Name.init("newPainting"), object: nil)
    }
    
    @objc func getInfo() {
        
        nameArray.removeAll(keepingCapacity: false)
        paintingArray.removeAll(keepingCapacity: false)
        yearArray.removeAll(keepingCapacity: false)
        artistArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
        
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    if let artist = result.value(forKey: "artist") as? String {
                        self.artistArray.append(artist)
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        self.yearArray.append(year)
                    }
                    if let image = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: image)
                        self.paintingArray.append(image!)
                    }
                    self.tableView.reloadData()
                }
            }
        } catch {
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String {
                        if name == nameArray[indexPath.row] {
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            paintingArray.remove(at: indexPath.row)
                            yearArray.remove(at: indexPath.row)
                            artistArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            do {
                                try context.save()
                            } catch {
                                
                            }
                            break
                        }
                    }
                }
                
            } catch {
                
            }
        }
    }

    @IBAction func addClicked(_ sender: Any) {
        selectedPainting = ""
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondVC" {
            let destinationVC = segue.destination as! SecondViewController
            destinationVC.chosenPainting = selectedPainting
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    
}

