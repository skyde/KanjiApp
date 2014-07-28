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
        let inputRadius:CGFloat = 30
        
        let ciContext = CIContext(options: nil)
        var size = UIScreen.mainScreen().bounds.size
        
        UIGraphicsBeginImageContext(size)
        view.drawViewHierarchyInRect(Globals.screenRect, afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        var coreImage = CIImage(image: image)
        
        var imageExtent = coreImage.extent()
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        var clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter.setValue(coreImage, forKey: kCIInputImageKey)
        clampFilter.setValue(NSValue(CGAffineTransform: transform), forKey:"inputTransform")
        
        let gaussianFilter = CIFilter(name: "CIGaussianBlur")
        gaussianFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
        gaussianFilter.setValue(inputRadius, forKey: "inputRadius")
        
        let filteredImageData = gaussianFilter.valueForKey(kCIOutputImageKey) as CIImage
        
        let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: Globals.screenRect)
        let filteredImage = UIImage(CGImage: filteredImageRef)
        
        blurImage.image = filteredImage
        UIGraphicsEndImageContext()
    }
}