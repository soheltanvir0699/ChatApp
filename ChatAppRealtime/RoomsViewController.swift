//
//  RoomsViewController.swift
//  ChatAppRealtime
//
//  Created by Apple Guru on 29/11/19.
//  Copyright © 2019 Apple Guru. All rights reserved.
//

import UIKit
import Firebase

class RoomsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
   
    @IBOutlet weak var newRoomsTextField: UITextField!
    @IBOutlet weak var roomsTable: UITableView!
    var rooms = [Room]()
    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTable.delegate = self
        roomsTable.dataSource = self
        observeRoom()
        // Do any additional setup after loading the view.
    }
    
    func observeRoom() {
        let databaseRef = Database.database().reference()
        databaseRef.child("rooms").observe(.childAdded) { (snapshot) in
            print(snapshot)
            if let dataArray = snapshot.value as? [String: Any] {
               print( dataArray["roomName"])
              if let roomName = dataArray["roomName"] as? String {
                let room = Room.init(roomName:roomName, roomId:snapshot.key)
                self.rooms.append(
                    room)
                self.roomsTable.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (Auth.auth().currentUser == nil) {
        logInScreen()
        }
    }
    
    @IBAction func didPressLogOut(_ sender: UIBarButtonItem) {
        logInScreen()
        try! Auth.auth().signOut()
        
    }
    
    @IBAction func didPressCreateNewRoom(_ sender: Any) {
        guard let roomName = self.newRoomsTextField.text, newRoomsTextField.text != nil else {
            return
        }
        
        let databaseRef = Database.database().reference()
        let room = databaseRef.child("rooms").childByAutoId()
        
        let dataArray:[String: Any] = ["roomName": roomName]
        room.setValue(dataArray) { (error, ref) in
            if (error == nil) {
                self.newRoomsTextField.text = ""
            }
        }
    }
    func logInScreen() {
        let sceneDeleage = SceneDelegate.shared
               let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
               let vc : UIViewController = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
               sceneDeleage?.window?.makeKeyAndVisible()
               sceneDeleage?.window?.rootViewController = vc
        
               print("logOut")
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel!.text = rooms[indexPath.row].roomName
        cell?.textLabel?.font =  UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        //cell?.textLabel?.textAlignment = .center
        return cell!
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomView = self.storyboard?.instantiateViewController(withIdentifier: "chatRoom") as? ChatRoomsViewController
        chatRoomView!.room = self.rooms[indexPath.row]
        self.navigationController?.pushViewController(chatRoomView!, animated: true)
    }
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
