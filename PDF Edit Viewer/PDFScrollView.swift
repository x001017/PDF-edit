//
//  PDFScrollView.swift
//  PDF Edit Viewer
//
//  Created by HisashiShindo on 2016/08/30.
//  Copyright © 2016年 HisashiShindo. All rights reserved.
//

import UIKit
import Foundation

class PDFScrollView: UIScrollView {
    
    //プロパティ
    private var _controller: PDFViewController!
    
    var controller: PDFViewController! {
        get {
            return _controller
        }
        
        set {
            _controller = newValue
        }
    }
    
    override func layoutSubviews() {
        // 中央へ移動
        _controller.frameToCenter()
    }
    
}
