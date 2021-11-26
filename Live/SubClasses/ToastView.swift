//
//  ToastView.swift
//  Live
//
//  Created by ITPATH on 4/3/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol ToastDelegate {
   func buttonNextDismissSelector()
}
enum ToastType{
    case next
    case close
}
class ToastView: UIView {
 //182 207 83
    @IBOutlet var lblToastMsg:UILabel!
    @IBOutlet var btnTrueFalse:UIButton!
    @IBOutlet var btnNextButton:RoundButton!
    @IBOutlet var containerView:UIView!
    
    var toastType:ToastType = .close {
        didSet{
            if toastType == .close{
               self.btnTrueFalse.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysOriginal), for: .normal)
               self.backgroundColor = UIColor.red
               self.btnNextButton.isHidden = true
               self.lblToastMsg.textColor = UIColor.white
            }else if toastType == .next{
                self.btnTrueFalse.setImage(#imageLiteral(resourceName: "right").withRenderingMode(.alwaysOriginal), for: .normal)
               self.lblToastMsg.textColor = UIColor.black
               self.btnNextButton.isHidden = false
               self.backgroundColor = UIColor.init(red: 182.0/255.0, green: 207.0/255.0, blue: 83.0/255.0, alpha: 1.0)
            }
        }
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    static let shared:ToastView = {
        let myClassNib = UINib(nibName: "ToastView", bundle: nil)
        return myClassNib.instantiate(withOwner: nil, options: nil)[0] as! ToastView
    }()
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func show(toastMessage:String,type:ToastType){
        self.lblToastMsg.text = "\(toastMessage)"
        self.toastType = type
        self.addViewOnWindow()
    }
    func addViewOnWindow(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
            let heightOfToast:CGFloat = 120.0
            var yPosition = UIScreen.main.bounds.height - heightOfToast
            if IQKeyboardManager.shared.keyboardShowing{
                //yPosition = IQKeyboardManager.shared
            }
            self.frame = CGRect.init(x: 0, y: yPosition, width: UIScreen.main.bounds.width, height: 130)
            keyWindow.addSubview(self)
            
            self.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.transform = .identity
            }, completion:{ (_ ) in
                
            })
            if(self.toastType == .close){
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    self.removeFromSuperview()
                }
            }
        }
    }
    @IBAction func buttonNextSelector(sender:UIButton){
        
    }
    @IBAction func buttonCloseSelector(sender:UIButton){
        self.removeFromSuperview()
    }
}
