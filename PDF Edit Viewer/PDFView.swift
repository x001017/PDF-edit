//
//  PDFView.swift
//  PDF Edit Viewer
//
//  Created by HisashiShindo on 2016/08/30.
//  Copyright © 2016年 HisashiShindo. All rights reserved.
//

import UIKit
import Foundation

class PDFView: UIView {
    
    // プロパティ
    private var _page: CGPDFPageRef?
    private var _scale: Float = 0.0
    
    var page: CGPDFPageRef? {
        get {
            return _page
        }
        set(page) {
            // ページの設定
            _page = page
            
            // 画面の更新
            self.setNeedsDisplay()
        }
        
        private var _scale:Float
        var scale:Float {
        get { return _scale }
        set { _scale = newValue }
        }
    }
    
    //--------------------------------------------------------------//
    // MARK: -- Initialize --
    //--------------------------------------------------------------//

    func layerClass() -> AnyClass {
        return CATiledLayer.self
    }
    
    func _init() {
        // インスタンス変数の初期化
        _scale = 1.0
        self.contentScaleFactor = 1.0
        
        // レイヤーの設定
        var layer:CATiledLayer!
        layer = (self.layer as! CATiledLayer)
        layer.levelsOfDetail = 4
        layer.levelsOfDetailBias = 4
        layer.tileSize = CGSizeMake(512.0, 512.0)
    }
    
    override init?(frame:CGRect) {
        self = super.init(frame:frame)
        if (self == nil) {
            return nil
        }
        
        // 共通の初期化処理
        self._init()
        return self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------------------------------//
    // MARK: -- Property --
    //--------------------------------------------------------------//
    // `setPage:` has moved as a setter.
    
    //--------------------------------------------------------------//
    // MARK: -- Drawing --
    //--------------------------------------------------------------//
    
    override func drawLayer(layer:CALayer, inContext context:CGContextRef){
        
        // 背景を白で塗りつぶす
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, self.bounds)
        
        // グラフィックコンテキストの保存
        CGContextSaveGState(context)
        
        // 垂直方向に反転するアフィン変換の設定
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.bounds))
        
        // スケールの設定
        CGContextScaleCTM(context, _scale, _scale)
        
        // ページの描画
        CGContextDrawPDFPage(context, _page)
        
        // グラフィックコンテキストの復元
        CGContextRestoreGState(context)
    }
    
}