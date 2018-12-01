//
//  AuthViewController.swift
//  Crypto Tracker
//
//  Created by Apeksha Sahu on 9/12/18.
//  Copyright © 2018 Apeksha Sahu. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
        
        presentAuth()
    }

    
    func presentAuth(){
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Your crypto is protected by biometrics") { (success, error) in
            if success {
                DispatchQueue.main.async {
                  
                    let cryptoTableVC = CryptoTableViewController()
                    let navTableVC = UINavigationController(rootViewController: cryptoTableVC)
                    self.present(navTableVC, animated: true, completion: nil)
                }
            } else {
                self.presentAuth()
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
