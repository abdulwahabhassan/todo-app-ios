//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Hassan Abdulwahab on 04/01/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

//create custom class that inherits UITableViewController and adopts SwipeTableViewCellDelegate
class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //increase row height
        tableView.rowHeight = 80.0
    }
    
    //delegate method from SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        //define SwipeAction
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            //task that should be completed when the swipe action occurs
            self.updateModel(at: indexPath)
            //reload table view
            tableView.reloadData()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete_icon")

        return [deleteAction]
    }
    
    //method will be overrided in subclasses
    func updateModel(at indexPath: IndexPath) {}
    
    //override method from superclass UITableViewController
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create reuseablecell
        //in order to implement swipeable cell using SwipeCellKit, downcast cell as SwipeTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell //do not forget to specify the Cell as a subclass of SwipeTableViewCell and its Module as SwipeCellKit in the storyboard view inspector
        //set cell delegate to self which adopts SwipeTableViewCellDelegate
        cell.delegate = self
        return cell
    }

}
