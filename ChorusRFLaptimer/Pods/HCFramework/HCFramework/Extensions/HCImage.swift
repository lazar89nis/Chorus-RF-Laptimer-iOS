//
//  HCImage.swift
//
//  Created by Hypercube on 9/20/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit

// MARK: - UIImage extension
extension UIImage
{
    /// Constructor where a UIView instance is used as a parameter.
    ///
    /// - Parameter view: UIView which has to be rendered as UIImage
    convenience init(view: UIView)
    {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!) 
    }
    
    /// Resize UIImage object with specific percentage value and return this object.
    ///
    /// - Parameter percentage: CGFloat value for percentage used to rezize UIImage object
    /// - Returns: Resized UIImage object
    public func hcResized(withPercentage percentage: CGFloat) -> UIImage?
    {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Resize UIImage object to specific width and return this object
    ///
    /// - Parameter width: CGFloat value for width used to rezize UIImage object
    /// - Returns: Resized UIImage object
    public func hcResized(toWidth width: CGFloat) -> UIImage?
    {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Perform Blend overlay mode with specific color on image object and return it.
    ///
    /// - Parameter color: UIColor value to applied Blend Overlay mode on UIImage object.
    /// - Returns: UIImage object over which it is applied Blend Overlay mode
    public func hcOverlay(with color: UIColor) -> UIImage? {
        return self.hcPerformBlend(blendMode: .overlay, color: color)
    }
    
    /// Perform Blend softLight mode with specific color on image object and return it.
    ///
    /// - Parameter color: UIColor value to applied Blend SoftLight mode on UIImage object
    /// - Returns: UIImage object over which it is applied Blend SoftLight mode
    public func hcSoftLight(with color: UIColor) -> UIImage? {
        return self.hcPerformBlend(blendMode: .softLight, color: color)
    }
    
    /// Perform specific Blend mode with specific color on image object and return it.
    ///
    /// - Parameters:
    ///   - blendMode: CGBlendMode value to applied on UIImage object.
    ///   - color: UIColor value to applied blendMode on UIImage object.
    /// - Returns: UIImage object over which it is applied sprecific Blend mode with specific color.
    public func hcPerformBlend(blendMode:CGBlendMode, color:UIColor) -> UIImage?
    {
        UIGraphicsBeginImageContext(self.size)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        if (context != nil)
        {
            color.setFill()
            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.setBlendMode(blendMode)
            let rect = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(self.size.width), height: CGFloat(self.size.height))
            context?.draw(self.cgImage!, in: rect)
            context?.clip(to: rect, mask: self.cgImage!)
            context?.addRect(rect)
            context?.drawPath(using: .fillStroke)
            let coloredImg: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return coloredImg!
        }
        return nil
    }
    
    /// This function is used to crop UIImage object to specific rect and return this object.
    ///
    /// - Parameter rect: CGRect value for rect used to crop UIImage object
    /// - Returns: Croped UIImage object
    public func hcCropImage(toRect rect:CGRect) -> UIImage? {
        var rect = rect
        rect.origin.y = rect.origin.y * self.scale
        rect.origin.x = rect.origin.x * self.scale
        rect.size.width = rect.width * self.scale
        rect.size.height = rect.height * self.scale
        
        guard let imageRef = self.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage:imageRef)
        return croppedImage
    }
    
    /// Perform grayscale (CIPhotoEffectMono) filter on current image
    ///
    /// - Returns: Grayscale version of current image.
    public func hcConvertToGrayScale() -> UIImage {
        let filter: CIFilter = CIFilter(name: "CIPhotoEffectMono")!
        filter.setDefaults()
        filter.setValue(CoreImage.CIImage(image: self)!, forKey: kCIInputImageKey)
        
        return UIImage(cgImage: CIContext(options:nil).createCGImage(filter.outputImage!, from: filter.outputImage!.extent)!)
    }
    
    /// Perform several filters (CIAffineClamp and CIGaussianBlur) on current image to achieve blur effect
    ///
    /// - Parameter blurRadius: Radius for blurring image. Default value is 10.0.
    /// - Returns: Blurred image
    public func hcBlur(blurRadius:CGFloat = 10.0) -> UIImage {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: self)
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter?.setDefaults()
        clampFilter?.setValue(inputImage, forKey: kCIInputImageKey)
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(clampFilter?.outputImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(blurRadius, forKey: "inputRadius")
        let result = blurFilter?.value(forKey: kCIOutputImageKey) as? CIImage
        let cgImage = context.createCGImage(result!, from: CGRect(origin: .zero, size: self.size))
        return UIImage(cgImage: cgImage!, scale: self.scale, orientation: .up)
    }
    
    /// Return UIImage object from UIImageView.
    ///
    /// - Parameter imageView: UIImageView from which the function returns the UIImage object.
    /// - Returns: UIImage object from UIImageView.
    public static func hcVisibleImage(from imageView: UIImageView) -> UIImage {
        UIGraphicsBeginImageContext(imageView.frame.size)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        imageView.layer.render(in: context!)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
    /// Modify current image with given alpha parameter
    ///
    /// - Parameter value: Alpha parameter
    /// - Returns: Current image modifed by alpha parameter
    public func hcAlpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    /// Current image converted to black-white image
    public var bwImage: UIImage? {
        guard let cgImage = cgImage,
            let bwContext = bwContext else {
                return nil
        }
        
        let rect = CGRect(origin: .zero, size: size)
        bwContext.draw(cgImage, in: rect)
        let bwCgImage = bwContext.makeImage()
        
        return bwCgImage.flatMap { UIImage(cgImage: $0) }
    }
    
    /// Black-white context for current image
    private var bwContext: CGContext? {
        let bwContext = CGContext(data: nil,
                                  width: Int(size.width * scale),
                                  height: Int(size.height * scale),
                                  bitsPerComponent: 8,
                                  bytesPerRow: Int(size.width * scale),
                                  space: CGColorSpaceCreateDeviceGray(),
                                  bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        bwContext?.interpolationQuality = .high
        bwContext?.setShouldAntialias(false)
        
        return bwContext
    }
}
