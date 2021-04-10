//
//  FindOperatorViewController.swift
//  InstaCare
//
//  Created by Dzin on 21.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import SideMenu
import FirebaseDatabase
import FirebaseAuth

class FindOperatorViewController: UIViewController {


    var menu: SideMenuNavigationController?
    @IBOutlet weak var problemDetails: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        
        menu = SideMenuNavigationController(rootViewController: (storyboard?.instantiateViewController(identifier: "SideMenu"))!)
        
        menu?.leftSide = true
        
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
    }
    
    func close(){
        print("close")
        self.tabBarController?.selectedIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isChatActive = UserDefaults.standard.bool(forKey: "chat")
        if isChatActive == true {
            
            self.tabBarController?.selectedIndex = 0
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let isChatActive = UserDefaults.standard.bool(forKey: "chat")
        if isChatActive == true {
            
            self.tabBarController?.selectedIndex = 0
        }
    }
    @IBAction func didTapMenu(_ sender: Any) {
        present(menu!, animated: true)
    }

    @IBAction func tapFindOperator(_ sender: Any) {
        if problemDetails.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" && problemDetails.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "Please enter a description about your problem."{
            let date = Date.getDate()
            print(date)
            Database.database().reference().child("requests").child(Auth.auth().currentUser!.uid).setValue(["name":UserDefaults.standard.string(forKey: "name"),"lastname":UserDefaults.standard.string(forKey: "lastname"),"request":problemDetails.text,"date":date])
            problemDetails.text = ""
            guard let z1 = storyboard?.instantiateViewController(identifier: "chatA") as? ChatViewController else {
                return
            }
            

            
            z1.modalPresentationStyle = .overCurrentContext
            self.present(z1, animated: true, completion: nil)

        }else{
            problemDetails.text = "Please enter a description about your problem."
        }
}

    
}
extension Date{
    static func getDate() -> NSString{
        let date = DateFormatter()
        date.dateFormat="dd/MM/YYYY"
        return NSString(string: date.string(from: Date()))
    }
}
