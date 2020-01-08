//
//  ViewController.swift
//  ChatAppRealtime
//
//  Created by Apple Guru on 27/11/19.
//  Copyright © 2019 Apple Guru. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    var isSending = false
    var email = ""
    var pass = ""
    var timer = Timer()
    let image = [ #imageLiteral(resourceName: "giphy.gif"),#imageLiteral(resourceName: "liveChat.jpg")]
    var isChange = true
    let referance = Database.database().reference()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
     private func getCurrentTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.currentTime) , userInfo: nil, repeats: true)
        }

        @objc func currentTime() {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm:ss a"
            timeLbl.text = formatter.string(from: Date())

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.CollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? FromCell
        if (indexPath.row == 0) {
            cell?.userNameContainer.isHidden = true
            cell?.actionButton.setTitle("LogIn", for: .normal)
            cell?.slideButton.setTitle("SingUp 👉🏻", for: .normal)
            cell?.slideButton.addTarget(self, action: #selector(slideToSingInCell(_:)), for: .touchUpInside)
            cell?.actionButton.addTarget(self, action: #selector(didPressSingIn(_:)), for: .touchUpInside)
            if isSending == true {
                cell?.EmailAdressTextField.text = email
                cell?.passwordTextField.text = pass
            }
        }else if (indexPath.row == 1) {
            cell?.userNameContainer.isHidden = false
            cell?.actionButton.setTitle("SingUp", for: .normal)
            cell?.slideButton.setTitle("👈🏻 LogIn", for: .normal)
            cell?.slideButton.addTarget(self, action: #selector(slideToLogInCell(_:)), for: .touchUpInside)
            cell?.actionButton.addTarget(self, action: #selector(didPressSingUp(_:)), for: .touchUpInside)
        }
        return cell!
    }
    
    @objc func slideToSingInCell(_ sender: UIButton) {
        let indexPath = IndexPath(row: 1, section: 0)
        CollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
    }
    @objc func slideToLogInCell(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        CollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    @objc func didPressSingUp(_ sender: UIButton) {
       let indexPath = IndexPath(row: 1, section: 0)
        let cell = self.CollectionView.cellForItem(at: indexPath) as? FromCell
        guard let emailAddress = cell?.EmailAdressTextField.text, let password = cell?.passwordTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: emailAddress, password: password) { (result, error) in
            if (error == nil) {
                guard let useId = result!.user.uid as? String  else {
                    return
                }
                print(useId)
                guard let userId = result?.user.uid, let userName = cell?.userNameTextField.text else {
                    
                   return
                }
                let user = self.referance.child("users").child(userId)
                let dataArray:[String:Any] = ["username": userName]
                user.setValue(dataArray)
                self.isSending = true
                self.email = emailAddress
                self.pass = password
                let indexPath = IndexPath(row: 0, section: 0)
                self.CollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                self.CollectionView.reloadData()
                
            } else {
                self.displayError(errorText: "Please fill correct email address")
                cell?.EmailAdressTextField.text = ""
                //cell?.passwordTextField.text = ""
           }
        }
    }
    
    @objc func didPressSingIn(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
               let cell = self.CollectionView.cellForItem(at: indexPath) as? FromCell
               guard let emailAddress = cell?.EmailAdressTextField.text, let password = cell?.passwordTextField.text else {
                   return
               }
        
        if (emailAddress.isEmpty == true || password.isEmpty == true) {
            self.displayError(errorText: "Please fill empty fields")
        } else {
        Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
            if (error == nil) {
                print("result")
                let sceneDeleage = SceneDelegate.shared
                       let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                       let vc : UIViewController = storyboard.instantiateViewController(withIdentifier: "rooms")
                       sceneDeleage?.window?.makeKeyAndVisible()
                       sceneDeleage?.window?.rootViewController = vc
                
            } else {
                self.displayError(errorText: "Wrong Username or Password")
                cell?.EmailAdressTextField.text = ""
                cell?.passwordTextField.text = ""
            }
        }
        
            }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.CollectionView.frame.size
    }
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionView.delegate = self
        CollectionView.dataSource = self
        getCurrentTime()
        // Do any additional setup after loading the view.
    }


}

extension ViewController {
    func displayError(errorText: String) {
        let alert = UIAlertController.init(title: "Error", message: errorText, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Dissmiss", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

