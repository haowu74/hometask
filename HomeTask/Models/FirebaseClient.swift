//
//  FirebaseClient.swift
//  HomeTask
//
//  Created by Hao Wu on 4/11/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

class FirebaseClient {
    
    // Mark: Singleton
    private init() {
        
    }
    static let shared = FirebaseClient()
    
    // Mark: Properties
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var user: User?
    
    //Mark: Functions
    
    func configureDatabase() -> DatabaseReference {
        return Database.database().reference()
    }
    
    func configureStorage() -> StorageReference {
        return Storage.storage().reference()
    }
    
    func configureAuth(success: @escaping () -> Void, fail: @escaping () -> Void) {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    success()
                }
            }
            else{
                fail()
            }
        })
    }
    
    
    func signIn() -> UIViewController {
        let authUI = FUIAuth.defaultAuthUI();
        let authViewController = authUI!.authViewController()
        
        return authViewController
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
    func getConnectionState(callback: @escaping (DataSnapshot) -> Void) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: callback)
    }
    
    func queryFamily(familyId: String, callback: @escaping (DataSnapshot) -> Void) {
        ref.child("families").child(familyId).observeSingleEvent(of: DataEventType.value, with: callback)
    }
    
    func addFamily(familyId: String, mdata: [String: Any]) {
        ref.child("families").child(familyId).setValue(mdata)
    }
    
    func updateFamilyMember(familyId: String, mdata: [String:Any]) {
        let familyUpdate = ["/families/\(familyId)": mdata]
        ref.updateChildValues(familyUpdate)
    }
    
    func queryTask(familyId: String, callback: @escaping (DataSnapshot) -> Void) {
        ref.child("tasks").queryOrderedByKey().queryEqual(toValue: familyId).observe(DataEventType.value, with: callback)
    }
    
    func getImage(imageUrl: String, maxSize: Int64, callback: @escaping (Data?, Error?) -> Void) -> Void {
        storageRef!.child(imageUrl).getData(maxSize: maxSize, completion: callback)
    }
    
    func deleteImage(imageUrl: String, completion: ((Error?) -> Void)?) {
        self.storageRef!.child(imageUrl).delete(completion: completion)
    }
    
    func updateImage(imageUrl: String, image: UIImage) -> Void {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let photoData = UIImageJPEGRepresentation(image, 0.8)
        self.storageRef!.child(imageUrl).putData(photoData!, metadata: metadata)
    }
    
    func addTask(familyId: String, mdata: [String: String?], updateImageUrl: @escaping (String, String) -> String?) -> String? {
        let reference = ref.child("tasks").child(familyId).childByAutoId()
        let taskId = reference.key
        let imageUrl = updateImageUrl(familyId, taskId!)
        var data = mdata
        data[Constants.TasksFields.imageUrl] = imageUrl
        reference.setValue(data)
        return taskId
    }
    
    func updateTask(familyId: String, taskId: String, mdata: [String: String?]) {
        let taskUpdate = ["/tasks/\(familyId)/\(taskId)": mdata]
        ref.updateChildValues(taskUpdate)
    }
    
    func deleteTask(familyId: String, taskId: String, completion: @escaping ((Error?, DatabaseReference) -> Void)) {
        ref.child("tasks").child(familyId).child(taskId).removeValue(completionBlock: completion)
    }
    
}

