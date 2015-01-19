//
//  ViewController.swift
//  health
//
//  Created by 松山 雄太 on 2015/01/01.
//  Copyright (c) 2015年 松山 雄太. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITextFieldDelegate  {
    
    var myHealthStore : HKHealthStore!
    var myReadHeartField: UITextField!
    var myWriteHeartField: UITextField!
    var myReadButton: UIButton!
    var myWriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // HealthStoreの生成
        myHealthStore = HKHealthStore()
        
        // Write用
        myWriteHeartField = UITextField(frame: CGRectMake(0,0,300,30))
        myWriteHeartField.text = "80"
        myWriteHeartField.delegate = self
        myWriteHeartField.borderStyle = UITextBorderStyle.RoundedRect
        myWriteHeartField.layer.position = CGPoint(x:self.view.bounds.width/2,y:50);
        self.view.addSubview(myWriteHeartField)
        
        // Read用
        myReadHeartField = UITextField(frame: CGRectMake(0,0,300,30))
        myReadHeartField.text = ""
        myReadHeartField.delegate = self
        myReadHeartField.borderStyle = UITextBorderStyle.RoundedRect
        myReadHeartField.layer.position = CGPoint(x:self.view.bounds.width/2,y:100);
        self.view.addSubview(myReadHeartField)
        
        // 読み込みボタン
        myReadButton = UIButton()
        myReadButton.frame = CGRectMake(0,0,200,40)
        myReadButton.backgroundColor = UIColor.redColor();
        myReadButton.layer.masksToBounds = true
        myReadButton.setTitle("脈拍データ読み込み", forState: UIControlState.Normal)
        myReadButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myReadButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myReadButton.layer.cornerRadius = 20.0
        myReadButton.layer.position = CGPoint(x: self.view.frame.width/2, y:200)
        myReadButton.tag = 1
        myReadButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myReadButton);
        
        // 書き込みボタン
        myWriteButton = UIButton()
        myWriteButton.frame = CGRectMake(0,0,200,40)
        myWriteButton.backgroundColor = UIColor.blueColor();
        myWriteButton.layer.masksToBounds = true
        myWriteButton.setTitle("脈拍データ書き込み", forState: UIControlState.Normal)
        myWriteButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myWriteButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        myWriteButton.layer.cornerRadius = 20.0
        myWriteButton.layer.position = CGPoint(x: self.view.frame.width/2, y:250)
        myWriteButton.tag = 2
        myWriteButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myWriteButton);
        
    }
    
    // ボタンイベント
    func onClickMyButton(sender: UIButton){
        if(sender.tag == 1){
            readData()
            
        }
        else if(sender.tag == 2){
            let myHeartStr: NSString = myWriteHeartField.text
            writeData(myHeartStr.doubleValue)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func requestAuthorization() {
        // 書き込みを許可する型.
        let typeOfWrite = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)]
        let typeOfWrites = NSSet(array: typeOfWrite)
        
        // 読み込みを許可する型.
        let typeOfRead = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)]
        let typeOfReads = NSSet(array: typeOfRead)
        
        //  HealthStoreへのアクセス承認をおこなう.
        self.myHealthStore.requestAuthorizationToShareTypes(typeOfWrites, readTypes: typeOfReads, completion: {
            (success: Bool, error: NSError!) in
            if success {
                println("Success!")
            } else {
                println("Error!")
            }
        })
    }
    
    // 心拍数を取得
    private func readData() {
        var error: NSError?
        
        let typeOfHeart = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        
        // 日付処理
        let calendar: NSCalendar! = NSCalendar.currentCalendar()
        let now: NSDate = NSDate()
        let startDate: NSDate = calendar.startOfDayForDate(now)
        let endDate: NSDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: startDate, options: nil)!
        let predicate: NSPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: HKQueryOptions.StrictStartDate)
        
        let statsOptions: HKStatisticsOptions = (HKStatisticsOptions.DiscreteMin | HKStatisticsOptions.DiscreteMax)
        
        let query: HKStatisticsQuery = HKStatisticsQuery(quantityType: typeOfHeart,
            quantitySamplePredicate: predicate, options: statsOptions, completionHandler: {
                (query: HKStatisticsQuery!, result: HKStatistics!, error: NSError!) in
                dispatch_async(dispatch_get_main_queue(),{
                    self.myReadHeartField.text = "最小:\(result.minimumQuantity()) 最大:\(result.maximumQuantity())"
                    
                    // 読み込み時にデータをuser defaultに保存
                    var myHeartStr = result.averageQuantity()
                    var def = NSUserDefaults(suiteName: "group.jp.techfund")
                    def?.setObject(myHeartStr, forKey: "heartRate")
                })
        })
        
        
        
        self.myHealthStore.executeQuery(query)
    }
    
    // 心拍数データを保存
    private func writeData(heart:Double){
        
        // Save the user's heart rate into HealthKit.
        let heartRateUnit: HKUnit = HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
        let heartRateQuantity: HKQuantity = HKQuantity(unit: heartRateUnit, doubleValue: heart)
        
        var heartRate : HKQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let nowDate: NSDate = NSDate()
        
        let heartRateSample: HKQuantitySample = HKQuantitySample(type: heartRate
            , quantity: heartRateQuantity, startDate: nowDate, endDate: nowDate)
        
        let completion: ((Bool, NSError!) -> Void) = {
            (success, error) -> Void in
            
            if !success {
                println("An error occured saving the Heart Rate \(heartRateSample). In your app, try to handle this gracefully. The error was: \(error).")
                abort()
            }
        }
        self.myHealthStore!.saveObject(heartRateSample, withCompletion: completion)
    }
}
