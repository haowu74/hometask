//
//  LoginViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 10/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class LoginViewController: UIViewController {
    
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var user: User?
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var login = false
    
    override func viewDidLoad() {
        //super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureAuth()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if login {
            self.performSegue(withIdentifier: "ShowNav", sender: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func showLoginView(_ sender: Any) {
        loginSession()
    }
    
    // MARK: Config
    
    func configureAuth() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            //self.messages.removeAll(keepingCapacity: false)
            //self.messagesTable.reloadData()
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    self.signedInStatus(isSignedIn: true)
                    //let name = user!.email!.components(separatedBy: "@")[0]
                    //self.displayName = name
                    self.login = true
                    self.performSegue(withIdentifier: "ShowNav", sender: nil)
                }
            }
            else {
                self.login = false
                self.signedInStatus(isSignedIn: false)
                self.loginSession()
            }
        })
    }
    

    

    /*
    deinit {
        ref.child("messages").removeObserver(withHandle: _refHandle)
    }
    */
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func signedInStatus(isSignedIn: Bool) {

        
        if (isSignedIn) {
                

        }
    }
    
    func loginSession() {
        let authUI = FUIAuth.defaultAuthUI();

        let authViewController = authUI!.authViewController()
        
        self.present(authViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowNav" {
            //let photoAlbumViewController = segue.destination as! NavViewController
            let taskTableViewController = (segue.destination as! UINavigationController).childViewControllers[0] as! TaskTableViewController
            taskTableViewController.email = user?.email
            if let user = UserDefaults.standard.string(forKey: "user") {
                appDelegate.user = user
            }
        }
    }

}
