//
//  TweetTableViewController.swift
//  WSUV_Twitter
//
//  Created by Tyler James Bounds on 3/27/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit
import Alamofire

class TweetTableViewController: UITableViewController {
    
    let kBaseURLString = "https://ezekiel.encs.vancouver.wsu.edu/~cs458/cgi-bin"
    
    
    
    @IBAction func login(_ sender: Any) {
        let manageAccountController = UIAlertController (
            title: "Manage Account",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        manageAccountController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        //---------------------------- REGISTER ------------------------------//
        manageAccountController.addAction(UIAlertAction(
            title: "Register",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                
                let alertController = UIAlertController(title: "Register", message: "Register a WSUV Twitter Account", preferredStyle: .alert)
                
                alertController.addAction(UIKit.UIAlertAction(title: "Register", style: .default, handler: { _ in
                    let usernameTextField = alertController.textFields![0]
                    let passwordTextField = alertController.textFields![1]
                    let rePasswordtextField = alertController.textFields![2]
                    
                    // XXX check for empty textfields, unique username, and passwords match
                    if passwordTextField.text == rePasswordtextField.text {
                        self.registerUser(username: usernameTextField.text!, password: passwordTextField.text!)
                    }
                    else {
                        // XXX ERROR WITH REGISTRATION
                        let registerErrorAlertContoller = UIAlertController(title: "Registration Error", message: nil, preferredStyle: .alert)
                        
                        registerErrorAlertContoller.message = "Passwords do not match."
                        
                        registerErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        
                        self.present(registerErrorAlertContoller, animated: true, completion: nil)
                    }
                    
                    
                    
                }))
                
                alertController.addAction(UIKit.UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addTextField { (textField : UITextField) -> Void in
                    textField.placeholder = "Username"
                }
                
                alertController.addTextField { (textField : UITextField) -> Void in
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Password"
                }
                
                alertController.addTextField { (textField : UITextField) -> Void in
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Re-enter Password"
                }
                
                self.present(alertController, animated: true, completion: nil)
                
        }
        ))
        
        
        //---------------------------- LOGIN ------------------------------//
        manageAccountController.addAction(UIAlertAction(
            title: "Login",
            style: .default,
            handler: { (UIAlertAction) -> Void in
                
                let alertController = UIAlertController(title: "Login", message: "Please Log in", preferredStyle: .alert)
                
                alertController.addAction(UIKit.UIAlertAction(title: "Login", style: .default, handler: { _ in
                    let usernameTextField = alertController.textFields![0]
                    let passwordTextField = alertController.textFields![1]
                    
                    // XXX check for empty textfields
                    if usernameTextField.text != "" && passwordTextField.text != "" {
                        self.loginUser(username: usernameTextField.text!, password: passwordTextField.text!)
                    }
                    //----- ERROR LOGGING IN -----//
                    else{
                        let loginErrorAlertContoller = UIAlertController(title: "Login Error", message: nil, preferredStyle: .alert)
                        
                        loginErrorAlertContoller.message = "Make sure the username and password fields are filled in."
                        
                        loginErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        
                        self.present(loginErrorAlertContoller, animated: true, completion: nil)
                    }
                    
                }))
                
                alertController.addAction(UIKit.UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addTextField { (textField : UITextField) -> Void in
                    textField.placeholder = "Username"
                }
                
                alertController.addTextField { (textField : UITextField) -> Void in
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Password"
                }
                
                self.present(alertController, animated: true, completion: nil)

            }
        ))
        
        manageAccountController.addAction(UIAlertAction(
            title: "Logout",
            style: .default,
            handler: nil
        ))
        
        manageAccountController.addAction(UIAlertAction(
            title: "Reset Passwords",
            style: .default,
            handler: nil
        ))
        
        
        
        self.present(manageAccountController, animated: true, completion: nil)
    }
    
    func loginUser(username: String, password: String) {
        NSLog("\(username)  \(password)")
        SSKeychain.setPassword(password, forService: kWazzuTwitterPassword, account: username)
    }
    
    func registerUser (username: String, password: String) {
        
        let urlString = kBaseURLString + "/register.cgi"
        
        let parameters = [
            "username" : username,  // username and password
            "password" : password,  // obtained from user
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {response in
                switch(response.result) {
                case .success(let JSON):
                    // save username
                    // save password and session_token in keychain
                    // enable "add tweet" button
                // change title of controller to show username, etc...
                    NSLog("Success")
                case .failure(let error):
                    var errMessage = "Unknown Error"
                    switch(response.response!.statusCode) {
                    case 500:
                        errMessage = "Internal server error."
                        break
                    case 400:
                        errMessage = "Make sure to provide both a username and a password."
                        break
                    case 409:
                        errMessage = "Username already exists."
                        break
                    default:
                        break
                    }
                    
                    let registerErrorAlertContoller = UIAlertController(title: "Registration Error", message: nil, preferredStyle: .alert)
                    
                    registerErrorAlertContoller.message = errMessage
                    
                    registerErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    
                    self.present(registerErrorAlertContoller, animated: true, completion: nil)
                    
                } } )
        
    }
    
    lazy var tweetDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    let tweetTitleAttributes = [
        NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline),
        NSForegroundColorAttributeName : UIColor.purple
    ]
    
    lazy var tweetBodyAttributes : [String : AnyObject] = {
        let textStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.lineBreakMode = .byWordWrapping
        textStyle.alignment = .left
        let bodyAttributes = [
            NSFontAttributeName : UIFont.preferredFont(forTextStyle: UIFontTextStyle.body),
            NSForegroundColorAttributeName : UIColor.black,
            NSParagraphStyleAttributeName : textStyle
        ]
        return bodyAttributes
    }()
    
    
    var tweetAttributedStringMap : [Tweet : NSAttributedString] = [:]
    
    func attributedStringForTweet(_ tweet : Tweet) -> NSAttributedString {
        let attributedString = tweetAttributedStringMap[tweet]
        if let string = attributedString { // already stored?
            return string
        }
        let dateString = tweetDateFormatter.string(from: tweet.date as Date)
        let title = String(format: "%@ - %@\n", tweet.username, dateString)
        let tweetAttributedString = NSMutableAttributedString(string: title, attributes: tweetTitleAttributes)
        let bodyAttributedString = NSAttributedString(string: tweet.tweet as String, attributes: tweetBodyAttributes)
        tweetAttributedString.append(bodyAttributedString)
        tweetAttributedStringMap[tweet] = tweetAttributedString
        return tweetAttributedString
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(
            forName: kAddTweetNotification,
            object: nil,
            queue: nil) { (note : Notification) -> Void in
                if !self.refreshControl!.isRefreshing {
                    self.refreshControl!.beginRefreshing()
                    self.refreshTweets(self)
                }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath)
        
        // Configure the cell...
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tweets = appDelegate.tweets[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0 // multi-line label
        cell.textLabel?.attributedText = attributedStringForTweet(tweets)
      
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.tweets.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//        //        else if editingStyle == .insert {
//        //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        //        }
//    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // ----- Refresh Tweets -----//
    @IBAction func refreshTweets(_ sender: AnyObject) {
        
        // ----- Get Tweets -----//
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "PST")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let lastTweetDate = appDelegate.lastTweetDate()
        let dateStr = dateFormatter.string(from: lastTweetDate as Date)
        
        // format date string from latest stored tweet...
        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date" : dateStr])
            .responseJSON {response in
                switch(response.result) {
                case .success(let JSON):
                    let dict = JSON as! [String : AnyObject]
                    let tweets = dict["tweets"] as! [[String : AnyObject]]
                    // ... create a new Tweet object for each returned tweet dictionary
                    var tweetList : [Tweet] = []
                    for entries in tweets {
                    
                        tweetList.append(Tweet(entries["tweet_id"] as! Int, entries["username"] as! String, entries["isdeleted"] as! Bool, entries["tweet"] as! NSString, dateFormatter.date(from: entries["time_stamp"] as! String)! as NSDate))
                    }
                    
                    // ... add new (sorted) tweets to appDelegate.tweets...
                    // Sorting NSDates: http://stackoverflow.com/questions/32205919/sort-array-of-custom-objects-by-date-swift
                    appDelegate.tweets = tweetList.sorted(by: {$0.date.compare($1.date as Date) == ComparisonResult.orderedDescending})
                    
                    
                    self.tableView.reloadData() // force table-view to be updated
                    self.refreshControl?.endRefreshing()
                case .failure(let error):
                    let message : String
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 500:
                            message = "Server error (my bad)"
                            // ...
                        default:
                            break
                        }
                    } else { // probably network or server timeout
                        message = error.localizedDescription
                    }
                    // ... display alert with message ..
                    self.refreshControl?.endRefreshing()
                }
        }
        
        // If successfully fetched new tweets
        //    self.tableView.reloadData(); self.refreshControl?.endRefreshing();
        // If error
        //    display alert with message; self.refreshControl?.endRefreshing();
    }
    
    
    
    
   
}
