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
    var taskTitleText: String?
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var email: String?
    var taskId: String?
    var existTask: Bool?
    var imageUrl: String?
    
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
    
    @IBAction func editTaskTitle(_ sender: Any) {
        taskTitleText = taskTitle.text
    }
    
    @IBAction func unwindFromTaskAssignViewController(segue: UIStoryboardSegue) {
        
        let taskAssignViewController = segue.source as! TaskAssignViewController
        name = taskAssignViewController.name
        dueDate = taskAssignViewController.dueDate

        if let name = name {
            taskAssignee.text = name
        }
        if let due = dueDate {
            taskDueDate.text = Utils.convertToString(date: due, dateformat: DateFormatType.date)
        }
    }
    
    @IBAction func unwindFromPhotoPickerViewController(segue: UIStoryboardSegue) {
        let photoPickerViewController = segue.source as! PhotoPickerViewController
        taskPicture.image = photoPickerViewController.photo.image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        taskPicture.addGestureRecognizer(tapGestureRecognizer)
        taskPicture.isUserInteractionEnabled = true
        
        taskDescription.layer.borderWidth = 2
        taskDescription.delegate = self
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        if let title = taskTitleText {
            taskTitle.text = title
        }
        
        if let description = taskDescriptionText {
            taskDescription.text = description
        }

        if let due = dueDate {
            taskDueDate.text = Utils.convertToString(date: due, dateformat: DateFormatType.date)
        } else {
            taskDueDate.text = Utils.convertToString(date: Date(), dateformat: DateFormatType.date)
        }
        
        if let assignee = name {
            taskAssignee.text = assignee
        } else if let assignee = appDelegate.user {
            taskAssignee.text = assignee
        }

        if let imageUrl = self.imageUrl {
            storageRef!.child(imageUrl).getData(maxSize: INT64_MAX) { (data, error) in
                guard error == nil else {
                    print("error downloading: \(error!)")
                    return
                }
                let image = UIImage.init(data: data!, scale: 50)

                DispatchQueue.main.async {
                    self.taskPicture.image = image
                }
                
            }
        }

    }
    
    @objc func back(sender: UIBarButtonItem) {
        if existTask! {
            updateTask()
        } else {
            addTask()
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    func addTask() {
        let familyId = Utils.getHash(email!)
        let imagePath = updateImage(familyId)
        let mdata = [
            Constants.TasksFields.title: taskTitle.text,
            Constants.TasksFields.description: taskDescription.text,
            Constants.TasksFields.assignee: taskAssignee.text,
            Constants.TasksFields.due: taskDueDate.text,
            Constants.TasksFields.imageUrl: imagePath
        ]
        
        ref.child("tasks").child(familyId).childByAutoId().setValue(mdata)
    }

    func updateTask() {
        let familyId = Utils.getHash(email!)
        let imagePath = updateImage(familyId)
        
        let mdata = [
            Constants.TasksFields.title: taskTitle.text,
            Constants.TasksFields.description: taskDescription.text,
            Constants.TasksFields.assignee: taskAssignee.text,
            Constants.TasksFields.due: taskDueDate.text,
            Constants.TasksFields.imageUrl: imagePath
        ]
        let taskUpdate = ["/tasks/\(familyId)/\(taskId!)": mdata]
        ref.updateChildValues(taskUpdate)
    }
    
    func updateImage(_ familyId: String) -> String? {
        let imagePath = "chat_photos/\(familyId)/\(taskId!).jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        if let image = taskPicture.image {
            let photoData = UIImageJPEGRepresentation(image, 0.8)
            self.storageRef!.child(imagePath).putData(photoData!, metadata: metadata)
            return imagePath
        }
        return nil
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        // Your action
        performSegue(withIdentifier: "photoSelection", sender: nil)
    }
}

extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        taskDescriptionText = textView.text
    }
}
