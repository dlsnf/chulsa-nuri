//
//  LoginViewController.swift
//  LovePet
//
//  Created by Nu-Ri Lee on 2017. 6. 4..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class SignUpViewController : UIViewController, UITextFieldDelegate {
    
    //handle text field
    weak var handleTextFieldDelegate : HandleTextField?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    @IBOutlet var textFieldPasswordHeightConstraint: NSLayoutConstraint!
    var signUpStep : Int = 0;
    
    @IBOutlet weak var btnNext: UIButton!
    
    @IBAction func btnNextPress(_ sender: Any) {
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
        
        if ( signUpStep == 0 )
        {
            if (email == "")
            {
                let alertController = UIAlertController(title: NSLocalizedString("fail sign up", comment: "fail sign up"), message: NSLocalizedString("input email", comment: "input email"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                    self.textFieldEmail.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
                
                
            }else if ( emailCheck == false ){
                //이메일 체크
                let alertController = UIAlertController(title: NSLocalizedString("fail sign up", comment: "fail sign up"), message: NSLocalizedString("not email type", comment: "not email type"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    self.textFieldEmail.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }else{
                self.signUpStep = 1;
                DispatchQueue.main.async() {
                    self.labelInfo.text = NSLocalizedString("input password", comment: "input password");
                    self.btnNext.setTitle(NSLocalizedString("comfirm", comment: "comfirm"),for: .normal)
                    self.btnNext.isEnabled = false;
                }
                self.textFieldPasswordHeightConstraint.constant = 60;
                self.scrollView.scrollToTop_custom(toppx:80 ,animated: true);

                self.textFieldPassword.becomeFirstResponder();
                
                UIView.animate(withDuration: 0.3,delay: 0 ,usingSpringWithDamping:0.8,
                               initialSpringVelocity:0, options: .curveEaseInOut, animations: {
                                self.view.layoutIfNeeded()


                }, completion: { (finished) -> Void in
                    self.btnNext.isEnabled = true;

                })
            }
        }else if( signUpStep == 1){
            if (email == "")
            {
                let alertController = UIAlertController(title: NSLocalizedString("fail sign up", comment: "fail sign up"), message: NSLocalizedString("input email", comment: "input email"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                    DispatchQueue.main.async() {
                        self.labelInfo.text = NSLocalizedString("input email", comment: "input email");
                    }
                    self.textFieldEmail.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
                
                
            }else if ( emailCheck == false ){
                //이메일 체크
                let alertController = UIAlertController(title: NSLocalizedString("fail sign up", comment: "fail sign up"), message: NSLocalizedString("not email type", comment: "not email type"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                    DispatchQueue.main.async() {
                        self.labelInfo.text = NSLocalizedString("input email", comment: "input email");
                    }
                    self.textFieldEmail.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }else if (password == "")
            {
                let alertController = UIAlertController(title: NSLocalizedString("fail sign up", comment: "fail sign up"), message: NSLocalizedString("input password", comment: "input password"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                    DispatchQueue.main.async() {
                        self.labelInfo.text = NSLocalizedString("input password", comment: "input password");
                    }
                    self.textFieldPassword.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }else if (password.count < 8)
            {
                let alertController = UIAlertController(title: NSLocalizedString("fail sign up", comment: "fail sign up"), message: NSLocalizedString("input password eight length", comment: "input password eight length"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                    self.textFieldPassword.becomeFirstResponder();
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }else{
                self.navigationController?.navigationBar.isUserInteractionEnabled = false;
                self.btnNext.isEnabled = false;
                
                //print(password);
                var pwCode : String = password;
                let clearData = pwCode.data(using:String.Encoding.utf8)!
                let hash = hashSHA256(data:clearData)
                pwCode = hash!.map { String(format: "%02hhx", $0) }.joined();
                //print("hash: "+pwCode)
                
                
                let key : String = "nuri";
                let type : String = "app";
                let param : String = "key="+key+"&email="+email+"&password="+password+"&type="+type;
                
                self.view.endEditing(true);
                self.scrollView.contentInset.bottom = 0
                self.scrollView.scrollIndicatorInsets.bottom = 0
                self.key_check = false;
                
                DispatchQueue.main.async() {
                    Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/sign_up.php", withParam: param) { (results:[[String:Any]]) in

                        for result in results{
                            if (result["error"] != nil){
                                //에러발생시
                                print(result["error"] ?? "error")
                                DispatchQueue.main.async() {
                                    self.navigationController?.navigationBar.isUserInteractionEnabled = true;
                                    self.btnNext.isEnabled = true;
                                }
                                let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                })
                                alertController.addAction(okButton)
                                self.present(alertController, animated: true, completion: nil)
                            }else{
//                                print(result["seq"]!)
//                                //let seq : String = String(describing: result["seq"]!)
//                                print("ajax 성공");
                                self.navigationController?.navigationBar.isUserInteractionEnabled = true;
                                let alertController = UIAlertController(title: NSLocalizedString("sign up", comment: "sign up"), message: NSLocalizedString("success", comment: "success"), preferredStyle: .alert)
                                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                    self.navigationController?.popToRootViewController(animated: true);
                                })
                                alertController.addAction(okButton)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }

                    }//Ajax
                    
                }//async
                
            }
            
        }//step = 1

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print(textField.tag);

        self.view.endEditing(true);

        self.scrollView.contentInset.bottom = 0
        self.scrollView.scrollIndicatorInsets.bottom = 0
        self.key_check = false;
        
        return(true);
    }
    
    func loginCheck(){
        let email = textFieldEmail.text!;
        let password = textFieldPassword.text!;


        if (email == "")
        {
            let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("input email", comment: "input email"), preferredStyle: .alert)
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                //self.textFieldEmail.becomeFirstResponder();
            })
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)


        }else if (password == "")
        {
            let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("input password", comment: "input password"), preferredStyle: .alert)
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .default, handler: { (action) -> Void in
                //self.textFieldPassword.becomeFirstResponder();
            })
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        }else{
            //이메일 체크
            let check = isValid(email);
            print("DD");
            if(check){

            }else{
                let alertController = UIAlertController(title: NSLocalizedString("fail login", comment: "fail login"), message: NSLocalizedString("not email type", comment: "not email type"), preferredStyle: .alert)
                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                })
                alertController.addAction(okButton)
                self.present(alertController, animated: true, completion: nil)
            }


        }
    }
    
    //이메일 체크
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.textFieldEmail.delegate = self;
        self.textFieldPassword.delegate = self;
        
        

        let viewTap = UITapGestureRecognizer(target: self, action:#selector(self.viewTap))
        scrollView.addGestureRecognizer(viewTap)
        
        self.textFieldEmail.becomeFirstResponder();

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        addObservers();
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers();
        
    }
    
    
    //MARK: - my function
    
    
    func hashSHA256(data:Data) -> Data? {
        var hashData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
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




