//
//  LoginViewController.swift
//  LovePet
//
//  Created by Nu-Ri Lee on 2017. 6. 4..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

//handle login
protocol HandleTextField: class {
    func focusTextField();
}


class LoginViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print(textField.tag);
        
        let email = textFieldEmail.text!;
        
        if (textField.tag == 0){
            let check = isValid(email);
            if (email == "")
            {
                let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("input email", comment: "input email"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                    self.textFieldEmail.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
                
            }else if check {
                self.textFieldPassword.becomeFirstResponder()
            }else{
                let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("not email type", comment: "not email type"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    self.textFieldEmail.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }
        }else if (textField.tag == 1){
            loginCheck();
        }
        
//        self.view.endEditing(true);
//
//        self.scrollView.contentInset.bottom = 0
//        self.scrollView.scrollIndicatorInsets.bottom = 0
//        self.key_check = false;
        return(true);
    }
    
    @IBAction func btnLoginAction(_ sender: Any) {
        loginCheck();
    }
    
    
    func loginCheck(){
        var email : String = textFieldEmail.text!;
        email = email.stringTrim();
        textFieldEmail.text = email;
        var password : String = textFieldPassword.text!;
        password = password.stringTrim();
        textFieldPassword.text = password;
        
        
        var emailCheck : Bool = false;
        if (email != "")
        {
            emailCheck = isValid(email);
        }
        
        
        if (email == "")
        {
            let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("input email", comment: "input email"), preferredStyle: .alert)
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                self.textFieldEmail.becomeFirstResponder();
            })
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
            
            
        }else if ( emailCheck == false ){
            //이메일 체크
            let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("not email type", comment: "not email type"), preferredStyle: .alert)
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                self.textFieldEmail.becomeFirstResponder();
            })
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        
            
        }else if (password == "")
        {
            let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("input password", comment: "input password"), preferredStyle: .alert)
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                self.textFieldPassword.becomeFirstResponder();
            })
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        }else{
            
            
            let key : String = "nuri";
            let type : String = "app";
            let param : String = "key="+key+"&email="+email+"&password="+password+"&type="+type;
            self.view.endEditing(true);
            self.scrollView.contentInset.bottom = 0
            self.scrollView.scrollIndicatorInsets.bottom = 0
            self.key_check = false;
            
            //로그인 시도
            DispatchQueue.main.async() {
                
                Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/login.php", withParam: param) { (results:[[String:Any]]) in

                    for result in results{
                        if (result["error"] != nil){
                            //에러발생시
                            print(result["error"] ?? "error")
                            let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                            })
                            alertController.addAction(okButton)
                            self.present(alertController, animated: true, completion: nil)
                        }else{
                            //print(result["seq"]!)
                            let userSeq = Int(String(describing: result["seq"]!))
                            UserDefaults.standard.set(userSeq!, forKey: "loginSesstion");
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                
                                //로그인 초기화
                                let noti = Notification.init(name : Notification.Name(rawValue: "loginInit"));
                                NotificationCenter.default.post(noti);
                                
                                //infoLikeReload
                                let noti2 = Notification.init(name : Notification.Name(rawValue: "infoLikeReload"));
                                NotificationCenter.default.post(noti2);
                                
                                
                                //addPin에서 로그인페이지로 이동 되었을때 바로 addPin 페이지로 이동
                                let loginToAddPin = UserDefaults.standard.object(forKey: "loginToAddPin") as? Bool ?? false;
                                
                                if loginToAddPin {
                                    let noti2 = Notification.init(name : Notification.Name(rawValue: "loginToAddPin"));
                                    NotificationCenter.default.post(noti2);
                                }
                                
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.presentingViewController?.dismiss(animated: true)
                            }
                        }
                    }

                }//Ajax

            }//async
        }
        
        
    }
    
    //이메일 체크
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
    
    func getKaKaoValue(){
        KOSessionTask.meTask(completionHandler: { (profile, error) in
            if profile != nil{
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let kakao : KOUser = profile as! KOUser
                    
                    let email : String = kakao.email!;
                    let type : String = "kakao";
                    let id : String = String(describing: kakao.id!);
                    var name : String!;
                    var profile_image : String!;
                    var thumbnail_image : String!;
                    
                    
                    if let value = kakao.properties?["nickname"] as? String{
                        //print("nickname : \(value)\r\n")
                        name = value;
                    }
                    if let value = kakao.properties?["profile_image"] as? String{
                        //self.imageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: value)!)!)
                        //print("profile_image : \(value)\r\n")
                        profile_image = value
                    }
                    if let value = kakao.properties?["thumbnail_image"] as? String{
                        //self.image2View.image = UIImage(data: NSData(contentsOfURL: NSURL(string: value)!)!)
                        //print("thumbnail_image : \(value)\r\n")
                        thumbnail_image = value;
                    }
                    
                    
                    
                    let param : String = "key=nuri&email="+email+"&name="+name+"&type="+type+"&id="+id+"&profile_image="+profile_image+"&thumbnail_image="+thumbnail_image;
                    
                    
                    Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/login.php", withParam: param) { (results:[[String:Any]]) in
                        
                        for result in results{
                            if (result["error"] != nil){
                                //에러발생시
                                print(result["error"] ?? "error")
                                let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                                
                                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                })
                                
                                alertController.addAction(okButton)
                                
                                
                                self.present(alertController, animated: true, completion: nil)
                            }else{
                                //print(result["seq"]!)
                                let userSeq = Int(String(describing: result["seq"]!))
                                UserDefaults.standard.set(userSeq!, forKey: "loginSesstion");
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    
                                    //로그인 초기화
                                    let noti = Notification.init(name : Notification.Name(rawValue: "loginInit"));
                                    NotificationCenter.default.post(noti);
                                    
                                    //infoLikeReload
                                    let noti2 = Notification.init(name : Notification.Name(rawValue: "infoLikeReload"));
                                    NotificationCenter.default.post(noti2);
                                    
                                    
                                    //addPin에서 로그인페이지로 이동 되었을때 바로 addPin 페이지로 이동
                                    let loginToAddPin = UserDefaults.standard.object(forKey: "loginToAddPin") as? Bool ?? false;
                                    
                                    if loginToAddPin {
                                        let noti2 = Notification.init(name : Notification.Name(rawValue: "loginToAddPin"));
                                        NotificationCenter.default.post(noti2);
                                    }
                                    
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.presentingViewController?.dismiss(animated: true)
                                }
                            }
                        }
                    }
                    
                    
                })
            }
        })
    }
    
    
    
    func kakaoLoginStart(){
        
        //print("왜 안돼");
        
    }
    
    @IBAction func kakaoLogin(_ sender: UIButton) {
        
        //go EULA
        
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.alpha = 1.0;
        
        
        
        
        
        self.textFieldEmail.delegate = self;
        self.textFieldPassword.delegate = self;
        
        
        
        let viewTap = UITapGestureRecognizer(target: self, action:#selector(self.viewTap))
        scrollView.addGestureRecognizer(viewTap)
        
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        addObservers();
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers();
        
    }
    
    
    
    
    @objc func viewTap(){
        //self.view.endEditing(true);
        self.view.endEditing(true);
        
        self.scrollView.contentInset.bottom = 0
        self.scrollView.scrollIndicatorInsets.bottom = 0
        self.key_check = false;
        
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func removeObservers()
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    //키보드 스크롤뷰 새로운 방법
    var key_check:Bool = false;
    
    @objc func keyboardWillShow(_ notification: Notification){
        if key_check == false{
            adjustingHeight(true, notification: notification as Notification)
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {

        if key_check == true{
            adjustingHeight(false, notification: notification as Notification)
            //self.view.endEditing(true);
        }
    }
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//
//
//            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
//
//            if show{
//                scrollView.contentInset = contentInset;
//                print("킴");
//                key_check = true;
//            }else{
//                scrollView.contentInset = UIEdgeInsets.zero;
//                print("끔");
//                key_check = false;
//            }
//        }
//
        var keyboardHeight:CGFloat = 0;

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            keyboardHeight = keyboardSize.height;
            //print(keyboardHeight);
        }
        
        
        if show{
            //self.editTextView.frame.origin.y -= changeInHeight;
            //self.editTextBottomSpace.constant = changeInHeight;
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.view.layoutIfNeeded()
            })
            
            
            
            
            self.scrollView.contentInset.bottom += keyboardHeight
            self.scrollView.scrollIndicatorInsets.bottom += keyboardHeight
            self.key_check = true;
            
        }else{
            
            //self.editTextView.frame.origin.y += changeInHeight;
            //self.editTextBottomSpace.constant = 0;
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.view.layoutIfNeeded()
            })
            
            self.scrollView.contentInset.bottom = 0
            self.scrollView.scrollIndicatorInsets.bottom = 0
            self.key_check = false;
            
        }
        
        
        
        
    }
    
    
    
    
}



class ConnectionCheck {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}



//search map
extension LoginViewController: HandleTextField {
    
    func focusTextField() {
        print("뀨");
    }
    
}


