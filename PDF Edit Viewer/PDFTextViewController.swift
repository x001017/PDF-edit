//
//  PDFTextViewController.swift
//  PDF Edit Viewer
//
//  Created by HisashiShindo on 2016/08/30.
//  Copyright © 2016年 HisashiShindo. All rights reserved.
//

import UIKit
import Foundation

class PDFTextViewController : UIViewController {
    
    // Property
    private var _textView:IBOutlet UITextView!
    private var _textView:UITextView!
    var textView:UITextView! {
        get { return _textView }
    }
    
    //--------------------------------------------------------------//
    // MARK: -- Action --
    //--------------------------------------------------------------//
    
    @IBAction func doneAction() {
        // ビューを隠す
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation:UIStatusBarAnimationFade)
        self.dismissModalViewControllerAnimated(true)
    }
    
}
