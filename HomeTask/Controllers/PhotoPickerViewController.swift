//
//  PhotoPickerViewController.swift
//  HomeTask
//
//  Created by Hao Wu on 29/9/18.
//  Copyright © 2018 S&J. All rights reserved.
//

import UIKit

class PhotoPickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Mark: IBOutlet
    
    @IBOutlet weak var photo: UIImageView!
    
    // Mark: IBAction
    
    @IBAction func cameraSelected(_ sender: Any) {
        chooseSourceType(.camera)
    }
    
    @IBAction func albumSelected(_ sender: Any) {
        chooseSourceType(.photoLibrary)
    }
    
    // Mark: Properties
    var image: UIImage?
    
    // Mark: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        if let image = self.image {
            photo.image = image
        }
    }
    
    // Mark: Callbacks
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindFromPhotoPickerViewController", sender: self)
    }
    
    // Mark: Functions
    
    private func chooseSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        self.present(pickerController, animated: true, completion: nil)
    }
    
    // Mark: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            photo.image = image
        }
        dismiss(animated: true, completion: nil)
    }

}
