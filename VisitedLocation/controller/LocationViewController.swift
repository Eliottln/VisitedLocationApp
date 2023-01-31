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
    
    var locationName: String?
    private var landmarks: [Landmark] = []
    private var viewContext: NSManagedObjectContext{
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        landmarks = fetchItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = locationName
    }
    
    private func fetchItems(searchText: String? = nil) -> [Landmark] {
        let fetchRequest: NSFetchRequest<Landmark> = Landmark.fetchRequest()
        
        let dateSortDescriptor = NSSortDescriptor(keyPath: \Landmark.modificationDate, ascending: false)
        let nameSortDescriptor = NSSortDescriptor(keyPath: \Landmark.title, ascending: true)
        
        fetchRequest.sortDescriptors = [dateSortDescriptor, nameSortDescriptor]
        
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "%K contains[cd] %@", argumentArray: [#keyPath(Landmark.title), searchText])
        }
        
        do {
            return try viewContext.fetch(fetchRequest)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locCell", for: indexPath)
        let item = landmarks[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.creationDate?.formatted()
        return cell
    }
    
    
    
}

extension LocationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        landmarks = fetchItems(searchText: searchText)
        tableView.reloadData()
    }
}
