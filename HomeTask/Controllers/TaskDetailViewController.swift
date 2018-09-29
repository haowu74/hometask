//
//  TaskDetailViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskDescription.layer.borderWidth = 2
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
