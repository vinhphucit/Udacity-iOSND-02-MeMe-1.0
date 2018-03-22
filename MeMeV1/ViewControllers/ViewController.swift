//
//  ViewController.swift
//  MeMeV1
//
//  Created by Phuc Tran on 3/22/18.
//  Copyright © 2018 Phuc Tran. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    @IBOutlet weak var btnPhoto: UIBarButtonItem!
    @IBOutlet weak var tfTop: UITextField!
    @IBOutlet weak var tfBottom: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField(tf: tfTop, text: "TOP")
        setupTextField(tf: tfBottom, text: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        btnCamera.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupTextField(tf: UITextField, text: String) {
        tf.defaultTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
            NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
            NSAttributedStringKey.font.rawValue : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: 6.0,
        ]
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.text = text
        tf.delegate = self
    }
    
    @IBAction func onClickCameraButton(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    @IBAction func onClickPhotoButton(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    @IBAction func onClickShareButton(_ sender: Any) {
        if ivPhoto.image == nil {
            showAlertError()
            return
        }
        
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { activity, success, items, error in
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    
    @IBAction func onClickCancelButton(_ sender: Any) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        tfTop.text = "TOP"
        tfBottom.text = "BOTTOM"
        ivPhoto.image = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        ivPhoto.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if tfBottom.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        if tfBottom.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
    
        // TODO: Hide toolbar and navbar
        navigationBar.isHidden = true
        toolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        

        return memedImage
    }
    
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: tfTop.text!, bottomText: tfBottom.text!, originalImage: ivPhoto.image!, memedImage: memedImage)
        
        //Show Toolbar and Navigation Bar
        navigationBar.isHidden = false
        toolbar.isHidden = false
        
    }
    
    func showAlertError(){
        let alertController = UIAlertController(title: "Error", message: "Please Choose An Image", preferredStyle: .alert)
        
        //then we create a default action for the alert...
        //It is actually a button and we have given the button text style and handler
        //currently handler is nil as we are not specifying any handler
        let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
        
        //now we are adding the default action to our alertcontroller
        alertController.addAction(defaultAction)
        
        //and finally presenting our alert using this method
        present(alertController, animated: true, completion: nil)
    }

}

