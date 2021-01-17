//
//  ResultViewController.swift
//  RubberDuck
//
//  Created by Mia Berthier on 2021-01-17.
//

import UIKit
import Firebase
import FirebaseFirestore

class ResultViewController: UIViewController {
    
    
    @IBOutlet weak var BgImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        
        db.collection("results").document("emotion").getDocument { [self] (document, error) in
           
            if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    let currString = "Document data: \(dataDescription)"
                
                if currString.hasSuffix("happy]") {
                    BgImage.image = UIImage(named: "happy")
                } else if currString.hasSuffix("sad]") {
                    BgImage.image = UIImage(named: "sad")
                } else if currString.hasSuffix("angry]") {
                    BgImage.image = UIImage(named: "angry")
                } else if currString.hasSuffix("calm]") {
                    BgImage.image = UIImage(named: "calm")
                } else if currString.hasSuffix("neutral]") {
                    BgImage.image = UIImage(named: "neutral")
                } else if currString.hasSuffix("disgusted]") {
                    BgImage.image = UIImage(named: "disgusted")
                } else if currString.hasSuffix("surprised]") {
                    BgImage.image = UIImage(named: "surprised")
                } else {
                    BgImage.image = UIImage(named: "error")
                }
            
        }

        // Do any additional setup after loading the view.
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
}
