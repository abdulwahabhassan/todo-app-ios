//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

//subclass SwipeTableViewController 
class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm() //initialize realm
    var realmTodos: Results<RealmTodo>?
    var selectedCategory: RealmCategory? {
        didSet { //everything within these curly braces will be run once the value of selectedCategory is set. This ensures the code we write here will only be triggered when the value of selectedCategory has been set.
            loadTodos()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set searchbar delegate as self (we alredy did this via the main story board by linking the serachbar's delegate to TodoListViewController, hence we don't need do it in code. So here's another multiple ways of doing the same thing)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
    }
    
    func loadTodos() {
        realmTodos = selectedCategory?.todos.sorted(byKeyPath: "title", ascending: true) //retrieve the todos in the selected category and sort them by title in ascending order
    }

    //override the tableview data source methods from SwipeTableViewController required to populate the tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return number of rows for the tableview
        return realmTodos?.count ?? 1
    }
    
    //override the tableview methods from SwipeTableViewController
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //tap into superclass and retrieve reusablecell
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
       
        //assign todo title to cell text label if it is not nil
        //set cell textlabel
        if let todo = realmTodos?[indexPath.row] {
            cell.textLabel?.text = todo.title
            //set accessoryType
            setAccessoryType(todo, cell, indexPath.row)
        } else {
            cell.textLabel?.text = "No Todos added yet"
        }
        
        return cell
    }
    
    //override the tableview methods from SwipeTableViewController required to respond to changes and events in the table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //retrieve the todo corresponding to the selected row
        if let todo = realmTodos?[indexPath.row] {
            updateTodoStatus(todo)
        }
        tableView.deselectRow(at: indexPath, animated: true) //to clear the selection indicator on the background
        //reload tableview
        tableView.reloadData()
    }
    
    //override method from SwipeTableViewController. This method is called when a swipe action is performed
    override func updateModel(at indexPath: IndexPath) {
        if let todo = realmTodos?[indexPath.row] {
            deleteTodo(todo: todo)
        }
    }
    
    //method to delete todo
    func deleteTodo(todo: RealmTodo) {
        do {
            try realm.write {
                realm.delete(todo)
            }
        } catch {
            print("error deleting todo from realm \(error)")
        }
    }
    
    //method to update todo status by writing to realm
    func updateTodoStatus(_ todo: RealmTodo) {
        do {
            try realm.write{
                todo.done = !todo.done
            }
        } catch {
            print("error updating todo to realm \(error)")
        }
    }
    
    //method to set cell accessoryType
    func setAccessoryType(_ todo: RealmTodo, _ cell: UITableViewCell?, _ row: Int) {
        //using swift ternary operator. If todo.done is true, let accessorytype = checkmark else none
        cell?.accessoryType = todo.done ? .checkmark : .none
    }
    
    //create IBAction for addButton when pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //create text field that will be shown in alertContoller
        var textField = UITextField()
        //create a UIAlert that will be displayed to the user by initializing a UIAlertController which
        let alertController = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        //create an UIAlertAction to be performed when a user click this action represented by a button with a title and style
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let text = textField.text {
                
                //initialize new todo from RealmTodo
                let todo = RealmTodo()
                todo.title = text //set title of todo
                //save todos
                self.appendTodoToCategory(todo)
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
    
    func appendTodoToCategory(_ realmTodo: RealmTodo) {
        //save data to realm
        if let category = self.selectedCategory {
            do {
                try realm.write{
                    category.todos.append(realmTodo) //append new todo to category
                }
            } catch {
                print("error appending todo to category \(error)")
            }
        }
        
    }
}
    

//MARK: - UISearchDisplay Delegate
extension TodoListViewController: UISearchBarDelegate {
    
    //implement the delegate methods we wish to respond to when a user takes an action on the search bar
    
    //this method will be triggered once the user click the searchBar search button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //because the delegate method 'func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)' is already taking care of the search as the search text changes, we don't need to do much when the search button is clicked by the user since the result of the search will already be available even before they clcik the search button. We can simply just reload the table view
        
        //reload tableview
        tableView.reloadData()
    }
    
    //method will be called whenever search text changes, if empty, load all todos, else query the data base with search text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadTodos()
            //unfocus the searchbar, close down keyboard
            //codes that affect the UI must be run asycnchronously and dispatched to the main
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            filterAndSortTodos(searchText)
        }
        //reload tableview to display retrieved data
        tableView.reloadData()
    }
    
    func filterAndSortTodos(_ searchText: String) {
        //filter todos using an NSPredicate format which checks for todos whose title contains the searchbar text. Sort the returned todos in ascending date order
        realmTodos = realmTodos?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
    }

    
    
}

