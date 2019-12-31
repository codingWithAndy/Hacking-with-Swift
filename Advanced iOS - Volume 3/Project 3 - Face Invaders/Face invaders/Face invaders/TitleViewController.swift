//
//  TitleViewController.swift
//  Face invaders
//
//  Created by Andy Gray on 31/12/2019.
//  Copyright © 2019 Andy Gray. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {
    override func viewDidLoad() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
