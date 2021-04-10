//
//  ProfileViewController.swift
//  InstaCare
//
//  Created by Dzin on 19.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    @IBOutlet weak var Lfullname: UILabel!
    @IBOutlet weak var Lemail: UILabel!
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var oldpassword: UITextField!
    @IBOutlet weak var newpassword: UITextField!
    @IBOutlet weak var cnewpassword: UITextField!
    @IBOutlet weak var LerrorForPass: UILabel!
    @IBOutlet weak var cpview: UIView!
    
    
    @IBOutlet weak var cprofileview: UIView!
    @IBOutlet weak var name: UITextField!

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var LerrorForEditProfile: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let n = UserDefaults.standard.string(forKey: "name") == nil ? "" : UserDefaults.standard.string(forKey: "name")!
        let ln = UserDefaults.standard.string(forKey: "lastname") == nil ? "" : UserDefaults.standard.string(forKey: "lastname")!
        Lfullname.text = n + " " + ln
        Lemail.text = Auth.auth().currentUser?.email
    }

    @IBAction func tapEditProfileConfirm(_ sender: Any) {
        
        let msg = validateForEditProfile()
        let Tname = name.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let Tlastname = lastname.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let Temail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if msg == nil{
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData([
                "name" : Tname!,
                "lastname" : Tlastname!
            ],completion: {err in
                if err != nil{
                    print(err!.localizedDescription)
                    self.showErrorForProfile(msg: "Failed to update")
                }
            })
            
            Auth.auth().currentUser?.updateEmail(to: Temail!, completion: {err in
                if err != nil {
                    print(err!.localizedDescription)
                    self.showErrorForProfile(msg: "Failed to update")
                }
                else{
                    UserDefaults.standard.setValue(Tname!, forKey: "name")
                    UserDefaults.standard.setValue(Tlastname!, forKey: "lastname")
                    UserDefaults.standard.setValue(Temail!, forKey: "email")
                    self.Lfullname.text = Tname! + " " + Tlastname!
                    self.Lemail.text = Temail!
                    self.cprofileview.isHidden = true
                    self.stack.isHidden = false
                }
            })
            
        }
        else {

            showErrorForProfile(msg: msg!)
        }

    }
    @IBAction func tapEditProfile(_ sender: Any) {
        stack.isHidden = true
        cprofileview.isHidden = false
    }
    @IBAction func tapCancelForEditProfile(_ sender: Any) {
        stack.isHidden = false
        cprofileview.isHidden = true
    }
    @IBAction func tapChangePassword(_ sender: Any) {
        stack.isHidden = true
        cpview.isHidden = false
    }
    @IBAction func didTapChangePassword(_ sender: Any) {
        let msg = validateForPass()
        if msg == nil {
            let oldpass = oldpassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let newpass = newpassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            let cridential = EmailAuthProvider.credential(withEmail: Auth.auth().currentUser!.email!, password: oldpass!)
            Auth.auth().currentUser?.reauthenticate(with: cridential, completion: {(res,err) in
                if err != nil {
                    self.showErrorPass(msg: err!.localizedDescription)
                    print(err!.localizedDescription)
                }
                else{
                    Auth.auth().currentUser?.updatePassword(to: newpass!, completion: { err in
                        if err != nil  {
                            self.showErrorPass(msg: "Database error")
                            print("RES")
                            print(err!.localizedDescription)
                        }
                        else{
                            do { try Auth.auth().signOut()}
                            catch {print("Error while signing out")}
                            self.goToLogin()
                        }
                    })
                }
                
            })
            
        }else{
            showErrorPass(msg: msg!)
        }
    }
    func goToLogin(){
        let home = storyboard?.instantiateViewController(withIdentifier: "LoginPage")
        view.window?.rootViewController = home
        view.window?.makeKeyAndVisible()
    }
    @IBAction func tapCancelForPassChange(_ sender: Any) {
        cpview.isHidden = true
        stack.isHidden = false
    }
    func showErrorPass(msg: String){
        LerrorForPass.alpha = 1
        LerrorForPass.text = msg
    }
    func showErrorForProfile(msg: String){
        LerrorForEditProfile.alpha = 1
        LerrorForEditProfile.text = msg
    }
    func validateForPass() -> String?{
        let oldpass = oldpassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let newpass = newpassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cnewpass = cnewpassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if oldpass == "" ||
            newpass == "" ||
            cnewpass == ""
        {
            
            return "All field must be filled in."
        }
        if newpass!.count < 6 {
            return "Password must be at least 6 characters long."
        }

        if  newpass != cnewpass {
            
            return "Passwords don't match."
        }
        
        return nil
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func validateForEditProfile() -> String?{
        let Tname = name.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let Tlastname = lastname.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let Temail = email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Tname == "" ||
            Temail == "" ||
            Tlastname == ""
        {
            
            return "All field must be filled in."
        }
        if  !isValidEmail(Temail!)
        {
            return "Email is not valid."
        }

        return nil
    }
}
