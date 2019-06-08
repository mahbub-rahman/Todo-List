//
//  CategoryViewController.swift
//  Todo-List
//
//  Created by mahbub rahman on 8/6/19.
//  Copyright © 2019 mahbub rahman. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    
    var categories: Results<Category>?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }


    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //print("Success!")
            print(textField.text ?? "Nohing to show")
            
            
            if let itemText = textField.text {
                let item = Category()
                item.name = itemText
                           
                self.saveItems(category: item)
                
            }
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //    MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category added"
        
        
        return cell
    }
    
    //    MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            dest.selectedCategory = categories?[indexPath.row]
        }
     }
    
    //    MARK: - Data Manupulation Methods
    
    func saveItems(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData()
    }
    func loadItems()  {
       categories = realm.objects(Category.self)
        tableView.reloadData()
    }
}
