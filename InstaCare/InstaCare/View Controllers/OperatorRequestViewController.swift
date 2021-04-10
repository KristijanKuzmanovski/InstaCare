//
//  OperatorRequestViewController.swift
//  InstaCare
//
//  Created by Dzin on 21.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import SideMenu
import FirebaseDatabase

class OperatorRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var menu: SideMenuNavigationController?
    var list : Dictionary<String,AnyObject> = [:]
    var fullname: String = ""
    var request: String = ""

    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        menu = SideMenuNavigationController(rootViewController: (storyboard?.instantiateViewController(identifier: "SideMenu"))!)
        
        menu?.leftSide = true
        
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
        tableView.register(RequestCellTableViewCell.nib(), forCellReuseIdentifier: RequestCellTableViewCell.id)
        tableView.delegate = self
        tableView.dataSource = self
        Database.database().reference().child("requests").observe(.value, with: {(snap) in
            let list2 = snap.value as? Dictionary<String,AnyObject>
            if(list2 != nil){
                self.list = list2!
                for (_,val) in list2!{
                        let name = val["name"] as?  String ?? "Bot"
                        let lastname = val["lastname"] as? String ?? "Bot"
                        self.fullname = name+" "+lastname
                        self.request = val["request"] as? String ?? "Bot"
                        LocalNotificationspublisher().sendNotification(title: "New request", subtitle: self.fullname ,body: self.request, badge: 1, delayInterval: 2)
                        
                    }
            }else{
                self.list = Dictionary<String,AnyObject>()
            }
            self.tableView.reloadData()
            
        })
    }
    

    @IBAction func didTapMenu(_ sender: Any) {
        present(menu!, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.list.count)
        if(self.list.count != 0){
            return self.list.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: RequestCellTableViewCell.id, for: indexPath) as! RequestCellTableViewCell
        var i = 0
        if(self.list.count != 0){
            for (_,val) in list{
                if(i == indexPath.row){
                    let name = val["name"] as?  String ?? "Bot"
                    let lastname = val["lastname"] as? String ?? "Bot"
                    self.fullname = name+" "+lastname
                    self.request = val["request"] as? String ?? "Bot"
                    cell.configure(with: self.fullname, request:  self.request, date: val["date"] as? String ?? "Bot")
                    LocalNotificationspublisher().sendNotification(title: "New request", subtitle: self.fullname ,body: self.request, badge: 1, delayInterval: 2)
                    return cell
                }
                i+=1
            }
        }else{
            cell.configure(with: "Empty", request: "", date: "")
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ViewRequestViewController") as! ViewRequestViewController
        var i = 0
        for (key,val) in list{
            if(i == indexPath.row){
                let name = val["name"] as! String
                let lastname = val["lastname"] as! String
                self.fullname = name+" "+lastname
                vc.name = self.fullname
                vc.req = val["request"] as! String
                UserDefaults.standard.setValue(key, forKey: "user_id")
            
                vc.name = self.fullname
                break
            }
            i+=1
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func uw(_ sender: UIStoryboardSegue){
        self.tabBarController?.selectedIndex = 0
    }
}
