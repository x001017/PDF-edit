//
//  ViewController.swift
//  PDF Edit Viewer
//
//  Created by HisashiShindo on 2016/08/30.
//  Copyright © 2016年 HisashiShindo. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController {
    
    var _document: CGPDFDocumentRef?
    var _index: Int32?
    var _text: NSMutableString?
    var _stream: CGPDFContentStreamRef?
    var _encoding: String?
    var _pdfView0: PDFView?
    var _pdfView1: PDFView?
    var _pdfView2: PDFView?
    var _mainScrollView: UIScrollView?
    var _innerView: UIView?
    var _subScrollView: PDFScrollView?
    
    
    func frameToCenter() {
        // 現在のビューのサイズを取得
        var size: CGSize
        size = self.view.bounds.size
        
        // PDFビューのframeを取得
        var pdfFrame: CGRect
        pdfFrame = _pdfView1!.frame
        
        // 横方向の中央に移動
        if CGRectGetWidth(pdfFrame) < size.width {
            pdfFrame.origin.x = (size.width - CGRectGetWidth(pdfFrame)) * 0.5
        } else {
            pdfFrame.origin.x = 0
        }
        
        // 縦方向の中央に移動
        if CGRectGetHeight(pdfFrame) < size.height {
            pdfFrame.origin.y = (size.height - CGRectGetHeight(pdfFrame)) * 0.5
        } else {
            pdfFrame.origin.y = 0
        }
        
        // PDFビューのframeを設定
        _pdfView1?.frame = pdfFrame
    }
    
    //--------------------------------------------------------------//
    // #pragma mark -- Action --
    //--------------------------------------------------------------//

    @IBAction func textAction() {
        
        // PDFファイルのパスを取得
        var path: String
        path = NSBundle.mainBundle().pathForResource("sample", ofType: "pdf")!
        
        // PDFドキュメントを作成
        var document: CGPDFDocumentRef
        document = CGPDFDocumentCreateWithURL(NSURL.fileURLWithPath(path) as CFURLRef)!
        
        // PDFページを取得
        var page: CGPDFPageRef
        page = CGPDFDocumentGetPage(document, _index)
        
        // PDFコンテントストリームを取得
        _stream = CGPDFContentStreamCreateWithPage(page)
        
        // PDFオペレータテーブルを作成
        var table: CGPDFOperatorTableRef
        table = CGPDFOperatorTableCreate()
        CGPDFOperatorTableSetCallback(table, TJ, operator_Text)
        CGPDFOperatorTableSetCallback(table, Tj, operator_Text)
        CGPDFOperatorTableSetCallback(table, Tf, operator_Font)
        
        // PDFスキャナを作成
        var scanner: CGPDFScannerRef
        scanner = CGPDFScannerCreate(_stream!, table, self)
       
        // スキャンを開始
        _text, _text = nil
        _text = NSMutableString.string()
        CGPDFScannerScan(scanner)
        
        // オブジェクトの解放
        CGPDFScannerRelease(scanner), scanner = NULL
        CGPDFOperatorTableRelease(table), table = NULL
        CGPDFContentStreamRelease(_stream), _stream = NULL
        CGPDFDocumentRelease(document), document = NULL
        
        // コントローラの作成
        PDFTextViewController * controller
        controller = PDFTextViewController(nibName: "TextView", bundle: nil)
        controller.loadView()
        
        // テキストの設定
        controller.textView.text = _text
        
        // コントローラの表示
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation:UIStatusBarAnimationFade)
        self.presentModalViewController(controller, animated: true)
    }

    //--------------------------------------------------------------//
    // #pragma mark -- View --
    //--------------------------------------------------------------//

    
    override func viewDidLoad() {
        super.viewDidLoad()
        _subScrollView!.controller = self
        // Do any additional setup after loading the view, typically from a nib.
        
        // PDFドキュメントの作成
        
        // innerViewをメインスクロールビューに追加
        _mainScrollView!.addSubview(_innerView!)
        
        // メインスクロールビューのコンテントサイズを設定
        _mainScrollView!.contentSize = _innerView!.frame.size
        
        // インデックスの初期値として-1を設定
        _index = -1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // 親クラスの呼び出し
        super.viewWillAppear(animated)
        
        //ページの更新
        self._renewPages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------------------------------//
    //#pragma mark -- Image --
    //--------------------------------------------------------------//

    func _createdPdfViewWithIndex(index: Int32) -> PDFView {
        
        // PDF Viewを作成
        var pdfView: PDFView
        pdfView = PDFView(frame: CGRectZero)!
        
        // PDFページを取得
        var page = ??;if index > 0 || index <= CGPDFDocumentGetNumberOfPages(_document) { //NULL
            page = CGPDFDocumentGetPage(_document, index)
        }
        pdfView.page = page
        
        // PDFの大きさを取得
        var pageRect = CGRectZero
        var scale = 1.0
        if page {
            pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox)
        }
        
        if CGRectGetWidth(pageRect) > 0 {
            scale = CGRectGetWidth(self.view.frame) / CGRectGetWidth(pageRect)
        }
        
        // 初期のPDF表示の大きさおよびスケールを設定
        pageRect.size.width *= scale
        pageRect.size.height *= scale
        pdfView.frame = pageRect
        pdfView.scale = scale
        return pdfView
    }
    
    func _renewPages() {
        var rect: CGRect
        
        // 現在のインデックスを保存
        let oldIndex = _index
        
        // PDFのページ数を取得
        var pageNumber: Int32
        pageNumber = CGPDFDocumentGetNumberOfPages(_document)
        
        // コンテントオフセットを取得
        var offset: CGPoint
        offset = (_mainScrollView?.contentOffset)!
        if offset.x == 0 {
            // 前のページへ移動
            _index!-1
        }
        
        if offset.x >= (_mainScrollView?.contentSize.width)! - CGRectGetWidth((_mainScrollView?.frame)!) {
            // 次のページへ移動
            _index!+1
        }
        
        // インデックスの値をチェック
        if _index < 1 {
            _index = 1
        }
        
        if _index > pageNumber {
            _index = pageNumber
        }
        
        if _index == oldIndex {
            return
        }
        
//        
//        左側のPDF viewを更新
//        
        //古いPDF Viewを解放
        _pdfView0?.removeFromSuperview()
        
        // PDF Viewを作成
        _pdfView0 = self._createdPdfViewWithIndex(_index! - 1)
        
        // 表示位置の設定
        rect.size = (_pdfView0?.frame.size)!
        rect.origin = CGPointZero
        if !CGSizeEqualToSize((_pdfView0?.frame.size)!, CGSizeZero) {
            rect.origin.x += (CGRectGetWidth(self.view.frame) - CGRectGetWidth(rect)) * 0.5
            rect.origin.y += (CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect)) * 0.5
        }
        
        _pdfView0?.frame = rect
        _mainScrollView?.addSubview(_pdfView0!)
        
