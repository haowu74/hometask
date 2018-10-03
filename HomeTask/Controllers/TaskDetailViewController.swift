//
//  TaskDetailViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class TaskDetailViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var name: String?
    var dueDate: Date?
    var taskDescriptionText: String?
    var ref: DatabaseReference!
    var email: String?
    
    @IBOutlet weak var taskPicture: UIImageView!
    @IBOutlet weak var taskTitle: UITextField!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskAssignee: UITextField!
    @IBOutlet weak var taskDueDate: UITextField!
    
    @IBAction func editTaskAssignee(_ sender: Any) {
        self.performSegue(withIdentifier: "taskAssigneeDue", sender: nil)
    }
    
    @IBAction func editTaskDueDate(_ sender: Any) {
        self.performSegue(withIdentifier: "taskAssigneeDue", sender: nil)
    }
    
    @IBAction func unwindFromTaskAssignViewController(segue: UIStoryboardSegue) {
        
        let taskAssignViewController = segue.source as! TaskAssignViewController
        name = taskAssignViewController.name
        dueDate = taskAssignViewController.dueDate

        if let name = name {
            taskAssignee.text = name
        }
        if let due = dueDate {
            taskDueDate.text = due.description
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        taskDescription.layer.borderWidth = 2
        taskDescription.delegate = self

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        addTask()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addTask() {
        let familyId = Utils.getHash(email!)
        let mdata = [
            Constants.TasksFields.title: taskDescriptionText,
            Constants.TasksFields.assignee: name,
            Constants.TasksFields.due: dueDate?.description
        ]
        
        ref.child("tasks").child(familyId).childByAutoId().setValue(mdata)
    }

}

extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        taskDescriptionText = textView.text
    }
}
