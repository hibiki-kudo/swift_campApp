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
    let userDefault = UserDefaults.standard
    var pleyerNum:Int = 0
    var nowPlayer:Int = 1
    var point:Double = 0
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
        //登録
        playerDicision()
        
    }
    
    func playerDicision(){
        if nowPlayer > pleyerNum && pleyerNum != 1{
            Victory()
            PlayerLabel.text = "プレイヤー\(self.nowPlayer)さんの勝利です"
            nowPlayer = 1
            userDefault.removeObject(forKey: "result1")
        }else if pleyerNum == 1{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
        }else{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
            nowPlayer += 1
        }
    }
    
    func Victory(){
        guard let victoryPlayer = userDefault.object(forKey: "result1") as? [Double] else{
            return
        }
        var counter = 0
        var maxPoint:Double = 0
        for i in victoryPlayer{
            counter += 1
            if i > maxPoint{
                self.nowPlayer = counter
                maxPoint = i
            }
            print(nowPlayer)
        }
    }
    
    @objc func redoMessage(){
        Alert(message: "パスしますか？",funcDici: 1)
        
    }
    
    func startGetAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1/100
        motionManager.startAccelerometerUpdates(to: OperationQueue.main){(accelerometerData:CMAccelerometerData?,error: Error?) in
            
            if let acc = accelerometerData{
                let x = acc.acceleration.x
                let y = acc.acceleration.y
                let z = acc.acceleration.z
                let synthetic = abs(x) + abs(y) +  abs(z)
                
                if synthetic <= 4{
                    self.startAccel = true
                    
                //    self.audioPlayer.currentTime = 0
                //    self.audioPlayer.play()
                    self.point += synthetic
                }
                self.pointLabel.text = String(format:"%.0",self.point)
                if self.startAccel == true && synthetic > 4{
                    self.startAccel = false
                    self.Alert(message: "終了です", funcDici: 1)
                    
                }
            }
        }
    }
    
    func Alert(message: String,funcDici: Int){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction) -> Void in
            if funcDici == 1{
                self.redoAction(redo: true)
            }else if funcDici == 2{
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
            loadView()
            viewDidLoad()
        }
    }
    
    func restart(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OptionButton(_ sender: Any) {
        userDefault.removeObject(forKey: "result1")
        userDefault.removeObject(forKey: "players1")
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
        TimerStart()
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