//        
//        中央のPDF View、サブスクロールビューを更新
//        
        
        // サブスクロールビューのframe
        rect.origin.x = CGRectGetMaxX(_pdfView0!.frame) > 0 ? CGRectGetMaxX((_pdfView0?.frame)!) + 20.0 : 0
        rect.origin.y = 0
        rect.size = self.view.frame.size
        
        // サブスクロールビューの設定
        _subScrollView?.frame = rect
        
        // 古いPDF Viewを解放
        _pdfView1?.removeFromSuperview()
        
        // PDF Viewを作成
        _pdfView1 = self._createdPdfViewWithIndex(_index!)
        
        // 表示位置の設定
        rect.size = (_pdfView1?.frame.size)!
        rect.origin = CGPointZero
        if !CGSizeEqualToSize((_pdfView1?.frame.size)!, CGSizeZero) {
            rect.origin.x += (CGRectGetWidth(self.view.frame) - CGRectGetWidth(rect)) * 0.5
            rect.origin.y += (CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect)) * 0.5
        }
        
        _pdfView1?.frame = rect
        _mainScrollView?.addSubview(_pdfView1!)
        
        // サブスクロールビューのコンテントサイズを設定
        _subScrollView?.contentSize = rect.size
        
//        
//        右側のPDF viewを更新
//        
        
        // 古いPDF Viewを解放
        _pdfView2?.removeFromSuperview()
        
        //PDF Viewを作成
        _pdfView2 = self._createdPdfViewWithIndex(_index! + 1)
        
        // 表示位置の設定
        rect.size = (_pdfView2?.frame.size)!
        rect.origin.x = CGRectGetMaxX(_subScrollView!.frame) + 20.0
        rect.origin.y = 0
        if !CGSizeEqualToSize((_pdfView2?.frame.size)!, CGSizeZero) {
            rect.origin.x += (CGRectGetWidth(self.view.frame) - CGRectGetWidth(rect)) * 0.5
            rect.origin.y += (CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect)) * 0.5
        }
        
        _pdfView2?.frame = rect
        _mainScrollView?.addSubview(_pdfView2!)
        
