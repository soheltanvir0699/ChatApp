//
//  ChatRoomsViewController.swift
//  ChatAppRealtime
//
//  Created by Apple Guru on 29/11/19.
//  Copyright © 2019 Apple Guru. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    var roomName = ""
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        /* this is where the magic happens, create a UIView and set its
           backgroundColor to what ever color you like then set the cell's
           selectedBackgroundView to your created View */

        let backgroundView = UIView()
        cell.selectedBackgroundView = backgroundView
        let message = self.chatMessages[indexPath.row]
        if message.senderId != Auth.auth().currentUser?.uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatCellOne
            cell!.cellView.layer.cornerRadius = 10
            cell?.userNameLabel.text = "  \(message.senderName!)"
            cell?.chatTextView.text = message.messageText
            return cell!
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as? ChatCellTwo
          cell!.cellView.layer.cornerRadius = 10
            cell?.userNameLabel.text = message.senderName
            cell?.chatTextView.text = message.messageText
            return cell!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chatTable.estimatedRowHeight = 100
        chatTable.rowHeight = UITableView.automaticDimension

    }
    var room: Room?

    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    var chatMessages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        chatTable.separatorStyle  = .none
        observeMessage()
        // Do any additional setup after loading the view.
    }
    func observeMessage() {
        guard let roomId = self.room?.roomId else {
             return
        }
        let databaseRef = Database.database().reference()
        databaseRef.child("rooms").child(roomId).child("messages").observe(.childAdded) { (snapshot) in
            print(snapshot)
            if let dataArray = snapshot.value as? [String: Any]{
                guard let senderName = dataArray["senderName"] as? String, let messageText = dataArray["text"] as? String, let senderId = dataArray["senderId"] as? String else {
                    return
                }
                let message = Message.init(messageKey: snapshot.key, senderName: senderName, messageText: messageText,senderId:senderId)
                self.chatMessages.append(message)
                self.chatTable.reloadData()
                let indexpath = IndexPath(row: self.chatMessages.count-1, section: 0)
                if self.chatMessages.count != 0 {
                self.chatTable.scrollToRow(at: indexpath, at: .bottom, animated: true)
                }
            }
        }
    }
    func getUsernamedWithId(id: String, completion: @escaping (_ userName: String?) -> ()) {
        let databaseRef = Database.database().reference()
        let user = databaseRef.child("users").child(id)
        user.child("username").observeSingleEvent(of: .value) { (snapshort) in
            if let userName = snapshort.value as? String {
                completion(userName)
            } else {
                completion(nil)
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping(_ isSuccess: Bool) -> ()) {
       guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        getUsernamedWithId(id: userId) { (userName) in
            let databaseRef = Database.database().reference()
            if let userName = userName {
                print("username is \(userName)")
                if let roomId = self.room?.roomId,let userId = Auth.auth().currentUser?.uid {
                    let dataArray: [String: Any] = ["senderName": userName, "text": text,"senderId": userId]
                let room = databaseRef.child("rooms").child(roomId)
                    room.child("messages").childByAutoId().setValue(dataArray) { (error, ref) in
                        if (error == nil) {
                            print("database data send successfuly")
                            self.chatTextField.text = ""
                            let indexpath = IndexPath(row: self.chatMessages.count-1, section: 0)
                            if self.chatMessages.count != 0 {
                            self.chatTable.scrollToRow(at: indexpath, at: .bottom, animated: true)
                            }
                          completion(true)
                           // }
                        } else {
                          completion(false)
                      }
                    }
                    
                
                }
            }
        }
                  
    }
    @IBAction func didPressSend(_ sender: Any) {
        guard let chatText = self.chatTextField.text, chatText != nil else {
            return
        }
        
        sendMessage(text: chatText) { (isSuccess) in
            if isSuccess {
                
            } else {
                
            }
        }
        
    }

}
