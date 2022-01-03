//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hassan Abdulwahab on 03/01/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoriesArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        fetchCategories(with: request)
    }
    
    func fetchCategories(with request: NSFetchRequest<Category>) {
        do {
            categoriesArray = try context.fetch(request)
        } catch {
            print("error fetching categories\(error)")
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //create text field that will be shown in alertContoller
        var textField = UITextField()
        //create a UIAlert that will be displayed to the user by initializing a UIAlertController
        let alertController = UIAlertController(title: "Add New Todo Category", message: "", preferredStyle: .alert)
        //create an UIAlertAction to be performed when a user click this action represented by a button with a title and style
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if let text = textField.text {
                //initialize a new Category(NSManagedObject), pass context of coredata retrieved from persistent container of app's delegate method
                let category = Category(context: self.context)
                //set category name to equal to text entered in UIAlert's text field
                category.name = text
                //append new category to array
                self.categoriesArray.append(category)
                //save
                self.saveCategory()
                //reload tableView
                self.tableView.reloadData()
            }
        }
       
        //add created text field to alertController
        alertController.addTextField { (alertTextField) in
            //make a global reference to the textfield since its value will be used outside of this scope
            textField = alertTextField
            //set place holder for the text field
            textField.placeholder = "Create new item"
        }
        
        //add the UIAlertAction we created to the alert controller
        alertController.addAction(action)
        //presemt the alert controlleer with animation
        present(alertController, animated: true, completion: nil)
    }
    
    func saveCategory() {
        //save data to sqlite database using coredata
        do {
            try context.save() //save the updated context
        } catch {
            print("error saving context \(error)")
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoriesArray[indexPath.row].name
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
                destinationVC.selectedCategory = categoriesArray[indexPath.row]
            }
        }
    }

}
