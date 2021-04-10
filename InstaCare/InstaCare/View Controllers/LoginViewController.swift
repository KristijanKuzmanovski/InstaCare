//
//  LoginViewController.swift
//  InstaCare
//
//  Created by Dzin on 18.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

class LoginViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var lerror: UILabel!
    @IBOutlet weak var Blogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if UserDefaults.standard.string(forKey: "email") != nil || UserDefaults.standard.string(forKey: "email") != ""{
            email.text = UserDefaults.standard.string(forKey: "email")
        }
        setUp()
    }
    
    func setUp(){
        lerror.alpha = 0
    }
    func showError(msg: String){
          lerror.alpha = 1
          lerror.text = msg
      }
      func isValidEmail(_ email: String) -> Bool {
          let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

          let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
          return emailPred.evaluate(with: email)
      }
    func validate() -> String?{
           
           
           if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
           {
               
               return "All field must be filled in."
           }
        
           if  !isValidEmail(email.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
               return "Email is not valid."
           }
        
           if password.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 6{
               return "Password must be at least 6 characters long."
           }
           return nil
       }
       func goToHome(){
           let home = storyboard?.instantiateViewController(withIdentifier: "HomePageTabController")
           view.window?.rootViewController = home
           view.window?.makeKeyAndVisible()
       }

    @IBAction func loginTapped(_ sender: Any) {
        let msg: String? = validate()
               if msg == nil{
                spinner.show(in: view)
                Auth.auth().signIn(withEmail: email.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: password.text!.trimmingCharacters(in: .whitespacesAndNewlines), completion: { (res,err) in
                    
                    DispatchQueue.main.async{
                        self.spinner.dismiss()
                    }
                    
                    if err != nil{
                        self.showError(msg: err!.localizedDescription)
                    }
                    else{
                        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).getDocument(completion: {(res,err) in
                            if err != nil{
                                print("ERROR")
                                print(err!.localizedDescription)
                            }else{
                                UserDefaults.standard.setValue(res?.get("name") as? String, forKey: "name")
                                UserDefaults.standard.setValue(res?.get("lastname") as? String, forKey: "lastname")
                                UserDefaults.standard.setValue(res?.get("type") as? String, forKey: "type")
                                UserDefaults.standard.setValue(self.email.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "email")
                                self.goToHome()
                            }
                        })
                        

                    }
                })
               }else {
                   showError(msg: msg!)
               }
    }
}

