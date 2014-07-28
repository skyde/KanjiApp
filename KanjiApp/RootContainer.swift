//
//  RootContainer.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-22.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class RootContainer: CustomUIViewController {
    
    @IBOutlet weak var sidebarButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var definitionOverlay: UIView!
    @IBOutlet weak var blurImage: UIImageView!
    
    var sidebarButtonBaseFrame: CGRect!
    var statusBarHidden = false
    let popoverAnimationSpeed = 0.4
    let sidebarEasing = UIViewAnimationOptions.CurveEaseIn
    let blurEasing = UIViewAnimationOptions.CurveEaseIn
    
    override func isGameView() -> Bool {
        return false
    }
    
    @IBAction func sidebarButtonTouch(sender: AnyObject) {
        
        animateSelf(mainView.frame.origin.x == 0)
    }
    
    private func animateSelf(open: Bool) {
        
        let xMove: CGFloat = 272
        
        if open {
            sidebar.hidden = false
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
                self.mainView.frame = CGRectMake(xMove, self.mainView.frame.origin.y, self.mainView.frame.width, self.mainView.frame.height);
            }
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
                self.sidebarButton.frame = CGRectMake(
                    self.sidebarButtonBaseFrame.origin.x + xMove,
                    self.sidebarButtonBaseFrame.origin.y,
                    self.sidebarButton.frame.width,
                    self.sidebarButton.frame.height);
            }
        }
        else
        {
            UIView.animateWithDuration(popoverAnimationSpeed,
            delay: NSTimeInterval(),
            options: sidebarEasing,
            animations: {
                self.mainView.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height) },
                completion: { (_) -> Void in if self.mainView.layer.presentationLayer().frame.origin.x == 0 { self.sidebar.hidden = true } })
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
                self.sidebarButton.frame = self.sidebarButtonBaseFrame;
            }
        }
    }

    init(coder aDecoder: NSCoder!) {
        
        super.init(coder: aDecoder)
    }

    override func onTransitionToView() {
        super.onTransitionToView()
        
        animateSelf(false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
//    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        definitionOverlay.hidden = true
        sidebar.hidden = true
        blurImage.hidden = true
        blurImage.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.view.sendSubviewToBack(mainView)
        self.view.sendSubviewToBack(sidebar)
        
        sidebarButtonBaseFrame = sidebarButton.frame
    }
    
    func onNotificationShowDefinition() {
        
        var animationSpeed = 0.4
        
        if Globals.currentDefinition == "" {
            UIView.animateWithDuration(popoverAnimationSpeed,
                delay: NSTimeInterval(),
                options: sidebarEasing,
                animations: {
                    self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height);
                    self.blurImage.alpha = 0
                },
                completion: {
                    (_) -> Void in if self.definitionOverlay.layer.presentationLayer().frame.origin.x == self.mainView.frame.width {
                        self.definitionOverlay.hidden = true;
                        self.blurImage.hidden = true;
                    }
                })
        } else {
            caculateBlur()
            definitionOverlay.hidden = false
            blurImage.hidden = false
            
            self.definitionOverlay.frame = CGRectMake(self.mainView.frame.width, 0, self.mainView.frame.width, self.mainView.frame.height)
            
            UIView.animateWithDuration(popoverAnimationSpeed) {
                self.definitionOverlay.frame = CGRectMake(0, 0, self.mainView.frame.width, self.mainView.frame.height);
                self.blurImage.alpha = 1
            }
        }
    }
    
    override func addNotifications() {
        super.addNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotificationShowDefinition", name: Globals.notificationShowDefinition, object: nil)
    }
    
    func caculateBlur() {
        var size = UIScreen.mainScreen().bounds.size
        
        UIGraphicsBeginImageContext(size)
        view.drawViewHierarchyInRect(Globals.screenRect, afterScreenUpdates: false)
        
        //            view.drawViewHierarchyInRect(Globals.screenRect, afterScreenUpdates: false)
        
        
        
        
        let baseImage = UIGraphicsGetImageFromCurrentImageContext()
        
        let outset: CGFloat = 50
        var expanded = CGSize(width: baseImage.size.width + outset * 2, height: baseImage.size.height + outset * 2)
        var insetRect = CGRectMake(outset, outset, baseImage.size.width, baseImage.size.height)
        
        UIGraphicsEndImageContext()
        UIGraphicsBeginImageContextWithOptions(expanded, true, 0)
//        let col = UIColor(red: 253.0 / 255, green: 250.0 / 255, blue: 248.0 / 255, alpha: 1.0)
//        col.set()
        //        UIRectFill(CGRectMake(0, 0, baseImage.size.width + outset * 2, baseImage.size.height + outset * 2))
        baseImage.drawInRect(CGRectMake(0, 0, baseImage.size.width + outset * 2, baseImage.size.height + outset * 2))
        
        baseImage.drawInRect(CGRectMake(0, outset, baseImage.size.width + outset * 2, baseImage.size.height))
        
        baseImage.drawInRect(insetRect)
        
        
        
        
//        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext();
//        return newImage;
        
        
        var coreImage = CIImage(image: image)
        
        
        let filter = CIFilter(name: "CIGaussianBlur")
        let ciContext = CIContext(options: nil)
//        
//        var transform: CGAffineTransform = CGAffineTransformIdentity
//        var clampFilter = CIFilter(name:"CIAffineClamp")
//        clampFilter.setValue(image, forKey:"inputImage")
//        clampFilter.setValue(NSValue(nonretainedObject: transform), "inputTransform")
//        [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
//        var affineClampFilter = CIFilter(name: "CIAffineClamp")
//        
//        var xform = CGAffineTransformMakeScale(1.0, 1.0)
////        var aofb = [UInt8](count:data.length, repeatedValue:0)
////        data.getBytes(&aofb, length:data.length)
////        var v1 = [UInt8](xform)
////        var v2 = [UInt8](CGAffineTransform)
////        var value = NSValue(bytes:v1, objCType:v2)
//        affineClampFilter.setValue(xform as AnyObject, forKey:"inputTransform")
        
        //[clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
//        objCType:@encode(CGAffineTransform)]
        //        forKey:@];
        let inputRadius:CGFloat = 30
        
//        coreImage = ciContext.createCGImage(<#im: CIImage?#>, fromRect: <#CGRect#>)(coreImage, fromRect: CGRectMake(
//            -outset, -outset, image.size.width + outset * 2, image.size.height + outset * 2))
        
        filter.setValue(inputRadius, forKey: "inputRadius")
        
        filter.setValue(coreImage, forKey: kCIInputImageKey)
//        filter.setValue(affineClampFilter, forKey: "inputTransform")
        if var filter: AnyObject = filter.valueForKey(kCIOutputImageKey) {
            
            let filteredImageData = filter as CIImage
            
            let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: filteredImageData.extent())
            let filteredImage = UIImage(CGImage: filteredImageRef);
            
            blurImage.image = filteredImage
            
            var screen = UIScreen.mainScreen().bounds.size
            println(filteredImage.size)
            println(image.size)
//            println(-(filteredImage.size.height - image.size.height * 2) / 2)
            blurImage.frame = CGRectMake(
                -outset - inputRadius,
                -outset - inputRadius,
                screen.width + outset * 2 + inputRadius * 2,
                screen.height + outset * 2 + inputRadius * 2)
            println(blurImage.frame)
//            = Globals.screenRect
        }
        UIGraphicsEndImageContext()
    }
    
//    func removeFromNotifications() {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
}