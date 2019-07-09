//
//  SecondViewController.swift
//  ArtBook
//
//  Created by Berkay Köse on 24.06.2019.
//  Copyright © 2019 Berkay Köse. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var paintingImage: UIImageView!
    @IBOutlet weak var paintingNameText: UITextField!
    @IBOutlet weak var artistNameText: UITextField!
    @IBOutlet weak var paintingYearText: UITextField!
    
    var chosenPainting = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paintingImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        paintingImage.addGestureRecognizer(gestureRecognizer)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", self.chosenPainting)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    self.paintingNameText.text = self.chosenPainting
                    
                    if let artist = result.value(forKey: "artist") as? String {
                        self.artistNameText.text = artist
                    }
                    
                    if let year = result.value(forKey: "year") as? Int {
                        self.paintingYearText.text = String(year)
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        self.paintingImage.image = image!
                    }
                }
            }
        } catch {
            
        }
        
        
    }
    
    @objc func imageTapped() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        paintingImage.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        // Attributes
        newPainting.setValue(artistNameText.text, forKey: "artist")
        newPainting.setValue(paintingNameText.text, forKey: "name")
        
        if let year = Int(paintingYearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        
        let data = paintingImage.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
        }catch {
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPainting"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
