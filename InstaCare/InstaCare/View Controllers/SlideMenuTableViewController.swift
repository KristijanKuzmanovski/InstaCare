//
//  SlideMenuTableViewController.swift
//  InstaCare
//
//  Created by Dzin on 19.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SlideMenuTableViewController: UITableViewController {
    
    @IBOutlet weak var Lname: UILabel!
    @IBOutlet weak var Llastname: UILabel!
    @IBOutlet weak var Lemail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var name = UserDefaults.standard.string(forKey: "name")
        var lastname = UserDefaults.standard.string(forKey: "lastname")
        
        if name == nil || lastname == nil {
            Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).getDocument{
                (doc ,err) in
                if err != nil {
                    print("Database Error")
                }
                name = doc?.get("name") as? String
                lastname = doc?.get("lastname") as? String
                
                UserDefaults.standard.setValue(name, forKey: "name")
                UserDefaults.standard.setValue(lastname, forKey: "lastname")
            }
        }
        
        Lemail.text = Auth.auth().currentUser?.email
        Lname.text = name
        Llastname.text = lastname
    }
    override func viewWillAppear(_ animated: Bool) {
        let name = UserDefaults.standard.string(forKey: "name")
        let lastname = UserDefaults.standard.string(forKey: "lastname")
        Lemail.text = Auth.auth().currentUser?.email
        Lname.text = name
        Llastname.text = lastname
    }
    
    func goToLogin(){
        let home = storyboard?.instantiateViewController(withIdentifier: "LoginPage")
        view.window?.rootViewController = home
        view.window?.makeKeyAndVisible()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3{
            let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
                do { try Auth.auth().signOut()}
                catch {print("Error while signing out")}
                UserDefaults.standard.setValue(false, forKey: "chat")
                self.goToLogin()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
