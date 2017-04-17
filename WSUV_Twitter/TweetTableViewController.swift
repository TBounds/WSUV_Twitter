//
//  TweetTableViewController.swift
//  WSUV_Twitter
//
//  Created by Tyler James Bounds on 3/27/17.
//  Copyright © 2017 Tyler James Bounds. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator

class TweetTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var addTweetButton: UIBarButtonItem!
    @IBOutlet weak var tweetTableView: UINavigationItem!
    @IBOutlet weak var manageAccountButton: UIBarButtonItem!
    
    @IBAction func manageAccount(_ sender: Any) {
    
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
        if self.appDelegate.username == "" {
            manageAccountController.addAction(UIAlertAction(
                title: "Register",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    
                    let alertController = UIAlertController(title: "Register", message: "Register a WSUV Twitter Account", preferredStyle: .alert)
                    
                    alertController.addAction(UIKit.UIAlertAction(title: "Register", style: .default, handler: { _ in
                        let usernameTextField = alertController.textFields![0]
                        let passwordTextField = alertController.textFields![1]
                        let rePasswordtextField = alertController.textFields![2]
                        
                        // Make sure passwords match. Server checks for other errors.
                        if passwordTextField.text == rePasswordtextField.text {
                            self.registerUser(username: usernameTextField.text!, password: passwordTextField.text!)
                        }
                        else {
                            // Passwords don't match, report to user.
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
        }
        
        //---------------------------- LOGIN ------------------------------//
        if self.appDelegate.username == "" {
            manageAccountController.addAction(UIAlertAction(
                title: "Login",
                style: .default,
                handler: { (UIAlertAction) -> Void in
                    
                    let alertController = UIAlertController(title: "Login", message: "Please Log in", preferredStyle: .alert)
                    
                    alertController.addAction(UIKit.UIAlertAction(title: "Login", style: .default, handler: { _ in
                        let usernameTextField = alertController.textFields![0]
                        let passwordTextField = alertController.textFields![1]
                        
                        //----- ATTEMPT TO LOGIN -----//
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
        }
        
        
        //---------------------------- LOGOUT ------------------------------//
        if appDelegate.username != "" {
            manageAccountController.addAction(UIAlertAction(
                title: "Logout",
                style: .default,
                handler: { (UIAlertController) -> Void in
                    let user = self.appDelegate.username
                    let pass = SAMKeychain.password(forService: kWazzuTwitterPassword, account: self.appDelegate.username)
                    
                    self.logout(username: user, password: pass!)
            }
            ))
        }
        
        
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            
            manageAccountController.popoverPresentationController?.barButtonItem = manageAccountButton
            
//            let popoverPresenter = manageAccountController.popoverPresentationController
//            let menuButtonTag = 12
//            let menuButton = tweetTableView.viewWithTag(menuButtonTag)
//            popoverPresenter?.sourceView = menuButton
//            popoverPresenter?.sourceRect = (menuButton?.bounds)!
        }
        
        self.present(manageAccountController, animated: true, completion: nil)
        
    }
    
    //----- LOGIN FUNCTION -----//
    func loginUser(username: String, password: String) {
        
        let urlString = kBaseURLString + "/login.cgi"
        
        let parameters = [
            "username" : username,  // username and password
            "password" : password,  // obtained from user
            "action" : "login"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {response in
                switch(response.result) {
                case .success(let JSON):
                    
                    let dict = JSON as! [String : AnyObject]
                    
                    // save username
                    self.appDelegate.username = username
                    
                    // save session_token and password in keychain
                    SAMKeychain.setPassword(password, forService: kWazzuTwitterPassword, account: username)
                    SAMKeychain.setPassword(dict["session_token"] as! String, forService: kWazzuTwitterSessionToken, account: username)
                    
                    
                    // enable "add tweet" button
                    self.addTweetButton.isEnabled = true
                    
                    // change title of controller to show username, etc...
                    self.title = username
                    
                case .failure(let error):
                    NSLog("\(error)")
                    
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
                    case 404:
                        errMessage = "Username does not exist."
                        break
                    case 401:
                        errMessage = "Password is incorrect"
                        break
                    default:
                        errMessage = "Error code: \(response.response!.statusCode)"
                        break
                    }
                    
                    let loginErrorAlertContoller = UIAlertController(title: "Login Error", message: nil, preferredStyle: .alert)
                    
                    loginErrorAlertContoller.message = errMessage
                    
                    loginErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    
                    self.present(loginErrorAlertContoller, animated: true, completion: nil)
                    
                } } )
        
    }
    
    //----- LOGOUT FUNCTION -----//
    func logout(username: String, password: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let urlString = kBaseURLString + "/login.cgi"
        
        let parameters = [
            "username" : username,  // username and password
            "password" : password,  // obtained from user
            "action" : "logout"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters)
            .responseJSON(completionHandler: {response in
                switch(response.result) {
                case .success(let JSON):
                    
                    let dict = JSON as! [String : AnyObject]
                    
                    // remove username
                    appDelegate.username = ""
                    
                    // save session_token in keychain
                    SAMKeychain.setPassword(dict["session_token"] as! String, forService: kWazzuTwitterSessionToken, account: username)
                    
                    // disable "add tweet" button
                    self.addTweetButton.isEnabled = false
                    
                    // change title of controller to show username, etc...
                    self.title = "Recent Tweets"
                    
                case .failure(let error):
                    NSLog("\(error)")
                    
                    // Check what kind of error is received.
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
                    case 404:
                        errMessage = "Username does not exist."
                        break
                    case 401:
                        errMessage = "Password is incorrect"
                        break
                    default:
                        errMessage = "Error code: \(response.response!.statusCode)"
                        break
                    }
                    
                    // Present error to user.
                    let loginErrorAlertContoller = UIAlertController(title: "Login Error", message: nil, preferredStyle: .alert)
                    
                    loginErrorAlertContoller.message = errMessage
                    
                    loginErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    
                    self.present(loginErrorAlertContoller, animated: true, completion: nil)
                    
                } } )
        
    }
    
    //----- REGISTER USER FUNC -----//
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
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let dict = JSON as! [String : AnyObject]
                    
                    // save username
                    appDelegate.username = username
                    
                    // save password and session_token in keychain
                    SAMKeychain.setPassword(password, forService: kWazzuTwitterPassword, account: username)
                    SAMKeychain.setPassword(dict["session_token"] as! String, forService: kWazzuTwitterSessionToken, account: username)
                    
                    // enable "add tweet" button
                    self.addTweetButton.isEnabled = true
                    
                    // change title of controller to show username, etc...
                    self.title = username
                    
                case .failure(let error):
                    NSLog("\(error)")
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
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        if appDelegate.fetchTweets {
            NotificationCenter.default.post(name: kAddTweetNotification, object: nil)
            
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
    
    
    //----- DELETING TWEETS -----//
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if appDelegate.username != "" {
            if editingStyle == .delete {
                // Delete the row from the data source
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                //appDelegate.tweets.remove(at: indexPath.row)
                //tableView.deleteRows(at: [indexPath], with: .fade)
                
                let urlString = kBaseURLString + "/del-tweet.cgi"
                
                let username = self.appDelegate.username as String
                let session_token = SAMKeychain.password(forService: kWazzuTwitterSessionToken, account: username)
                let tweet_id = appDelegate.tweets[indexPath.row].tweet_id
                
                let parameters = [
                    "username" : username,  // username and password
                    "session_token" : session_token!,  // obtained from user
                    "tweet_id" : tweet_id,
                    ] as [String : Any]
                
                Alamofire.request(urlString, method: .post, parameters: parameters)
                    .responseJSON {response in
                        switch(response.result) {
                        case .success(let JSON):
                            NSLog("\(JSON)")
                            appDelegate.tweets.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        case .failure(let error):
                            NSLog("\(error)")
                            var errMessage = "Unknown Error"
                            switch(response.response!.statusCode) {
                            case 500:
                                errMessage = "Internal server error."
                                break
                            case 400:
                                errMessage = "Bad reqeust. All parameters not provided."
                                break
                            case 404:
                                errMessage = "No such user or tweet."
                                break
                            case 401:
                                errMessage = "Unauthorized."
                                break
                            case 403:
                                errMessage = "This is not your tweet to delete."
                                break
                            default:
                                errMessage = "Error code: \(response.response!.statusCode)"
                                break
                            }
                            
                            let deleteErrorAlertContoller = UIAlertController(title: "Delete Error", message: nil, preferredStyle: .alert)
                            
                            deleteErrorAlertContoller.message = errMessage
                            
                            deleteErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                            
                            self.present(deleteErrorAlertContoller, animated: true, completion: nil)
                        }
                }
            }
        }
        else {
            let deleteErrorAlertContoller = UIAlertController(title: "Delete Error", message: nil, preferredStyle: .alert)
            
            deleteErrorAlertContoller.message = "You must be logged in to delete your tweets."
            
            deleteErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            
            self.present(deleteErrorAlertContoller, animated: true, completion: nil)
        }
    }
    
    
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

        Alamofire.request(kBaseURLString + "/get-tweets.cgi", method: .get, parameters: ["date" : dateStr])
            .responseJSON {response in
                switch(response.result) {
                case .success(let JSON):
                    let dict = JSON as! [String : AnyObject]
                    let tweets = dict["tweets"] as! [[String : AnyObject]]
                    // ... create a new Tweet object for each returned tweet dictionary
                    var tweetList : [Tweet] = []
                    for entries in tweets {
                        if !(entries["isdeleted"] as! Bool){
                            tweetList.append(Tweet(entries["tweet_id"] as! Int, entries["username"] as! String, entries["isdeleted"] as! Bool, entries["tweet"] as! NSString, dateFormatter.date(from: entries["time_stamp"] as! String)! as NSDate))
                        }
                        
                    }
                    
                    // ... add new (sorted) tweets to appDelegate.tweets...
                    // Sorting NSDates: http://stackoverflow.com/questions/32205919/sort-array-of-custom-objects-by-date-swift
                    appDelegate.tweets = tweetList.sorted(by: {$0.date.compare($1.date as Date) == ComparisonResult.orderedDescending})
                    
                    
                    self.tableView.reloadData() // force table-view to be updated
                    self.refreshControl?.endRefreshing()
                case .failure(let error):
                    var message : String = "Unknown error"
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 500:
                            message = "Server error (my bad)"
                            break
                        case 503:
                            message = "Unable to connect to internal database."
                            break
                        default:
                            break
                        }
                    } else { // probably network or server timeout
                        message = error.localizedDescription
                    }
                    // ... display alert with message ..
                    
                    let fetchErrorAlertContoller = UIAlertController(title: "Fetch Error", message: nil, preferredStyle: .alert)
                    
                    fetchErrorAlertContoller.message = message
                    
                    fetchErrorAlertContoller.addAction(UIKit.UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    
                    self.present(fetchErrorAlertContoller, animated: true, completion: nil)
                    
                    self.refreshControl?.endRefreshing()
                }
        }
        
        // If successfully fetched new tweets
        //    self.tableView.reloadData(); self.refreshControl?.endRefreshing();
        // If error
        //    display alert with message; self.refreshControl?.endRefreshing();
    }
    
    
    
    
   
}
