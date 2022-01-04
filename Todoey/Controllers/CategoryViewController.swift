//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hassan Abdulwahab on 03/01/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift //import RealmSwift

class CategoryViewController: UITableViewController {
    
    //initialize realm
    let realm = try! Realm()
    var realmCategories: Results<RealmCategory>? //this type is the data type we get from realm when we query for items in the database. This will hold the results from querying all the categories in the database
   

    override func viewDidLoad() {
        super.viewDidLoad()
        //load categories when view loads
        loadCategories()

    }
    
    func loadCategories() {
        realmCategories = realm.objects(RealmCategory.self) //fetch all categories in realm
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //create text field that will be shown in alertContoller
        var textField = UITextField()
        //create a UIAlert that will be displayed to the user by initializing a UIAlertController
        let alertController = UIAlertController(title: "Add New Todo Category", message: "", preferredStyle: .alert)
        //create an UIAlertAction to be performed when a user click this action represented by a button with a title and style
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if let text = textField.text {
                //iinitialize a new RealmCategory
                let category = RealmCategory()
                //set category name
                category.name = text //set name to equal text
                self.saveCategory(category) //save category to realm
                self.tableView.reloadData()
            }
        }
       
        //add created text field to alertController
        alertController.addTextField { (alertTextField) in
            //make a global reference to the textfield since its value will be used outside of this scope
            textField = alertTextField
            //set place holder for the text field
            textField.placeholder = "Create new category"
        }
        
        //add the UIAlertAction we created to the alert controller
        alertController.addAction(action)
        //presemt the alert controlleer with animation
        present(alertController, animated: true, completion: nil)
    }
    
    func saveCategory(_ category: RealmCategory) {
        //save the category to realm
        do {
            try realm.write{
                realm.add(category) //add category to realm
            }
        } catch {
            print("error saving category to realm \(error)")
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmCategories?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = realmCategories?[indexPath.row].name ?? "No Categories Added yet"
        return cell
    }
    
    //MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //perfrom segue to TodoListController when a cell is selected. Prior to performing segue, we need to prepare the viewContoller for segue
        performSegue(withIdentifier: "goToTodos", sender: self)
    }
    
    //method will be called prior to performing the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //because this method will be called any number of times prior to performing any segue, in case where our view controller may have multiple segues, we must first check that the identifier of the segue corresponds to the segue we want to perform before retrieving its destination and downcasting it to the sepcific view controller the segue is linked to
        if segue.identifier == "goToTodos" {
            let destinationVC = segue.destination as! TodoListViewController
            //grab the category of the selected cell row using tableView.indexPathForSelectedRow which returns the indexpath for the selected row
            if let indexPath = tableView.indexPathForSelectedRow {
                //set the selectedCategory property in the destinationVC(TodoListViewController) to equal the category of the selected row
                destinationVC.selectedCategory = realmCategories?[indexPath.row]
            }
        }
    }

}
