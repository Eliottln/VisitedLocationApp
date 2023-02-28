//
//  ViewController.swift
//  VisitedLocation
//
//  Created by lpiem on 31/01/2023.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    // MARK: - Properties
    
    private var categories: [Category] = []
    private var viewContext: NSManagedObjectContext{
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = fetchItems()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    //MARK: - CoreData Methods
    
    private func fetchItems(searchText: String? = nil) -> [Category] {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        let dateSortDescriptor = NSSortDescriptor(keyPath: \Category.modificationDate, ascending: false)
        let nameSortDescriptor = NSSortDescriptor(keyPath: \Category.name, ascending: true)
        
        fetchRequest.sortDescriptors = [dateSortDescriptor, nameSortDescriptor]
        
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "%K contains[cd] %@", argumentArray: [#keyPath(Category.name), searchText])
        }
        
        do {
            return try viewContext.fetch(fetchRequest)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func createItem(name: String) {
        let item = Category(context: viewContext)
        item.name = name
        item.creationDate = Date()
        item.modificationDate = Date()
        saveContext()
    }
    
    private func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    // MARK: - UITableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCell", for: indexPath)
        let item = categories[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.creationDate?.formatted()
        return cell
    }
        
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let index = indexPath.row
        let item = categories[index]
        
        viewContext.delete(item)
        saveContext()
        
        categories.remove(at: index)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //MARK: - User Interactions
    
    @IBAction private func addButtonAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Nouvelle catégorie", message: "Ajouter une catégorie à la liste", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "Nom"
        }
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel)
        let saveAction = UIAlertAction(title: "Ajouter", style: .default) { [unowned self] _ in
            guard let textField = alertController.textFields?.first else {
                return
            }
            
            self.createItem(name: textField.text!)
            self.categories = self.fetchItems()
            self.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showLocations") {
            let dest = segue.destination as! LocationViewController
            let index = tableView.indexPathForSelectedRow?.row
            dest.category = categories[index ?? 0]
        }
    }
    
}

extension CategoryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        categories = fetchItems(searchText: searchText)
        tableView.reloadData()
    }
}