//        
//        メインスクロールビューの更新
//        
        
        // コンテントサイズとオフセットの設定
        var size: CGSize
        size.width = _index > 1 && _index < pageNumber ? (CGRectGetWidth(self.view.frame) + 20) * 3.0 : (CGRectGetWidth(self.view.frame) + 20.0) * 2.0
        size.height = 0
        _mainScrollView?.contentSize = size
        _mainScrollView?.contentOffset = (_subScrollView?.frame.origin)!
    }
    
    func stringInPDFObject(object: CGPDFObjectRef) -> String {
        
        var result = true
        
        // PDFオブジェクトタイプの取得
        var type: CGPDFObjectType
        type = CGPDFObjectGetType(object)
        
        // タイプ別による処理
        switch type {
        // PDF文字列の場合
        case kCGPDFObjectTypeString:
            // PDF文字列の取得
            var string: CGPDFStringRef
            result = CGPDFObjectGetValue(object, type, &String)
            if !result {
                return nil
            }
            
            // MacRomanEncodingの場合
            if _encoding.isEqualToString("MacRomanEncodig") {
                // CGPDFStringからNSStringへの変換
                var nsstring: String
                nsstring = CGPDFStringCopyTextString(string) as! String
                return nsstring
            }
            
            // Identity-Hの場合
            if _encoding.isEqualToString("Identity-H") {
                // バッファの作成
                var buffer: NSMutableString
                buffer = NSMutableString.string()
                
                // バイトのポインタを取得
                let tmp: UInt8
                tmp = CGPDFStringGetBytePtr(string)
                
                // NSStringへの変換
                var i: Int32
                for i = 0; i < CGPDFStringGetLength(string) / 2; i += 1 {
                    
                    // CIDを取得
                    var cid: UInt16
                    cid = *tmp++ << 8
                    cid |= *tmp++
                    
                    // CIDをunicharへ変換
                    var c: unichar
                    c = unicharWithGlyph(cid)
                    if c == 0 {
                        break
                    }
                    
                    // NSStringへ変換して追加
                    var nsstring: NSString
                    nsstring = NSString.stringWithCharacters(&c, length: 1)
                    if nsstring {
                        buffer.appendString(nsstring as String)
                    }
                }
                return buffer as String
            }
            
            
            // PDF配列の場合
            case kCGPDFObjectTypeArray:
                
                // PDF配列の取得
                var array: CGPDFArrayRef
                result = CGPDFObjectGetValue(object, type, &array)
                if !result {
                    return nil
                }
                
                // バッファの作成
                var buffer: NSMutableString
                buffer = NSMutableString.string()
                var count: size_t
                count = CGPDFArrayGetCount(array)
                
                // PDF配列の中身の取得
                var i: Int32
                for i = 0; i < count; i += 1 {
                    
                    // PDF配列からオブジェクトを取得
                    var child: CGPDFObjectRef
                    CGPDFArrayGetObject(array, i, &child)
                    
                    // テキストの抽出
                    var nsstring: NSString
                    nsstring = self.stringInPDFObject(child)
                    if nsstring {
                        buffer.appendString(nsstring as String)
                    }
                    
                }
                return buffer as String
            
        }
        return nil
        
     }
    
    func operatorTextScanned(scanner: CGPDFScannerRef) {
        
        // PDFオブジェクトの取得
        var object: CGPDFObjectRef
        CGPDFScannerPopObject(scanner, &object)
        
        // テキストの抽出
        var string: NSString
        string = self.stringInPDFObject(object)
        
        // テキストの追加
        if string {
            _text!.appendString(string as String)
        }
        
    }
    
    func operatorFontScanned(scanner: CGPDFScannerRef) {
        
        var result: bool
        
        // フォントサイズの取得
        var size: CGPDFInteger
        result = CGPDFScannerPopInteger(scanner, &size)
        if !result {
            return
        }
        
        // フォント名の取得
        let name: Int8
        result = CGPDFScannerPopName(scanner, &name)
        if !result {
            return
        }
        
        // フォントの取得
        var object: CGPDFObjectRef
        object = CGPDFContentStreamGetResource(_stream, Font, name)
        if !object {
            return
        }
        
        // PDF辞書の取得
        var dict: CGPDFDictionaryRef
        result = CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)
        if !result {
            return
        }
        
        // エンコーディングの設定
        _encoding = NSString.stringWithCString(encoding, encoding: NSASCIIStringEncoding)
        
    }
    
    //--------------------------------------------------------------//
    //#pragma mark -- UIScrollViewDelegate --
    //--------------------------------------------------------------//
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // メインスクロールビューの場合
        if scrollView == _mainScrollView {
            if !decelerate {
                
                // ページの更新
                self._renewPages()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // メインスクロールビューの場合
        if scrollView == _mainScrollView {
            // ページの更新
            self._renewPages()
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView {
        // サブスクロールビューの場合
        if scrollView == _subScrollView {
            
            // 中央のPDF viewを使う
            return _pdfView1!
        }
        return nil
    }
    
    extension PDFViewController {
        
        // 表示の更新
        func _renewPages() {
            
        }
        
        // オペレータコールバック
        func operatorTextScanned(scanner: CGPDFScannerRef) {
            
        }
        
        func operatorFontScanned(scanner: CGPDFScannerRef) {
            
        }
    }
    
    var operator_Textscanner: CGPDFScannerRef, _ info: Void: Void
    var operator_Fontscanner: CGPDFScannerRef, _ info: Void: Void
    func operator_Text(scanner: CGPDFScannerRef, _ info: Void) {
        info as! PDFViewController.operatorTextScanned(scanner)
    }
    
    func operator_Font(scanner: CGPDFScannerRef, _ info: Void) {
        info as! PDFViewController.operatorFontScanned(scanner)
    }
    
    func unicharWithGlyph(glyph: CGGlyph) -> unichar {
        var i: Int32
        var _glyphs65535: CGGlyph
        var _initialized = false
        
        if !_initialized {
            
            // Unicodeテーブルの初期化
            var unichars65535: UniChar
            for i = 0; i < 65535; i += 1 {
                unichars[i] = i
            }
            
            // CTFontの作成
            var ctFont: CTFontRef
            ctFont = CTFontCreateWithName("HiraKakuProN-W3" as CFStringRef, 10.0, NULL)
            
            // Unicodeからグリフの取得
            CTFontGetGlyphsForCharacters(ctFont, unichars, _glyphs, 65535)
            
            // 初期化済みフラグの設定
            _initialized = true
        }
        
        // マップの検索
        for i = 0; i < 65535; i += 1 {
            // 指定されたグリフが見つかった場合、そのインデクッスがunicodeとなっている
            if _glyphs[i] == glyph {
                return i
            }
        }
        return 0
    }

}

