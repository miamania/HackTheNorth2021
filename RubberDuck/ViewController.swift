//
//  ViewController.swift
//  RubberDuck
//
//  Created by Mia Berthier on 2021-01-15.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var GifView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GifView.loadGif(name: "GifTheyFeel")
    }
    
    


}

