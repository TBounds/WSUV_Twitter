//
//  AddTweetTableViewController.swift
//  WSUV_Twitter
//
//  Created by Tyler James Bounds on 3/27/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit
import Alamofire

class AddTweetTableViewController: UITableViewController, UITextFieldDelegate {

    let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
    @IBOutlet weak var tweetTextField: UITextView!
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func postTweet(_ sender: Any) {
        
        let urlString = kBaseURLString + "/add-tweet.cgi"
        
        let user = self.appDelegate.username
        let sess_token = SSKeychain.password(forService: kWazzuTwitterSessionToken, account: self.appDelegate.username)!
        let tweet = tweetTextField.text as String
        
        NSLog("user: \(user), sess_token: \(sess_token), tweet = \(tweet)")
        
        let parameters = [
            "username" : user,  // username and password
            "session_token" : sess_token,  // obtained from user
            "tweet" : tweet
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {response in
                switch(response.result) {
                case .success(let JSON):
                    NSLog("Success")
                    
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: kAddTweetNotification, object: nil)
                    })
                    
                case .failure(let error):
                    var errMessage = "Unknown Error"
                    switch(response.response!.statusCode) {
                    case 500:
                        errMessage = "Internal server error."
                        break
                    case 400:
                        errMessage = "Cannot post empty tweet."
                        break
                    case 404:
                        errMessage = "Username does not exist."
                        break
                    case 401:
                        errMessage = "Unauthorized."
                        break
                    default:
                        errMessage = "Error code: \(response.response!.statusCode)"
                        break
                    }
                    
                    let postErrorAlertContoller = UIAlertController(title: "Tweet Error", message: nil, preferredStyle: .alert)
                    
                    postErrorAlertContoller.message = errMessage
                    
                    postErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    
                    self.present(postErrorAlertContoller, animated: true, completion: nil)
                    
                } } )
        
    }


}
