//
//  RegisterViewController.swift
//  InstaCare
//
//  Created by Dzin on 18.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import JGProgressHUD

class RegisterViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var cpassword: UITextField!
    @IBOutlet weak var lerror: UILabel!
    @IBOutlet weak var Bcreate: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        
        if name.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastname.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            cpassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            
            return "All field must be filled in."
        }
        if  !isValidEmail(email.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
            return "Email is not valid."
        }
        if password.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 6{
            return "Password must be at least 6 characters long."
        }

        if  password.text?.trimmingCharacters(in: .whitespacesAndNewlines) != cpassword.text?.trimmingCharacters(in: .whitespacesAndNewlines){
            
            return "Passwords don't match."
        }
        
        return nil
    }
    func goToHome(){
        let home = storyboard?.instantiateViewController(withIdentifier: "HomePageTabController")
        view.window?.rootViewController = home
        view.window?.makeKeyAndVisible()
    }
    
    @IBAction func createTapped(_ sender: Any) {
        let msg: String? = validate()
        if msg == nil{
            spinner.show(in: view)
            Auth.auth().createUser(withEmail: email.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: password.text!.trimmingCharacters(in: .whitespacesAndNewlines), completion: { (res, err) in
                if err != nil {
                    self.showError(msg: "Database Error - Could not create account.")
                }else{
                    let db = Firestore.firestore()
                    
                    db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                        "uid": res!.user.uid,
                        "name": self.name.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                        "lastname": self.lastname.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                        "type": "user"
                    ], completion: {err in
                        if err != nil{
                            self.showError(msg: "Database Error - Could not add data to user.")
                        }
                        UserDefaults.standard.setValue(self.name.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "name")
                        UserDefaults.standard.setValue(self.lastname.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "lastname")
                        UserDefaults.standard.setValue(self.email.text!.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "email")
                        UserDefaults.standard.setValue("user", forKey: "type")
                    })
                    DispatchQueue.main.async{
                        self.spinner.dismiss()
                    }
                     self.goToHome()
                }
            })
        }else {
            showError(msg: msg!)
        }
    }
}
