//
//  MarkViewController.swift
//  VisitedLocation
//
//  Created by lpiem on 31/01/2023.
//

import UIKit
import CoreData

class LocationViewController: UITableViewController {
    
    // MARK: - Properties
    
    var category: Category? = nil
    private var landmarks: [Landmark] = []
    private var viewContext: NSManagedObjectContext{
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        landmarks = fetchItems()
        title = category!.name
        tableView.reloadData()
    }
    
    private func fetchItems(searchText: String? = nil) -> [Landmark] {
        let fetchRequest: NSFetchRequest<Landmark> = Landmark.fetchRequest()
        
        let dateSortDescriptor = NSSortDescriptor(keyPath: \Landmark.modificationDate, ascending: false)
        let nameSortDescriptor = NSSortDescriptor(keyPath: \Landmark.title, ascending: true)
        
        fetchRequest.sortDescriptors = [dateSortDescriptor, nameSortDescriptor]
        
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "%K contains[cd] %@ && category = %@", argumentArray: [#keyPath(Landmark.title), searchText, category!])
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "category = %@", argumentArray: [category!])
        }
        
        do {
            return try viewContext.fetch(fetchRequest)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locCell", for: indexPath)
        let item = landmarks[indexPath.row]
        let itemCell = cell as! LandmarkTableViewCell
        itemCell.cellTitle.text = item.title
        itemCell.cellDescription.text = item.landmarkDescription
        itemCell.cellImage.image = UIImage(data: item.image!)
        return itemCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let index = indexPath.row
        let item = landmarks[index]
        
        viewContext.delete(item)
        saveContext()
        
        landmarks.remove(at: index)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newLocation") {
            let dest = segue.destination as! NewLocationViewController
            dest.category = category
            dest.delegate = self
        }
        if (segue.identifier == "landmarkDetails") {
            let dest = segue.destination as! DetailsViewController
            let index = tableView.indexPathForSelectedRow?.row
            dest.landmark = landmarks[index ?? 0]
        }
    }
    
}

// MARK: - extension

extension LocationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        landmarks = fetchItems(searchText: searchText)
        tableView.reloadData()
    }
}

extension LocationViewController: NewLocationViewControllerDelegate {
    func addLocationViewControllerAdd(_ controller: NewLocationViewController) {
        navigationController?.popViewController(animated: true)
    }

}

