//
//  GameViewController.swift
//  SwiftCampApp
//
//  Created by 工藤 響 on 2018/11/09.
//  Copyright © 2018 工藤 響. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class GameViewController: UIViewController {
    
    @IBOutlet weak var Bar: UINavigationItem!
    @IBOutlet weak var PlayerLabel: UILabel!
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var gameStartButton: UIButton!
    let userDefault = UserDefaults.standard
    var pleyerNum:Int = 1
    var nowPlayer:Int = 1
    var point:Double = 0
    var startY = 0
    var syntheticAccels:Double = 0
    var timer:Timer!
    
    // 加速度センサーを使うためのオブジェクトを格納します。
    let motionManager: CMMotionManager = CMMotionManager()
    // iPhoneを振った音を出すための再生オブジェクトを格納します。
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    // ボタンを押した時の音を出すための再生オブジェクトを格納します。
    var startAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    var startAccel: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barItem = UINavigationItem()
        barItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,  target: self, action: #selector(redoMessage))
        
        pleyerNum = userDefault.object(forKey: "players1") as! Int
        Bar.rightBarButtonItems = barItem.rightBarButtonItems
        timerLabel.text = "10"
        pointLabel.text = "0"
        point = 0
        //登録
        playerDicision()
        
    }
    
    func playerDicision(){
        if nowPlayer > pleyerNum && pleyerNum != 1{
            Victory()
            PlayerLabel.text = ""
            userDefault.removeObject(forKey: "result1")
            Alert(message: "プレイヤー\(self.nowPlayer)さんの勝利です", funcDici: 2)
            nowPlayer = 1
        }else if pleyerNum == 1{
            nowPlayer = 1
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
        }else{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
            self.nowPlayer += 1
        }
    }
    
    func Victory(){
        guard let victoryPlayer = userDefault.object(forKey: "result1") as? [Double] else{
            return
        }
        print(victoryPlayer)
        print(nowPlayer)
        nowPlayer = 1
        var counter = 1
        var maxPoint:Double = 0
        for i in victoryPlayer{
            print(i)
            if i > maxPoint{
                self.nowPlayer = counter
                maxPoint = i
                print("if通りましたよ")
            }
            counter += 1
            print(nowPlayer)
        }
    }
    
    @objc func redoMessage(){
        Alert(message: "パスしますか？",funcDici: 1)
        
    }
    
    func startGyros() {
        if motionManager.isGyroAvailable {
            self.motionManager.gyroUpdateInterval = 1.0 / 100
            self.motionManager.startGyroUpdates(to: OperationQueue.main){(GyroData:CMGyroData?,error: Error?) in
                
                //            // Configure a timer to fetch the accelerometer data.
                //            self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                //                               repeats: true, block: { (timer) in
                //                                // Get the gyro data.
                if let data = self.motionManager.gyroData {
                    let x = data.rotationRate.x
                    let y = data.rotationRate.y
                    let z = data.rotationRate.z
                    let synthetic = abs(x) + abs(z)
                    self.startY = abs(Int(y))
                    print(self.startY)
                    print(synthetic)
                    if (self.startAccel){
                        if synthetic <= 1 && synthetic > 0.5{
                            self.startAccel = true
                            
                            //    self.audioPlayer.currentTime = 0
                            //    self.audioPlayer.play()
                            
                            self.point += synthetic * 10
                            
                            
                        }
                        
                        self.pointLabel.text = String(format:"%.1f",self.point)
                        
                        if synthetic > 1.5{
                            self.startAccel = false
                            self.Alert(message: "終了です", funcDici: 1)
                            self.timer.invalidate()
                            if (self.motionManager.isGyroActive) {
                                self.motionManager.stopGyroUpdates()
                                self.motionManager.stopAccelerometerUpdates()
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func startGetAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1/100
        motionManager.startAccelerometerUpdates(to: OperationQueue.main){(accelerometerData:CMAccelerometerData?,error: Error?) in
            
            if let acc = accelerometerData{
                
                let z = acc.acceleration.z
                if abs(z) > 0.5{
                    self.syntheticAccels += abs(z)
                }
                if self.syntheticAccels > 15{
                    self.startAccel = true
                    self.syntheticAccels = 0
                    //    self.audioPlayer.currentTime = 0
                    //    self.audioPlayer.play()
                    
                    print(self.syntheticAccels)
                }
            }
        }
    }
    
    
    func Alert(message: String,funcDici: Int){
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction) -> Void in
            if funcDici == 1{
                if (self.motionManager.isGyroActive) {
                    self.motionManager.stopGyroUpdates()
                    self.motionManager.stopAccelerometerUpdates()
                }
                self.redoAction(redo: true)
                
            }else if funcDici == 2{
                if (self.motionManager.isGyroActive) {
                    self.motionManager.stopGyroUpdates()
                    self.motionManager.stopAccelerometerUpdates()
                }
                self.restart()
            }
        }))
        let close = UIAlertAction(title: "閉じる", style: .cancel, handler:  {(action: UIAlertAction) -> Void in
        })
        alert.addAction(close)
        present(alert, animated: true, completion: nil)
    }
    
    
    func redoAction(redo: Bool){
        if redo{
            if var result = userDefault.object(forKey: "result1") as? [Double]{
                result.append(point)
                userDefault.set(result,forKey:"result1")
            }else{
                userDefault.set([point],forKey:"result1")
            }
            if gameStartButton.isEnabled == false{
                self.timer.invalidate()
            }
            
            loadView()
            viewDidLoad()
        }
    }
    
    func restart(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OptionButton(_ sender: Any) {
        userDefault.removeObject(forKey: "result1")
        userDefault.removeObject(forKey: "players¥1")
        Alert(message: "本当にやり直しますか？",funcDici: 2)
    }
    
    func PlayerApear(){
        UIView.animate(withDuration: 0.3, animations: {
            self.PlayerView.alpha = 0
        }, completion:  {
            (value: Bool) in
            self.PlayerView.isHidden = true
        })
        
    }
    
    @IBAction func PlayerStartButton(_ sender: Any) {
        PlayerApear()
    }
    
    @IBAction func gameStartButton(_ sender: Any) {
        gameStartButton.isEnabled = false
        TimerStart()
        startGetAccelerometer()
        startGyros()
    }
    
    func TimerStart(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.timerUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func timerUpdate(){
        if Int(timerLabel.text!)! > 0{
            timerLabel.text = String(Int(timerLabel.text!)!  - 1)
        }else{
            Alert(message: "タイムアップです", funcDici: 1)
            self.timer!.invalidate()
        }
    }
    
}
