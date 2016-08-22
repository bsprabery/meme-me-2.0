//
//  ViewController.swift
//  MemeMe v 1.0
//
//  Created by Brittany Sprabery on 7/13/16.
//  Copyright © 2016 Brittany Sprabery. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
   
    @IBOutlet weak var subview: UIView!
    
    var topConstraint : NSLayoutConstraint!
    var bottomConstraint : NSLayoutConstraint!
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        self.view.sendSubviewToBack(imagePickerView)
        
        let centeringText = NSMutableParagraphStyle()
        centeringText.alignment = .Center
        
        let memeTextAttributes: [String: AnyObject] = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
            NSStrokeWidthAttributeName: -5.0,
            NSParagraphStyleAttributeName: centeringText
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.attributedPlaceholder = NSAttributedString(string: "TOP",attributes: memeTextAttributes)
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: memeTextAttributes)
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
        
        print("View Did Load")
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.subscribeToKeyboardNotifications()
        self.subscribeToKeyboardHideNotification()
        
        navigationController?.navigationBarHidden = true
        
        
        if (imagePickerView.image == nil) {
            shareButton.enabled = false
            cancelButton.enabled = false
        } else {
            shareButton.enabled = true
            cancelButton.enabled = true
        }
        
        if (imagePickerView.image != nil) {
            layoutTextFields()
            }
    }
    
   
    @IBAction func shareMeme(sender: AnyObject) {
        let image = generatedMemedImage(imagePickerView.image!.size)
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)
        controller.popoverPresentationController?.barButtonItem = shareButton
        
        controller.completionWithItemsHandler = { activity, completed, items, error -> Void in if completed {
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
            }
        }

    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        // Implement code to create segue back to table/collection view controller instead of using the following:
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        shareButton.enabled = false
        cancelButton.enabled = false
        navigationController?.navigationBarHidden = false
    }


    @IBAction func pickAnImage(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)

        
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //GitHub - https://gist.github.com/tomasbasham/10533743
    
    func generatedMemedImage(size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth = size.width / imagePickerView.image!.size.width
        let aspectHeight = size.height / imagePickerView.image!.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = imagePickerView.image!.size.width * aspectRatio
        scaledImageRect.size.height = imagePickerView.image!.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        imagePickerView.frame = scaledImageRect
        //subview.frame = scaledImageRect
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        subview.drawViewHierarchyInRect(imagePickerView.frame, afterScreenUpdates: true)
        //imagePickerView.drawViewHierarchyInRect(imagePickerView.frame, afterScreenUpdates: true)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
        
    }
    
    func save() {
        let meme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imagePickerView.image!, memedImage: generatedMemedImage(imagePickerView.image!.size))
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)

    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
        navigationController?.navigationBarHidden = false
    }
    
    
    //Text Fields

    func textFieldDidBeginEditing() {
        topTextField.text = ""
        bottomTextField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        return true
    }
    
    
    //I adapted this from Stack Overflow: http://stackoverflow.com/questions/32479499/updating-auto-layout-constraints-to-reposition-text-field
    
    func layoutTextFields() {
        if topConstraint != nil {
            view.removeConstraint(topConstraint)
        }
        
        if bottomConstraint != nil {
            view.removeConstraint(bottomConstraint)
        }
        
        let size = imagePickerView.image != nil ? imagePickerView.image!.size : imagePickerView.frame.size
        let frame = AVMakeRectWithAspectRatioInsideRect(size, imagePickerView.bounds)
        
        let margin = frame.origin.y + frame.size.height * 0.10
        
        topConstraint = NSLayoutConstraint(
            item: topTextField,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: imagePickerView,
            attribute: .Top,
            multiplier: 1.0,
            constant: margin)
        view.addConstraint(topConstraint)
        
        bottomConstraint = NSLayoutConstraint(
            item: bottomTextField,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: imagePickerView,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: -margin)
        view.addConstraint(bottomConstraint)
    }
    
    
    //Keyboard Notifications
    
   func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardHideNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:  UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object:  nil)
    }
    
    //Shift View's Frame Up When Keyboard is Displayed
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() == true {
            view.frame.origin.y -= getKeyboardHeight(notification)
        } 
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() == true {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    

}

