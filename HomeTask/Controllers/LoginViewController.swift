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
    
    // MARK: IBAction
    
    @IBAction func showLoginView(_ sender: Any) {
        loginSession()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if login {
            self.performSegue(withIdentifier: "ShowNav", sender: nil)
        }
    }
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var user: User?
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    // log in status
    var login = false
    

    
    // MARK: Config
    
    func configureAuth() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    self.login = true
                    self.performSegue(withIdentifier: "ShowNav", sender: nil)
                }
            }
            else {
                self.login = false
                self.loginSession()
            }
        })
    }
    
    // Mark: Functions
    
    func loginSession() {
        let authUI = FUIAuth.defaultAuthUI();
        let authViewController = authUI!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNav" {
            let taskTableViewController = (segue.destination as! UINavigationController).childViewControllers[0] as! TaskTableViewController
            taskTableViewController.email = user?.email
            if let user = UserDefaults.standard.string(forKey: "user") {
                appDelegate.user = user
            }
        }
    }
}
