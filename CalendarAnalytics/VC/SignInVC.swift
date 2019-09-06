//
//  SignInVC.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/7/31.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import ProgressHUD

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeCalendarReadonly]
        
        // Uncomment to automatically sign in the user.
        if(GIDSignIn.sharedInstance().hasAuthInKeychain()){
            ProgressHUD.show("Log in...", interaction: false)
            GIDSignIn.sharedInstance().signInSilently()
        }
//        if GIDSignIn.sharedInstance().currentUser != nil{
//            performSegue(withIdentifier: "segueI mport", sender: nil)
//        }
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

extension SignInVC: GIDSignInUIDelegate, GIDSignInDelegate{
    //GID SignInUIDelegate
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        present(viewController, animated: true, completion: nil)
    }
    
    //GID SignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            /*let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email*/
            
            /*let url = NSURL(string: "https://www.googleapis.com/calendar/v3/calendars/tesusimina@gmail.com/events?maxResults=15&key="+API_KEY)
            let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
                let dataAsNSString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(dataAsNSString)
            }
            task.resume()*/
            performSegue(withIdentifier: "segueImport", sender: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        ProgressHUD.showSuccess()
    }
}
