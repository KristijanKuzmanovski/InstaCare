//
//  TabBarViewController.swift
//  InstaCare
//
//  Created by Dzin on 21.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let z = storyboard?.instantiateViewController(identifier: "MapPage"),
              let z1 = storyboard?.instantiateViewController(identifier: "OperatorChatPage"),
              let z2 = storyboard?.instantiateViewController(identifier: "ChatPage")
              
        else{
            print("ERROR")
            return
        }
        var type = UserDefaults.standard.string(forKey: "type")
        if type == nil {
            print(type)
            type = "user"
        }
        z.tabBarItem = UITabBarItem(title: "Map", image: #imageLiteral(resourceName: "map"), tag: 0)
        z1.tabBarItem = UITabBarItem(title: "Chat", image: #imageLiteral(resourceName: "chat"), tag: 1)
        z2.tabBarItem = UITabBarItem(title: "Chat", image: #imageLiteral(resourceName: "chat") ,tag: 2)
        if type == "user"{
            setViewControllers([z,z2], animated: true)
        }else if type == "operator"{
            self.viewControllers = [z,z1]
            setViewControllers([z,z1], animated: true)
        }
        self.selectedIndex = 0
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.title == "Chat"{
            let isChatActive = UserDefaults.standard.bool(forKey: "chat")
            if isChatActive == true {
              guard let z1 = storyboard?.instantiateViewController(identifier: "chatA")
              else {
                return
               }
                z1.modalPresentationStyle = .overCurrentContext
                self.present(z1, animated: true, completion: nil)
            }
        }
        
    }
}

