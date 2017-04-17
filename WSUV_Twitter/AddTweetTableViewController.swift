//
//  AddTweetTableViewController.swift
//  WSUV_Twitter
//
//  Created by Tyler James Bounds on 3/27/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit
import Alamofire

class AddTweetTableViewController: UITableViewController, UITextViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let charLimit = 140
  
    @IBOutlet weak var tweetTextField: UITextView!
    @IBOutlet weak var charLimitLabel: UILabel!
    
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextField.delegate = self
        
        charLimitLabel.text = "0/140"
        
    }
    
    
    // http://stackoverflow.com/questions/32935528/setting-maximum-number-of-characters-of-uitextview-and-uitextfield
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        
        let length = String(numberOfChars)
        
        // Prevents char limit label bug from displaying 141.
        if(numberOfChars <= charLimit) {
            charLimitLabel.text = length + "/140"
        }
        
        return numberOfChars <= charLimit;
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
        let sess_token = SAMKeychain.password(forService: kWazzuTwitterSessionToken, account: self.appDelegate.username)!
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
                    NSLog("\(JSON)")
                    
                    self.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: kAddTweetNotification, object: nil)
                    })
                    
                case .failure(let error):
                    NSLog("\(error)")
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
