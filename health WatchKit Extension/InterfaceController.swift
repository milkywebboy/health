//
//  InterfaceController.swift
//  health WatchKit Extension
//
//  Created by Yuta on 2015/01/17.
//  Copyright (c) 2015年 松山 雄太. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label1: WKInterfaceLabel!
    @IBOutlet weak var label2: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
    }

    override func willActivate() {
        super.willActivate()
        
        // heartRateの値を取得
        var def = NSUserDefaults(suiteName: "group.jp.techfund")
        let heartRate = def?.objectForKey("heartRate") as String
        var heartRateInt :Int! = heartRate.toInt()
        
        switch heartRateInt {
        case 1...59:
            label1.setText("💙")    // 少ない
        case 60...90:
            label1.setText("❤️")    // 正常
        default:
            label1.setText("💛")    // 多い
        }
        
        label2.setText(heartRate)
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
