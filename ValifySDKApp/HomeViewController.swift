//
//  HomeViewController.swift
//  ValifySDKApp
//
//  Created by Peter Samir on 29/08/2024.
//

import UIKit
import ValifySDK

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func action(_ sender: Any) {
        let vc = CameraViewController(viewModel: CameraViewModel(cameraHandler: CameraHandler()))
        
        self.present(vc, animated: true)
    }
    

}
