//
//  TaskAssignViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

class TaskAssignViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Mark: IBOutlet
    
    @IBOutlet weak var familyMemberList: UIPickerView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
 
    // Mark: IBAction
    
    @IBAction func dueDateSelected(_ sender: Any) {
        dueDate = dueDatePicker.date
    }
    
    // Mark: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let client = FirebaseClient.shared
    var name: String?
    var dueDate: Date?
    
    // Mark: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        familyMemberList.delegate = self
        familyMemberList.dataSource = self
        if dueDate == nil {
            dueDate = Date()
        }
        if name == nil {
            name = appDelegate.family.names[0]
        }
        let index =  appDelegate.family.names.firstIndex(of: name!)
        if let index = index {
            familyMemberList.selectRow(index, inComponent: 0, animated: false)
        } else {
            familyMemberList.selectRow(0, inComponent: 0, animated: false)
        }
    
        dueDatePicker.setDate(dueDate!, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        performSegue(withIdentifier: "unwindTaskAssigneeDue", sender: self)
    }
    

    // Mark: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    // Mark: UIPickerViewDelegate, UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appDelegate.family.names.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return appDelegate.family.names[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        name = appDelegate.family.names[row]
    }
    
}
