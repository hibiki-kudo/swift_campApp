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
        synthetic = 0
        playerNum = userDefault.object(forKey: "players2") as! Int
        
        Bar.rightBarButtonItems = barItem.rightBarButtonItems
        playerDicision()
    }
    
    func playerDicision(){
        if nowPlayer > playerNum && playerNum != 1{
            Victory()
            PlayerLabel.text = ""
            userDefault.removeObject(forKey: "result2")
            Alert(message: "プレイヤー\(self.nowPlayer)さんの勝利です", funcDici: 2)
            nowPlayer = 1
        }else if playerNum == 1{
            nowPlayer = 1
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
        }else{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
            self.nowPlayer += 1
        }
    }
    
    func Victory(){
        guard let victoryPlayer = userDefault.object(forKey: "result2") as? [Double] else{
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
        Alert(message: "次の人に回しますか？",funcDici: 1)
        
    }
    
    @IBAction func ThrowFastBall(_ sender: Any) {

            startGetAccelerometer()

    }
    
    
    func startGetAccelerometer(){
        motionManager.accelerometerUpdateInterval = 1/100
        motionManager.startAccelerometerUpdates(to: OperationQueue.main){(accelerometerData:CMAccelerometerData?,error: Error?) in
            
            if let acc = accelerometerData{
                let x = acc.acceleration.x
                let y = acc.acceleration.y
                let z = acc.acceleration.z
                //加速度が全方向で最低でも0.3以上計測すると実行
                if  (abs(x) + abs(y) + abs(z)) > 3 && self.startAccel == false{
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
                print(self.synthetic)
                
                if abs(x) < 0.3 && abs(y) < 0.3 && abs(z) < 0.3{
                    self.startAccel = false
                }
            }
        }
    }
    
    func Alert(message: String,funcDici: Int){
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction) -> Void in
            if funcDici == 1{
                if (self.motionManager.isAccelerometerActive) {
                    self.motionManager.stopAccelerometerUpdates()
                }
                self.redoAction(redo: true)
            }else if funcDici == 2{
                if (self.motionManager.isAccelerometerActive) {
                    self.motionManager.stopAccelerometerUpdates()
                }
                self.restart()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    func redoAction(redo: Bool){
        if redo{
            print("userDefault入れますよ~")
            if var result = userDefault.object(forKey: "result2") as? [Double]{
                result.append(speed)
                userDefault.set(result,forKey:"result2")
            }else{
                userDefault.set([speed],forKey:"result2")
            }
            
            loadView()
            viewDidLoad()
        }
    }
    
    func restart(){
        userDefault.removeObject(forKey: "result2")
        userDefault.removeObject(forKey: "players2")
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
        Alert(message: "本当にやり直しますか？",funcDici: 2)
    }
    
    @IBAction func startButton(_ sender: Any) {
        PlayerApear()
    }
    

    
    
}
