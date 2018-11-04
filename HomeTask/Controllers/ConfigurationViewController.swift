//
//  ConfigurationViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI


class ConfigurationViewController: UIViewController {
    
    // Mark: IBOutlet
    
    @IBOutlet weak var familyEmailAddress: UILabel!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var familyMemberList: UIPickerView!
    
    // Mark: IBAction
    
    @IBAction func updateName(_ sender: Any) {
        let data = [Constants.FamilyFields.family: email! as String]
        updateFamilyMember(data: data)
    }
    
    @IBAction func logout(_ sender: Any) {
        client.signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openFamilyMemberList(_ sender: Any) {
        familyMemberList.isHidden = false
    }
    
    // Mark: Properties
    
    var email: String?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let client = FirebaseClient.shared
    var familyExisting = false
    var selectedMemberIdx = 0
    
    // Mark: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        familyEmailAddress.text = email
        familyMemberList.isHidden = true
        familyMemberList.delegate = self
        familyMemberList.dataSource = self
        familyMemberList.layer.borderWidth = 1
        fullName.text = appDelegate.user
    }
    

    // Mark: Functions
    
    private func updateFamilyMember(data: [String:Any]) {
        var mdata = data
        mdata[Constants.FamilyFields.name] = [fullName.text] as? [String]

        let familyId = Utils.getHash(email!)
        
        if !familyExisting {
            client.addFamily(familyId: familyId, mdata: mdata)
        }
        else {
            if let name = fullName.text {
                if !(self.appDelegate.family.names.contains(name)) {
                    if selectedMemberIdx == 0 {
                        if !name.isEmpty {
                            self.appDelegate.family.names.append(name)
                        }
                    }
                    else {
                        if !name.isEmpty {
                            self.appDelegate.family.names[selectedMemberIdx-1] = name
                        }
                        else {
                            self.appDelegate.family.names.remove(at: selectedMemberIdx-1)
                        }
                    }
                    let family: [String: Any] = [
                        "family": email ?? "",
                        "name": self.appDelegate.family.names
                    ]
                    client.updateFamilyMember(familyId: familyId, mdata: family)
                }
                else if name.isEmpty {
                    self.appDelegate.family.names.remove(at: selectedMemberIdx-1)
                }
            }
        }
    }
}



extension ConfigurationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Mark: UIPickerViewDelegate and UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appDelegate.family.names.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < appDelegate.family.names.count {
            return appDelegate.family.names[row]
        }
        else {
            return "New Member"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < appDelegate.family.names.count {
            selectedMemberIdx = row + 1
            fullName.text = appDelegate.family.names[row]
            UserDefaults.standard.set(fullName.text, forKey: "user")
            appDelegate.user = fullName.text
        }
        else {
            selectedMemberIdx = 0
            fullName.text = ""
        }
        familyMemberList.isHidden = true
    }
}
