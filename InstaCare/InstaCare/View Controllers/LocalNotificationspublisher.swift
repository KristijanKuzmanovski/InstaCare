//
//  LocalNotificationspublisher.swift
//  RestaurantMenu
//
//  Created by Dzin on 3.06.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class LocalNotificationspublisher{
    
    func sendNotification(title: String, subtitle: String, body: String, badge: Int?, delayInterval: Int?){
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body
        
        var delayTrigger: UNTimeIntervalNotificationTrigger?
        
        if let delayInterval = delayInterval{
         delayTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(delayInterval), repeats: false)
        }
        
        if let badge = badge{
            var currentbadgeCount = UIApplication.shared.applicationIconBadgeNumber
            currentbadgeCount += badge
            notificationContent.badge = NSNumber(integerLiteral: currentbadgeCount)
        }
        
        notificationContent.sound = UNNotificationSound.default
        
        
        
        let request = UNNotificationRequest(identifier: "LocalNotification", content: notificationContent, trigger: delayTrigger)
        
        UNUserNotificationCenter.current().add(request) {
            error in if let error = error{
                print(error.localizedDescription)
            }
        }
    }
}

