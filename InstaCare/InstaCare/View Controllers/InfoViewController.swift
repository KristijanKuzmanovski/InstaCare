//
//  InfoViewController.swift
//  InstaCare
//
//  Created by Dzin on 19.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var Lversion: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var Lcontact: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Lversion.text = "Version 1.0.0"
        Lcontact.text = "test@test.com"
        
        textView.text = "This app enables goverments to better handle crisis situations by better informing people about new developments and giving people instructions about how to dieal with the crisis.\nThis app also can alleviate the strain on resources.\nOn the map tab you can see your location (if you allow the permissions) and the locations of all the stations where you can receive help in a time of crisis.\nOn the chat tab you will be able to contact and speak directly to a trained operator who can help you in your time of need."

    }
}
