//
//  ChatViewController.swift
//  InstaCare
//
//  Created by Dzin on 18.11.20.
//  Copyright © 2020 Dzin. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseAuth
import FirebaseDatabase
import InputBarAccessoryView
import AVFoundation
import AVKit
import FirebaseStorage
import SDWebImage
import CoreMotion


struct Sender : SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType{
    var sender: SenderType
    var messageId: String = ""
    var sentDate: Date
    var kind: MessageKind
}
struct Media: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatViewController: MessagesViewController, MessagesDataSource,MessagesLayoutDelegate, MessagesDisplayDelegate,InputBarAccessoryViewDelegate{
    
    var id: String = UserDefaults.standard.string(forKey: "user_id") as? String ?? ""
    var name: String = "BOT"
    let type = UserDefaults.standard.string(forKey: "type")
    let currSender = Sender(senderId: UserDefaults.standard.string(forKey: "email") as? String ?? "Error", displayName: UserDefaults.standard.string(forKey: "name") as? String ?? "Error") //FIX THISSS
    let other = Sender(senderId: "fix", displayName: "FIXER")
    let pm = CMPedometer()
    var messages = [MessageType]()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        setUpNavBar()
        setUpExtraButtons()
        
        if(self.type == "user"){
        messages.append(Message(sender: other, messageId: "1", sentDate: Date(), kind: .text("Please wait for the operator to connect.")))
        }
        if(self.id == ""){
            self.id = Auth.auth().currentUser?.uid as! String
            
        }

