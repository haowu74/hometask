//
//  TaskAssignViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class TaskAssignViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var name: String?
    var dueDate: Date?
    
    @IBOutlet weak var familyMemberList: UIPickerView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
 
    @IBAction func dueDateSelected(_ sender: Any) {
        dueDate = dueDatePicker.date
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        familyMemberList.delegate = self
        familyMemberList.dataSource = self
        name = appDelegate.family.names[0]
        familyMemberList.selectRow(0, inComponent: 0, animated: false)
        dueDate = Date()
        dueDatePicker.setDate(dueDate!, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        performSegue(withIdentifier: "unwindTaskAssigneeDue", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

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
