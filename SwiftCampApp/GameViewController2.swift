//
//  GameViewController2.swift
//  SwiftCampApp
//
//  Created by 工藤 響 on 2018/11/10.
//  Copyright © 2018 工藤 響. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class GameViewController2: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var PlayerLabel: UILabel!
    @IBOutlet weak var Bar: UINavigationItem!
    @IBOutlet var nextPlayerButton: [UIButton]!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet var throwButton: [UIButton]!
    
    let userDefault = UserDefaults.standard
    var playerNum:Int = 0
    var nowPlayer:Int = 1
    // 加速度センサーを使うためのオブジェクトを格納します。
    let motionManager: CMMotionManager = CMMotionManager()
    // iPhoneを振った音を出すための再生オブジェクトを格納します。
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    // ボタンを押した時の音を出すための再生オブジェクトを格納します。
    var startAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    var startAccel: Bool = false
    var speed:Double = 0
//    var subAccel:Double = 0
    var synthetic:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barItem = UINavigationItem()
        barItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,  target: self, action: #selector(redoMessage))
        speed = 0
        if userDefault.object(forKey: "players2")  as? Int != nil{
            playerNum = userDefault.object(forKey: "players2") as! Int
        }else{
            playerNum = 1
        }
        Bar.rightBarButtonItems = barItem.rightBarButtonItems
        playerDicision()
    }
    
    func playerDicision(){
        if nowPlayer > playerNum && playerNum != 1{
            Victory()
            PlayerLabel.text = ""
            Alert(message: "プレイヤー\(self.nowPlayer)さんの勝利です", funcDici: 1)
            nowPlayer = 1
            userDefault.removeObject(forKey: "result2")
        }else if playerNum == 1{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
        }else{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
            nowPlayer += 1
        }
    }
    
    func Victory(){
        guard let victoryPlayer = userDefault.object(forKey: "result2") as? [Double] else{
            return
        }
        nowPlayer -= 1
        var counter = 0
        var maxSpeed:Double = 0
        for i in victoryPlayer{
            counter += 1
            if i > maxSpeed{
                self.nowPlayer = counter
                maxSpeed = i
            }
            print(nowPlayer)
        }
    }
    
    @objc func redoMessage(){
        Alert(message: "次の人に回しますか？",funcDici: 1)
        
        if var result = userDefault.object(forKey: "result2") as? [Double]{
            result.append(speed)
            userDefault.set(result,forKey:"result2")
        }else{
            userDefault.set([speed],forKey:"result2")
        }
        
    }
    
    @IBAction func ThrowFastBall(_ sender: Any) {
        //ボタンを1回押されたら実行、2回目は処理終了
        var checkBtn:Int?
        if checkBtn == nil || checkBtn == 0{
            startGetAccelerometer()
            checkBtn = 1
        }else{
            checkBtn = 0
            self.startAccel = false
        }
    }
    
    
    func startGetAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1/100
        motionManager.startAccelerometerUpdates(to: OperationQueue.main){(accelerometerData:CMAccelerometerData?,error: Error?) in
            
            if let acc = accelerometerData{
                let x = acc.acceleration.x
                let y = acc.acceleration.y
                let z = acc.acceleration.z
                //加速度が全方向で最低でも0.3以上計測すると実行
                if  abs(x) > 0.3 && abs(y) > 0.3 && abs(z) > 0.3 && self.startAccel == false{
                    self.startAccel = true
                    //現加速度を保存
                    self.synthetic = (abs(x) + abs(y) + abs(z))
                    //print(synthetic)
                    //self.subAccel = (abs(x) + abs(y) + abs(z))
                    print(self.synthetic)
                    if self.speed < self.synthetic{
                        self.speed = self.synthetic
                        print(self.synthetic)
                    }
                    //                    self.audioPlayer.currentTime = 0
                    //                    self.audioPlayer.play()
                    
                    self.speedLabel.text = String(format:"%.1fkm",self.speed*10)
                }
                
                if abs(x) < 0.3 && abs(y) < 0.3 && abs(z) < 0.3{
                    self.startAccel = false
                }
            }
        }
    }
    
    func Alert(message: String,funcDici: Int){
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
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
            loadView()
            viewDidLoad()
        }
    }
    
    func restart(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func PlayerApear(){
        UIView.animate(withDuration: 0.3, animations: {
            self.playerView.alpha = 0
        }, completion:  {
            (value: Bool) in
            self.playerView.isHidden = true
        })
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        userDefault.removeObject(forKey: "result2")
        userDefault.removeObject(forKey: "players2")
        Alert(message: "本当にやり直しますか？",funcDici: 2)
    }
    
    @IBAction func startButton(_ sender: Any) {
        PlayerApear()
    }
    
    @IBAction func NextPlay(_ sender: Any) {
        redoAction(redo: true)
    }
    
    
}
