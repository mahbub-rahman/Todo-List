//
//  ViewController.swift
//  Todo-List
//
//  Created by mahbub rahman on 4/6/19.
//  Copyright © 2019 mahbub rahman. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: UITableViewController {

    let realm = try! Realm()
    
    var todoItems : Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
   // let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        print(dataFilePath ?? "")
       
    }
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.color {
            title = selectedCategory!.name
            updateNavBar(withColorHexCode: colourHex)
            
        }
       
    }
    override func viewWillDisappear(_ animated: Bool) {
       updateNavBar(withColorHexCode:  "1D9BF6")
    }
    
    //    MARK: NavBar Setup method
    func updateNavBar(withColorHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller does not exist.")}
        
        if let navBarColor = UIColor(hexString: colorHexCode){
            
            navBar.barTintColor = navBarColor
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            
            searchBar.barTintColor = navBarColor
        }
    }
    
    
    //MARK: - Tablview Datasourse method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row]{
        
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
    
            if let colour =  UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:
                    CGFloat(indexPath.row)/CGFloat((todoItems?.count)!)){
                    
                    cell.backgroundColor = colour
                    cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:colour, isFlat:true)

            }
            
        }else {
            cell.textLabel?.text = "No Item Added"
        }
        
        
        return cell
    }
    
    //    MARK: Tableview Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.row)
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    //realm.delete(item)
                    item.done = !item.done
                }
            }catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Add new Item
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //print("Success!")
            print(textField.text ?? "Nohing to show")
            
            if let currentCategory = self.selectedCategory {
                if let itemText = textField.text {
                    do{
                        try self.realm.write {
                            let item = Item()
                            item.title = itemText
                            item.dateCreated = Date()
                            currentCategory.items.append(item)
                        }
                    }catch {
                        print("Error saving items\(error)")
                    }
                }
            }
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func loadItems()  {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
}
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
   
}

