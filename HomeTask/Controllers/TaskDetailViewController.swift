//
//  TaskDetailViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import CoreData

class TaskDetailViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // Mark: IBOutlet
    
    @IBOutlet weak var taskPicture: UIImageView!
    @IBOutlet weak var taskTitle: UITextField!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskAssignee: UITextField!
    @IBOutlet weak var taskDueDate: UITextField!
    @IBOutlet weak var taskCompleted: UISegmentedControl!
    @IBOutlet weak var photoLoading: UIActivityIndicatorView!
    @IBOutlet weak var deleteTaskButton: UIButton!
    
    // Mark: IBAction
    
    @IBAction func editTaskAssignee(_ sender: Any) {
        self.performSegue(withIdentifier: "taskAssigneeDue", sender: nil)
    }
    
    @IBAction func editTaskDueDate(_ sender: Any) {
        self.performSegue(withIdentifier: "taskAssigneeDue", sender: nil)
    }
    
    @IBAction func editTaskTitle(_ sender: Any) {
        taskTitleText = taskTitle.text
    }
    
    @IBAction func deleteTask(_ sender: Any) {
        if (taskId != nil) {
            removeTask {
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
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
    
    @IBAction func completeStateChanged(_ sender: Any) {
        let taskCompletedState = sender as! UISegmentedControl
        if taskCompletedState.selectedSegmentIndex == 0 {
            completed = false
        } else {
            completed = true
        }
    }
    
    // Mark: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var name: String?
    var dueDate: Date?
    var taskDescriptionText: String?
    var taskTitleText: String?
    var email: String?
    var taskId: String?
    var existTask: Bool?
    var imageUrl: String?
    var completed: Bool?
    var familyId: String?
    var photosFetchedResultsController: NSFetchedResultsController<Photo>!
    var dataController: DataController!
    var connected: Bool!
    let client = FirebaseClient.shared
    // Mark: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskPicture.isHidden = true
        photoLoading.startAnimating()
        
        familyId = Utils.getHash(email!)
        dataController = appDelegate.dataController
        
        // Edit existing task
        if taskId != nil {
            setupFetchedResultsController()
            if  photosFetchedResultsController.fetchedObjects?.count ?? 0 > 0 {
                for photo in photosFetchedResultsController.fetchedObjects! {
                    if let image = photo.photo {
                        DispatchQueue.main.async {
                            self.taskPicture.image = UIImage(data: image)!
                            self.photoLoading.stopAnimating()
                            self.photoLoading.isHidden = true
                            self.taskPicture.isHidden = false
                        }
                    }
                }
            }
            else if connected {
                if let imageUrl = self.imageUrl {
                    client.getImage(imageUrl: imageUrl, maxSize: INT64_MAX) { (data, error) in
                        guard error == nil else {
                            print("error downloading: \(error!)")
                            return
                        }
                        let image = UIImage.init(data: data!, scale: 50)
                        
                        DispatchQueue.main.async {
                            self.taskPicture.image = image
                            self.photoLoading.stopAnimating()
                            self.photoLoading.isHidden = true
                            self.taskPicture.isHidden = false
                        }
                    }
                }
            }
        }
        // Create new task
        else {
            self.photoLoading.stopAnimating()
            self.photoLoading.isHidden = true
            self.taskPicture.isHidden = false
            self.deleteTaskButton.setTitle("Discard", for: UIControlState.normal)
        }
        
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

        client.getConnectionState { (snapshot) in
            if snapshot.value as? Bool ?? false {
                self.connected = true
            } else {
                self.connected = false
            }
        }
        
        if let completed = completed {
            taskCompleted.selectedSegmentIndex = completed ? 1 : 0;
        }

    }
    
    // Mark: Callback functions
    
    @objc func back(sender: UIBarButtonItem) {
        if existTask! {
            updateTask()
        } else {
            addTask()
        }
        savePhoto()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        performSegue(withIdentifier: "photoSelection", sender: nil)
    }
    
    // Mark: Functions
    
    private func addTask() {

        //let imagePath = updateImage(familyId!)
        let completedStr = completed ?? false ? "true" : "false"
        let title = taskTitle.text
        let description = taskDescription.text
        let assignee = taskAssignee.text
        let due = taskDueDate.text
        let mdata = [
            Constants.TasksFields.completed: completedStr,
            Constants.TasksFields.title: title,
            Constants.TasksFields.description: description,
            Constants.TasksFields.assignee: assignee,
            Constants.TasksFields.due: due,
            Constants.TasksFields.imageUrl: nil
        ]
        taskId = client.addTask(familyId: familyId!, mdata: mdata, updateImageUrl: updateImage)
    }
    
    private func updateTask() {
        
        let imagePath = updateImage(familyId: familyId!, taskId: taskId!)
        let completedStr = completed ?? false ? "true" : "false"
        let title = taskTitle.text
        let description = taskDescription.text
        let assignee = taskAssignee.text
        let due = taskDueDate.text
        let mdata = [
            Constants.TasksFields.title: title,
            Constants.TasksFields.description: description,
            Constants.TasksFields.assignee: assignee,
            Constants.TasksFields.due: due,
            Constants.TasksFields.imageUrl: imagePath,
            Constants.TasksFields.completed: completedStr
        ]
        client.updateTask(familyId: familyId!, taskId: taskId!, mdata: mdata)
    }
    
    private func removeTask(completion: @escaping () -> Void) {
        deletePhoto()
        deleteImage()
        client.deleteTask(familyId: familyId!, taskId: taskId!) { (error, reference) in
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func updateImage(familyId: String, taskId: String) -> String? {
        let imagePath = "chat_photos/\(familyId)/\(taskId).jpg"
        
        if let image = taskPicture.image {
            client.updateImage(imageUrl: imagePath, image: image)
            return imagePath
        }
        return nil
    }
    
    private func deleteImage() {
        let imagePath = "chat_photos/\(familyId!)/\(taskId!).jpg"
        client.deleteImage(imageUrl: imagePath, completion: nil)
    }
    
    // Save photo to Core Data
    private func savePhoto() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "family == %@ AND task == %@", familyId!, taskId!)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try dataController.viewContext.execute(deleteRequest)
        } catch {
            // TODO: handle the error
        }
        
        let photo = Photo(context: dataController.viewContext)
        photo.task = taskId
        photo.family = familyId
        
        if let image = taskPicture.image {
            guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                // handle failed conversion
                print("jpg error")
                return
            }
            photo.photo = imageData
            
            do {
                try dataController.viewContext.save()
            } catch {
                print("Photo Core data save failed")
            }
        }
    }
    
    // Delete photo from Core Data
    private func deletePhoto() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "family == %@ AND task == %@", familyId!, taskId!)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try dataController.viewContext.execute(deleteRequest)
        } catch {
            // TODO: handle the error
        }
    }
    
    // Mark: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "taskAssigneeDue" {
            let taskAssignViewController = segue.destination as! TaskAssignViewController
            taskAssignViewController.name = name
            taskAssignViewController.dueDate = dueDate
        }
        else if segue.identifier == "photoSelection" {
            if let img = taskPicture.image {
                let photoPickerViewController = segue.destination as! PhotoPickerViewController
                photoPickerViewController.image = img
            }
        }
    }
    
    // Mark: Firebase
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "family == %@ AND task == %@", familyId!, taskId!)
        //let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        photosFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        photosFetchedResultsController.delegate = self
        do {
            try photosFetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}

extension TaskDetailViewController: UITextViewDelegate {
    
    // Mark: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        taskDescriptionText = textView.text
    }
}
