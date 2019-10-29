//
//  HCImagePicker.swift
//  iOSTemplate
//
//  Created by Hypercube 2 on 10/3/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit

public typealias CompletionHandler = (_ success:Bool, _ res:AnyObject?) -> Void

// NOTE: Add NSCameraUsageDescription to plist file

open class HCImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    public var imageSelectionInProgress = false
    public var imageSelectCompletitionHandler:CompletionHandler?
    
    public static let sharedManager: HCImagePicker =
        {
            let instance = HCImagePicker()
            return instance
    }()
    
    /// Open UIImagePickerController with Camera like source type with the possibility of setting Completition Handler Function.
    ///
    /// - Parameters:
    ///   - completitionHandler: Completion Handler Function. By default it is not set.
    public func takePictureFromCamera(allowEditing: Bool = true, completitionHandler:CompletionHandler? = nil)
    {
        self.imageSelectCompletitionHandler = completitionHandler
        self.openCamera(allowEditing: allowEditing)
    }
    
    /// Open UIImagePickerController with PhotosAlbum like source type with the possibility of setting Completition Handler Function.
    ///
    /// - Parameters:
    ///   - completitionHandler: Completion Handler Function. By default it is not set.
    public func getPictureFromGallery(allowEditing: Bool = true, completitionHandler:CompletionHandler? = nil)
    {
        self.imageSelectCompletitionHandler = completitionHandler
        self.openGallery(allowEditing: allowEditing)
    }
    
    /// Open dialog to choose the image source from where the image will be obtained.
    ///
    /// - Parameters:
    ///   - title: Dialog title. Default value is "Select picture".
    ///   - fromCameraButtonTitle: From camera button title. Default value is "From Camera".
    ///   - fromGalleryButtonTitle: From gallery button title. Default value is "From Gallery".
    ///   - cancelButtonTitle: Cancel button title. Default value is "Cancel".
    ///   - completitionHandler: Completion Handler Function. By default it is not set.
    public func selectPicture(title:String = "Select picture", fromCameraButtonTitle:String = "From Camera", fromGalleryButtonTitle:String = "From Gallery", cancelButtonTitle:String = "Cancel", allowEditing: Bool = true, completitionHandler:CompletionHandler? = nil)
    {
        self.imageSelectCompletitionHandler = completitionHandler
        HCDialog.showDialogWithMultipleActions(message: "", title: title, alertButtonTitles:
            [
                fromCameraButtonTitle,
                fromGalleryButtonTitle,
                cancelButtonTitle]
            , alertButtonActions:
            [
                { (alert) in
                    self.openCamera(allowEditing: allowEditing)
                },
                { (alert) in
                    self.openGallery(allowEditing: allowEditing)
                },
                nil
            ], alertButtonStyles:
            [
                .default,
                .default,
                .cancel
            ])
    }
    
    /// Open UIImagePickerController with Camera like source type
    private func openCamera(allowEditing: Bool)
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = allowEditing
            
            imageSelectionInProgress = true
            UIApplication.shared.keyWindow?.rootViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Open UIImagePickerController with PhotosAlbum like source type
    private func openGallery(allowEditing: Bool)
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = allowEditing
            
            imageSelectionInProgress = true
            UIApplication.shared.keyWindow?.rootViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Fix orientation for image. This is useful in some cases, for example, when image taken from camera has wrong orientation after upload to server.
    ///
    /// - Parameter img: Image for which we need to fix orientation
    /// - Returns: Image with valid orientation
    private func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if picker.allowsEditing
            {
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    if let completiton = self.imageSelectCompletitionHandler
                    {
                        completiton(true, self.fixOrientation(img: image))
                    }
                }
            } else {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    if let completiton = self.imageSelectCompletitionHandler
                    {
                        completiton(true, self.fixOrientation(img: image))
                    }
                }
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: {
            if let completiton = self.imageSelectCompletitionHandler
            {
                completiton(false, nil)
            }
        })
    }
}
