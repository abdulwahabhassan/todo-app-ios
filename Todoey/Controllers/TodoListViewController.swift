//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemsArray = [Item]()
    var todoArray = [Todo]()
    
    //create an interface to the user's defaults database to be used for persistent local storage of defaults (key-value data). User defaults get saved in a plist file. User default should be used only for saving small bits of data
    let defaults = UserDefaults.standard //(in cases when using userdefault to save standard key-value data)
    
    //create data file path that points to a plist where we'll save custom data which adopt the codable protocol
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //in cases when using coredata to save to sqlite database
    //retrieve the context(which is technically the staging area) of the coredata persistentContainer from the app's delegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print file path so we can visually see the data that we save to the plist
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)
        
        //retrieve todos from plist
        //loadItems() //commented out cause I am loading todos from coredata now
        loadTodos()
    }
    
    func loadTodos() {
        //create a fetch request
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        //using the context of our core data which is the mediator by which we perform any operation in the sqlite database
        do {
            //fetch request and assign result to todArray
            todoArray = try context.fetch(request)
        } catch {
            print("error fetching request \(error)")
        }
    }
    
    //method to retrieve data from plist
    func loadItems() {
        //retrieve array of todos from user Defaults with the specified key if it exists. (in cases when using userdefault to save standard key-value data)
//        if let items = defaults.array(forKey: "todoListArray") as? [Item] {
//            itemsArray = items
//        }
        //initialize a data with the contents of a url (in this case, the file path for our plist)
        if let data = try? Data(contentsOf: dataFilePath!) { //because the initialization is capable of thrwing an error, hence, we try it first
            //initialize a PropertyListDecoder
            let decoder = PropertyListDecoder()
            do {
                //using the decoder, decode data retrieved from dataFilePath and assign it as the value of itemsArray
                itemsArray = try decoder.decode([Item].self, from: data)
            } catch {
                print(error)
            }
            
        }
    }

    //override the tableview data source methods from UITableViewController required to populate the tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return number of rows for the tableview
        //return itemsArray.count //commented out cause I'm using todoArray with coredata now
        return todoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create and return a reuseable table view cell
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        //tableViewCell.textLabel?.text = itemsArray[indexPath.row].title //commented out cause I'm using todoArray with coredata now
        tableViewCell.textLabel?.text = todoArray[indexPath.row].title
        //set accessoryType
        setAccessoryType(tableViewCell, indexPath.row)
        return tableViewCell
    }
    
    //override the tableview delegte methods from UITableViewController required to respond to changes and events in the table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //toggle accessoryType
        //itemsArray[indexPath.row].toggleCheck() //commented out cause I am working with data from todoArray retrieved from coredata
        todoArray[indexPath.row].done = !todoArray[indexPath.row].done //retrieve Todo object as an NSManaged object and update its done value
        //set accessoryType
        setAccessoryType(cell, indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true) //to clear the selection indicator on the background
        
        //save items
        //saveItems() //commented out cause I am saving data to coredata now no longer user defaults or codable which uses plist
        
        //save todos
        saveTodos()
    }
    
    //method to set cell accessoryType
    func setAccessoryType(_ cell: UITableViewCell?, _ row: Int) {
        //using swift ternary operator. If Item.done is true, let accessorytype = checkmark else none
        //cell?.accessoryType = itemsArray[row].done ? .checkmark : .none //commented out cause I'm using todoArray with coredata now
        cell?.accessoryType = todoArray[row].done ? .checkmark : .none
    }
    //create IBAction for addButton when pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //create text field that will be shown in alertContoller
        var textField = UITextField()
        //create a UIAlert that will be displayed to the user by initializing a UIAlertController which
        let alertController = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        //create an UIAlertAction to be performed when a user click this action represented by a button with a title and style
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //declare what should happen when user clicks on this action
            print("Success")
            if let text = textField.text {
                
                //append item to array (in cases when using userdefault to save standard key-value data or using codable to save custom data types to plist)
                //self.itemsArray.append(Item(title: text)) //commented out cause I am working with coredata now
                //save items
                //self.saveItems() //commented out cause I'm using core data now
                
                //in cases when using coredata to save to sqlite database
                //create a new instance of the core data DataModel and pass the context of the persistent container
                let todo = Todo(context: self.context)
                //set the properties of todo and save context
                todo.title = text
                todo.done = false
                //append new todo to todoArray
                self.todoArray.append(todo)
                //save todos
                self.saveTodos()
                
                //reload tableview to display newly added data
                self.tableView.reloadData()
            }
           
        }
        //add textfield to alertController
        alertController.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = "Create new item"
        }
        //add action to alertController
        alertController.addAction(action)
        //present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    func saveTodos() {
        //save data to sqlite database using coredata
        do {
            try context.save() //save the updated context
        } catch {
            print("error saving context \(error)")
        }
    }
    
    func deleteTodo(row: Int) {
        //delete from context and then the array used to populate the tableview datasource. This order matters
        context.delete(todoArray[row])
        todoArray.remove(at: row)
        //as always, after every happy operation via the context, save context
        saveTodos()
    }
    
    //method to save data to plist
    func saveItems() {
        //save updated array to user defaults database which is a plist (in cases when using userdefault to save standard key-value data)
        //self.defaults.set(self.itemsArray, forKey: "todoListArray") //commented out cause I am using core data now
        //save updated array which contains custom data type to the plist we created using PropertyListEncoder (in cases when using codable)
        let encoder = PropertyListEncoder()
        do { //because the encode method can throw, we have to call it with a try keyword inside a do/catch block
            let data = try encoder.encode(itemsArray)
            //write the data to the data file path we created
            try data.write(to: dataFilePath!)
        } catch {
            print("error encoding itemsArray\(error)")
        }
        
        
    }
    
}

