//
//  TaskTableViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 25/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class TaskTableViewController: UITableViewController {
    
    var tasks: [String: Any]! = [:]
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    fileprivate var _refHandle: DatabaseHandle!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var familyExisting = false
    var email: String?
    
    
    @IBAction func config(_ sender: Any) {
        self.performSegue(withIdentifier: "configuration", sender: nil)
    }
    

    
    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "taskDetail", sender: sender)
    }
    
    @IBAction func unwindFromTaskDetailViewController(segue: UIStoryboardSegue) {
        
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func configureStorage() {
        storageRef = Storage.storage().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        configureStorage()
        
        getFamilyMember()
        
        /*
        let familyId = Utils.getHash(email!)
        _refHandle = ref.child("tasks").queryOrderedByKey().queryEqual(toValue: familyId).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let groups = snapshot.value as! [String: Any]
            
            self.tasks = groups
            self.tableView.reloadData()

        })
        */
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let familyId = Utils.getHash(email!)
        _refHandle = ref.child("tasks").queryOrderedByKey().queryEqual(toValue: familyId).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            let groups = snapshot.value as! [String: Any]
            
            self.tasks = groups
            self.tableView.reloadData()

        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let task = Array(tasks)[indexPath.row].value as! [String: String]
        let title = task[Constants.TasksFields.title] ?? "[title]"
        let due = task[Constants.TasksFields.due] ?? "[now]"
        
        cell.taskTitle.text = title
        cell.taskDue.text = due
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "taskDetail", sender: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    func getFamilyMember() {
        let familyId = Utils.getHash(email!)
        ref.child("families").child(familyId).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil {
                let email = value?["family"] as? String ?? ""
                let names = value?["name"] as? [String] ?? []
                self.appDelegate.family.email = email
                self.appDelegate.family.names = names
                self.familyExisting = true
            }
            else{
                self.familyExisting = false
            }
        }
    }
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "configuration" {
            let configurationViewController = segue.destination as! ConfigurationViewController
            configurationViewController.email = email
            configurationViewController.ref = ref
            configurationViewController.familyExisting = familyExisting
        }
        else if segue.identifier == "taskDetail" {
            let taskDetailViewController = segue.destination as! TaskDetailViewController
            taskDetailViewController.ref = ref
            taskDetailViewController.email = email
            taskDetailViewController.storageRef = storageRef
            
            if !(sender is UIBarButtonItem) {
                // View / Update exiting task
                let index = self.tableView.indexPathForSelectedRow?.row
                let task = Array(tasks)[index!].value as! [String: String]
                let taskId = Array(tasks)[index!].key
                taskDetailViewController.taskTitleText = task[Constants.TasksFields.title]
                taskDetailViewController.taskDescriptionText = task[Constants.TasksFields.description]
                taskDetailViewController.dueDate = Utils.convertToDate(dateString: (task[Constants.TasksFields.due]?.components(separatedBy: " ")[0])!)
                taskDetailViewController.name = task[Constants.TasksFields.assignee]
                taskDetailViewController.existTask = true
                taskDetailViewController.taskId = taskId
                
                if let imageUrl = task[Constants.TasksFields.imageUrl] {
                    taskDetailViewController.imageUrl = imageUrl
                }
            }
            else {
                // New Task
                taskDetailViewController.existTask = false
                
            }
        }
    }

}
