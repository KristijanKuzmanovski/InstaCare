//
//  ViewController.swift
//  InstaCare
//
//  Created by Dzin on 18.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import JGProgressHUD

class ViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var Blogin: UIButton!
    @IBOutlet weak var Bregister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.backButtonTitle=" "
    }
    func goToHome(){
        let home = storyboard?.instantiateViewController(withIdentifier: "HomePageTabController")
        view.window?.rootViewController = home
        view.window?.makeKeyAndVisible()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil{
            spinner.show(in: view)
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).getDocument(completion: {(res,err) in
                if err != nil{
                    print("ERROR")
                    print(err!.localizedDescription)
                }else{
                    UserDefaults.standard.setValue(res?.get("name") as? String, forKey: "name")
                    UserDefaults.standard.setValue(res?.get("lastname") as? String, forKey: "lastname")
                    UserDefaults.standard.setValue(res?.get("type") as? String, forKey: "type")
                    UserDefaults.standard.setValue(Auth.auth().currentUser?.email, forKey: "email")
                    DispatchQueue.main.async{
                        self.spinner.dismiss()
                    }
                    self.goToHome()
                }
            })
               }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
}

