//
//  LoginViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 10/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit
//import Firebase
//import FirebaseAuthUI
//import FirebaseGoogleAuthUI

class LoginViewController: UIViewController {
    
    // MARK: IBAction
    
    @IBAction func showLoginView(_ sender: Any) {
        loginSession()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !appDelegate.authConfigured {
            configureAuth()
            appDelegate.authConfigured = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if login {
            self.performSegue(withIdentifier: "ShowNav", sender: nil)
        }
    }
    
    // MARK: Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let client = FirebaseClient.shared

    // log in status
    var login = false
    

    
    // MARK: Config
    
    func configureAuth() {
        client.configureAuth(success: {
            self.login = true
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowNav", sender: nil)
            }
        }) {
            self.login = false
            DispatchQueue.main.async {
                self.loginSession()
            }
        }
    }
    
    // Mark: Functions
    
    func loginSession() {
        let authViewController = client.signIn()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNav" {
            let taskTableViewController = (segue.destination as! UINavigationController).childViewControllers[0] as! TaskTableViewController
            taskTableViewController.email = client.user?.email
            if let user = UserDefaults.standard.string(forKey: "user") {
                appDelegate.user = user
            }
        }
    }
}
