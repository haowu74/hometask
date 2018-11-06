//
//  TaskTableViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 25/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {
    
    // Mark: IBOutlet
    
    @IBOutlet weak var showCompletedButton: UIBarButtonItem!
    @IBOutlet weak var showOnlyMyTasksButton: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    
    // Mark: IBAction
    
    @IBAction func config(_ sender: Any) {
        self.performSegue(withIdentifier: "configuration", sender: nil)
    }
    
    @IBAction func toggleShowingCompletedTasks(_ sender: UIBarButtonItem) {
        showCompletedTask = !showCompletedTask
        if showCompletedTask {
            sender.title = "Hide Completed"
        }
        else {
            sender.title = "Show Completed"
        }
        filteredTasks = tasks.filter(filterTasks)
        tableView.reloadData()
    }
    
    @IBAction func toggleShowingAllTasks(_ sender: UIBarButtonItem) {
        onlyShowMyTask = !onlyShowMyTask
        if onlyShowMyTask {
            sender.title = "All Tasks"
        }
        else {
            sender.title = "My Tasks"
        }
        filteredTasks = tasks.filter(filterTasks)
        tableView.reloadData()
    }
    
    @IBAction func sortByDate(_ sender: UIBarButtonItem) {
        sortByDateAscending = !sortByDateAscending
        sender.title = "Sort"
        filteredTasks = filteredTasks.sorted(by: sortTasks)
        tableView.reloadData()
    }
    
    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "taskDetail", sender: sender)
    }
    
    @IBAction func unwindFromTaskDetailViewController(segue: UIStoryboardSegue) {
        // Todo: Segue unwind from TaskDetailViewController
    }
    
    // Mark: Propeties
    
    var tasks: [(key: String, value: Any)]! = []
    var filteredTasks: [(key: String, value: Any)]! = []

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var familyExisting = false
    var email: String?
    var connected = false
    
    // TableView Display options
    var showCompletedTask = false
    var onlyShowMyTask = false
    var sortByDateAscending = false
    
    let client = FirebaseClient.shared
    
    var indicator = UIActivityIndicatorView()
    
    // Mark: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator()
        client.getConnectionState { (snapshot) in
            if snapshot.value as? Bool ?? false {
                self.connected = true
            } else {
                self.connected = false
            }
        }
        self.getFamilyMember()
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
        
        self.hideKeyboardWhenTappedAround()
        
        let familyId = Utils.getHash(email!)
        client.queryTask(familyId: familyId) { (snapshot) in
            if (snapshot.childrenCount > 0) {
                let family = snapshot.value as! [String: Any]
                let groups = family.first?.value as! [String: Any]
                let sortedGroup = groups.sorted(by: self.sortTasks)
                self.tasks = sortedGroup
                self.filteredTasks = self.tasks.filter(self.filterTasks)
            }
            else {
                self.filteredTasks.removeAll()
            }
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
            self.tableView.reloadData()
        }
    }

    // MARK: - Table View Delegator and Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let task = Array(filteredTasks)[indexPath.row].value as! [String: String]
        let title = task[Constants.TasksFields.title] ?? "[title]"
        let due = task[Constants.TasksFields.due] ?? "[now]"
        
        let completed = task[Constants.TasksFields.completed] == "true" ? true : false
        
        let taskTitle = NSMutableAttributedString(string: title)
        let taskDue = NSMutableAttributedString(string: due)
        if completed {
            taskTitle.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, taskTitle.length))
            taskDue.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, taskDue.length))
        }
        cell.taskTitle.attributedText = taskTitle
        cell.taskDue.attributedText = taskDue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "taskDetail", sender: nil)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "configuration" {
            let configurationViewController = segue.destination as! ConfigurationViewController
            configurationViewController.email = email

            configurationViewController.familyExisting = familyExisting
        }
        else if segue.identifier == "taskDetail" {
            let taskDetailViewController = segue.destination as! TaskDetailViewController
            taskDetailViewController.email = email
            
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
                taskDetailViewController.completed = task[Constants.TasksFields.completed] == "true"
                taskDetailViewController.connected = connected
                if let imageUrl = task[Constants.TasksFields.imageUrl] {
                    taskDetailViewController.imageUrl = imageUrl
                }
            }
            else {
                // New Task
                taskDetailViewController.existTask = false
                taskDetailViewController.completed = false
                taskDetailViewController.connected = connected
            }
        }
    }
    
    // Mark: Functions
    
    private func sortTasks(task1: (key: String, value: Any), task2: (key: String, value: Any)) -> Bool {
        let t1 = task1.value as! [String: String]
        let t2 = task2.value as! [String: String]
        let due1 = Utils.convertToDate(dateString: (t1[Constants.TasksFields.due]?.components(separatedBy: " ")[0])!)
        let due2 = Utils.convertToDate(dateString: (t2[Constants.TasksFields.due]?.components(separatedBy: " ")[0])!)
        if sortByDateAscending {
            return due1 < due2
        }
        else {
            return due1 > due2
        }
    }

    private func filterTasks(task: (key: String, value: Any)) -> Bool {
        let t = task.value as! [String: String]
        let completed = t[Constants.TasksFields.completed]
        let assignee = t[Constants.TasksFields.assignee]
        if !showCompletedTask {
            if completed == "true" {
                return false
            }
        }
        if onlyShowMyTask {
            if assignee != appDelegate.user {
                return false
            }
        }
        return true
    }
    
    private func getFamilyMember() {
        let familyId = Utils.getHash(email!)
        client.queryFamily(familyId: familyId) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["family"] as? String ?? ""
            let names = value?["name"] as? [String] ?? ["Default"]
            self.appDelegate.family.email = email
            self.appDelegate.family.names = names
            if value == nil {
                let data = [Constants.FamilyFields.family: self.email! as String]
                self.client.addFamily(familyId: familyId, mdata: data)
            }
            self.familyExisting = true
        }
    }
    
    private func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 3)
        self.view.addSubview(indicator)
    }
}
