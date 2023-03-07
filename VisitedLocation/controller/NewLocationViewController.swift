//
//  NewLocationViewController.swift
//  VisitedLocation
//
//  Created by lpiem on 28/02/2023.
//

import UIKit
import CoreData

class NewLocationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var locationDescription: UITextField!
    var category: Category? = nil
    var delegate: NewLocationViewControllerDelegate?
    var imagePicker = UIImagePickerController()
    
    private var viewContext: NSManagedObjectContext{
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageView.image = selectedImage
        print(info.keys)
        self.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    @IBAction func updateDoneButton(_ sender: Any) {
        doneButton.isEnabled = locationName.hasText && locationDescription.hasText
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        let coordinate = Coordinate(context: viewContext)
        coordinate.latitude = 37.33233141
        coordinate.longitude = -122.0312186
        
        let item = Landmark(context: viewContext)
        item.title = locationName.text
        item.isFavorite = false
        item.landmarkDescription = locationDescription.text
        item.creationDate = Date()
        item.modificationDate = Date()
        item.category = category
        item.coordinate = coordinate
        if let image = imageView.image {
            if let imageData = image.pngData() {
                item.image = imageData
            }
        }
        saveContext()
        delegate?.addLocationViewControllerAdd(self)
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}

protocol NewLocationViewControllerDelegate: AnyObject {
    func addLocationViewControllerAdd(_ controller: NewLocationViewController)
}

