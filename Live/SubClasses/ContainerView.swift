//
//  ContainerView.swift
//  Live
//
//  Created by ITPATH on 4/4/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class ContainerView: UIView {
    var containerTop:CGFloat{
        get{
            if(UIDevice.current.userInterfaceIdiom == .phone){
                if(UIScreen.main.nativeBounds.size.height == 2436.0){ //iPhoneX
                    return  44.0
                }
            }
            return 0.0
        }
    }
    var containerBottom:CGFloat{
        get{
            if(UIDevice.current.userInterfaceIdiom == .phone){
                if(UIScreen.main.nativeBounds.size.height == 2436.0){ //iPhoneX
                    return  34.0
                }
            }
            return 0.0
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(self.constraints.count)
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        print(self.constraints.count)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //Main thread when data available UI execution run on main thread
        self.layoutIfNeeded()
        DispatchQueue.main.async {
            
            print(self.constraints.count)
            for constraint in self.constraints{
                if let _ = constraint.identifier{
                    if(constraint.identifier! == "ContainerTop"){
                        constraint.constant = self.containerTop
                    }else if(constraint.identifier! == "ContainerBottom"){
                        constraint.constant = self.containerBottom
                    }
                }
            } 
        }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
    }

}
