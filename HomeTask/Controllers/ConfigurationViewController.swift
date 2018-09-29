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
import CommonCrypto

class ConfigurationViewController: UIViewController {

    var email: String?
    var ref: DatabaseReference!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var familyExisting = false
    
    @IBOutlet weak var familyEmailAddress: UILabel!
    @IBOutlet weak var fullName: UITextField!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        familyEmailAddress.text = email
        // Do any additional setup after loading the view.
        getFamilyMember()
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
        //mdata[Constants.FamilyFields.family] = email
        //ref.child("families").childByAutoId().child("name").setValue(mdata)
        //var id = ref.child("families").childByAutoId()
        //ref.child("families").child("haowu74").child("email").setValue(mdata)
        let familyId = getHash(email!)
        if !familyExisting {
            ref.child("families").child(familyId).setValue(mdata)
        }
        else {
            if let name = fullName.text {
                if !(self.appDelegate.family.names.contains(name)) {
                    self.appDelegate.family.names.append(name)
                    let family: [String: Any] = [
                        "family": email ?? "",
                        "name": self.appDelegate.family.names
                    ]
                    let familyUpdate = ["/families/\(familyId)": family]
                    ref.updateChildValues(familyUpdate)
                }
            }
        }
    }
    
    func getFamilyMember() {
        let familyId = getHash(email!)
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
    
    private func getHash(_ string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