        Database.database().reference().child("chat/"+self.id).observe(.value, with: {snap in
            guard let s = snap.value as? Dictionary<String,AnyObject> else{
                return
            }
            
            
            for (key,val) in s{
                var flag = true
                for m in self.messages{
                    if(key == m.messageId){
                       flag = false
                    }
                }
                
                if flag {
                    if(val["sender"] as! String != Auth.auth().currentUser!.email!){
                        
                        if(val["message"] as! String == "Chat has ended"){
                            self.end()
                        }

                
                        if(self.type == "user"){
                            self.name = val["sender"] as! String
                            self.setUpNavBar()
                        }
                        if((val["message"] as! String).prefix(13) == "photo_message"){
                            let msg = val["message"] as! String
                            Storage.storage().reference().child("images/"+msg).downloadURL(completion: {url,err in
                          
                                guard let url = url,err == nil else{
                                    return
                                }
                                let media = Media(url: url, image: nil, placeholderImage: UIImage(systemName: "plus")!, size: CGSize(width: 300, height: 300))
                                self.messages.append(Message(sender: self.other, messageId: key, sentDate: Date(), kind: .photo(media)))
                                
                                self.messagesCollectionView.reloadData()
                                self.messagesCollectionView.scrollToBottom(animated: true)
                                
                            })

                            LocalNotificationspublisher().sendNotification(title: "New message", subtitle: self.other.senderId ,body: "Photo sent", badge: 1, delayInterval: 2)
                        }else{
                            self.messages.append(Message(sender: self.other, messageId: key, sentDate: Date(), kind: .text(val["message"] as! String)))
                            LocalNotificationspublisher().sendNotification(title: "New message", subtitle: self.other.senderId ,body: val["message"] as! String, badge: 1, delayInterval: 2)
                        }
                       
                    }else{
                        if((val["message"] as! String).prefix(13) == "photo_message"){
                            let msg = val["message"] as! String
                            Storage.storage().reference().child("images/"+msg).downloadURL(completion: {url,err in
                             
                                guard let url = url,err == nil else{
                                    return
                                }
                                let media = Media(url: url, image: nil, placeholderImage: UIImage(systemName: "plus")!, size: CGSize(width: 300, height: 300))
                                self.messages.append(Message(sender: self.currSender, messageId: key, sentDate: Date(), kind: .photo(media)))
                              
                                self.messagesCollectionView.reloadData()
                                self.messagesCollectionView.scrollToBottom(animated: true)
                                
                            })


                        }
                        else{
                        self.messages.append(Message(sender: self.currSender, messageId: key, sentDate: Date(), kind: .text(val["message"] as! String)))
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    override func viewDidLayoutSubviews() {
        self.messagesCollectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 70, right: 0)
    }
    @objc func goToHome(){
        let x = self.presentingViewController as? FindOperatorViewController
        dismiss(animated: true){
            
            x?.close()
        }
        
    }
    func setUpExtraButtons(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.onTouchUpInside{[weak self]_ in
            self?.presentActions()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
    }
    func presentActions(){
        let actionSheet = UIAlertController(title: "Extras",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputAction()
        }))
        actionSheet.addAction(UIAlertAction(title: "Steps", style: .default, handler: { [weak self] _ in
            self?.stepCounter()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    func stepCounter(){
        // NE TESTIRAN KOD BIDEJKI PROEKTOT E IZRABOTEN VO EMULATOR
        if CMPedometer.isStepCountingAvailable(){
            self.pm.startUpdates(from: Date(), withHandler: {data,err in
                guard let res = data,err == nil else{
                    return
                }
                Database.database().reference().child("chat/"+self.id).child(UUID().uuidString).setValue(["sender":self.currSender.senderId,"message": res.numberOfSteps])
                self.pm.stopUpdates()
            })

        }else{
            Database.database().reference().child("chat/"+self.id).child(UUID().uuidString).setValue(["sender":self.currSender.senderId,"message": "Device does not have pedometer."])
        }
    }
    func presentPhotoInputAction(){
        let actionSheet = UIAlertController(title: "Attach Photo",
                                                    message: "Where would you like to attach a photo from",
                                                    preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
                    // NE TESTIRAN KOD BIDEJKI PROEKTOT E IZRABOTEN VO EMULATOR
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.delegate = self
                    picker.allowsEditing = true
                    self?.present(picker, animated: true)

                }))
                actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in

                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    picker.allowsEditing = true
                    self?.present(picker, animated: true)

                }))
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                present(actionSheet, animated: true)
    }
    @objc func end(){
        if (self.type == "operator"){
        let msg = Message(sender: currSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text("Chat has ended"))
        Database.database().reference().child("chat/"+self.id).child(msg.messageId).setValue(["sender":msg.sender.senderId,"message": "Chat has ended"])
        Database.database().reference().child("chat/"+self.id).removeAllObservers()
        Database.database().reference().child("chat/"+self.id).removeValue()
        Database.database().reference().child("requests/"+self.id).removeValue()
        }
        UserDefaults.standard.setValue(false, forKey: "chat")
        UserDefaults.standard.setValue("", forKey: "user_id")
        dismiss(animated: true, completion: nil)
    }
    func currentSender() -> SenderType {
        return currSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        let msg = Message(sender: currSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))

        Database.database().reference().child("chat/"+self.id).child(msg.messageId).setValue(["sender":msg.sender.senderId,"message": text])
        inputBar.inputTextView.text = ""
    }
    func setUpNavBar() {
            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 30, width: UIScreen.main.bounds.width, height: 30))
            self.view.addSubview(navBar)
            navBar.items?.append(UINavigationItem(title: self.name))
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goToHome))
            //navBar.topItem?.leftBarButtonItem = backButton
            let endButton = UIBarButtonItem(title: "End", style: .plain, target: self, action: #selector(end))
            navBar.topItem?.rightBarButtonItem = endButton
            
        }
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let msg = message as? Message else{
            return
        }
        switch msg.kind {
        case .photo(let media):
            guard let url = media.url else {
                return
            }
            imageView.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
}
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)


        if let image = info[.editedImage] as? UIImage, let imageData =  image.pngData() {
            let fileName = "photo_message_" + UUID().uuidString.replacingOccurrences(of: " ", with: "-") + ".png"

            // Upload image
 
            Storage.storage().reference().child("images/"+fileName).putData(imageData, metadata: nil, completion: {mt,err in
                guard err == nil else{
                    return
                }
                Database.database().reference().child("chat/"+self.id).child(UUID().uuidString).setValue(["sender":self.currSender.senderId,"message": fileName])
            })
            

        
        }
    }

}
