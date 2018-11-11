//
//  TitleViewController.swift
//  SwiftCampApp
//
//  Created by 工藤 響 on 2018/11/10.
//  Copyright © 2018 工藤 響. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
        if motion != UIEvent.EventSubtype.motionShake {
            // シェイクモーション以外では動作させない
            return
        }
        
        
        UIView.animate(withDuration: 1, animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: { (finished: Bool) in
            print("タイトル振りました")

            self.performSegue(withIdentifier: "goGameSelect", sender: nil)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
