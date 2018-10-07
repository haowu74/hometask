//
//  ConfigurationViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI


class ConfigurationViewController: UIViewController {

    var email: String?
    var ref: DatabaseReference!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var familyExisting = false
    var selectedMemberIdx = 0
    
    @IBOutlet weak var familyEmailAddress: UILabel!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var familyMemberList: UIPickerView!
    
    @IBAction func updateName(_ sender: Any) {
        let data = [Constants.FamilyFields.family: email! as String]
        updateFamilyMember(data: data)
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openFamilyMemberList(_ sender: Any) {
        familyMemberList.isHidden = false
    }
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func updateFamilyMember(data: [String:Any]) {
        var mdata = data
        mdata[Constants.FamilyFields.name] = [fullName.text] as? [String]

        let familyId = Utils.getHash(email!)
        if !familyExisting {
            ref.child("families").child(familyId).setValue(mdata)
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
                    let familyUpdate = ["/families/\(familyId)": family]
                    ref.updateChildValues(familyUpdate)
                }
                else if name.isEmpty {
                    self.appDelegate.family.names.remove(at: selectedMemberIdx-1)
                }
            }
        }
    }
}

// Mark: Extension for UIPickerViewDelegate and UIPickerViewDataSource

extension ConfigurationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
