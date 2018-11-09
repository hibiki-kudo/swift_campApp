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
    
    let userDefault = UserDefaults.standard
    var pleyerNum:Int = 0
    var nowPlayer:Int = 1
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
        pleyerNum = userDefault.object(forKey: "players2") as! Int
        Bar.rightBarButtonItems = barItem.rightBarButtonItems
        playerDicision()
    }
    
    func playerDicision(){
        if nowPlayer > pleyerNum{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの勝利です"
        }else{
            PlayerLabel.text = "プレイヤー\(nowPlayer)さんの番です"
            nowPlayer += 1
        }
    }
    
    @objc func redoMessage(){
        Alert(message: "パスしますか？",funcDici: 1)
        
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
                let synthetic = (x * x) + (y * y) + (z * z)
                print(synthetic)
                
                if synthetic >= 8 && self.startAccel == false{
                    self.startAccel = true
                    
                    self.audioPlayer.currentTime = 0
                    self.audioPlayer.play()
                }
                
                if self.startAccel == true && synthetic < 1{
                    self.startAccel = false
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
             Alert(message: "本当にやり直しますか？",funcDici: 2)
    }

    @IBAction func startButton(_ sender: Any) {
        PlayerApear()
    }
    
    
    
}
