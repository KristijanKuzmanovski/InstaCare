//
//  ViewRequestViewController.swift
//  InstaCare
//
//  Created by Dzin on 21.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit

class ViewRequestViewController: UIViewController {

    var req = ""
    var name = ""
    
    @IBOutlet weak var request: UITextView!
    @IBOutlet weak var Lfullname: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Lfullname.text = name
        self.request.text = req
        // Do any additional setup after loading the view.
    }

    @IBAction func tapConnect(_ sender: Any) {
        
        guard let z1 = storyboard?.instantiateViewController(identifier: "chatA") as? ChatViewController else {
            return
        }
        z1.name = self.name
   
        let isChatActive = UserDefaults.standard.bool(forKey: "chat")
        if isChatActive == false {
            UserDefaults.standard.setValue(true, forKey: "chat")
        }
        
        z1.modalPresentationStyle = .overCurrentContext
        self.present(z1, animated: true, completion: nil)
    }
    
}
