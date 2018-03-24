//
//  ViewController.swift
//  CFood
//
//  Created by Mac Pro on 3/23/18.
//  Copyright © 2018 Mac Pro. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = "80d442de211aba25966f4dbe4175068522c3d852"
    let version = "2018-04-23"
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var results: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        shareButton.isHidden = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        navigationItem.title = "calculating..."
        SVProgressHUD.show()
        
        if let userImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = userImage
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visRec = VisualRecognition(apiKey: apiKey, version: version)
            
            let imageData = UIImageJPEGRepresentation(userImage, 0.05)
            
            let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = docURL.appendingPathComponent("tempImage.jpeg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visRec.classify(imagesFile: fileURL, success: { (ClassifiedImages) in
                let classes = ClassifiedImages.images.first!.classifiers.first!.classes
                self.results = []
                for index in 0..<classes.count {
                    self.results.append(classes[index].className)
                }
                SVProgressHUD.dismiss()
                print(self.results)
                DispatchQueue.main.async {

                    self.navigationItem.title = self.results.first!
                    self.cameraButton.isEnabled = true
                    self.shareButton.isHidden = false
                }
            })
            
        }else{
            print("ooops")
        }
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        navigationItem.title = ""
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func sharePressed(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("Isn't this cool?!?")
            vc?.add(imageView.image)
            present(vc!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Log in to Twitter"
        }
        
    }
    
}

