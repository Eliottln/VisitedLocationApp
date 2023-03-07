//
//  DetailsViewController.swift
//  VisitedLocation
//
//  Created by lpiem on 07/03/2023.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var landmarkDescription: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var image: UIImageView!
    var landmark: Landmark?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = landmark?.title
        image.image = UIImage(data: (landmark?.image)!)
        date.text = landmark?.modificationDate?.formatted()
        landmarkDescription.text = landmark?.landmarkDescription
    }

}
