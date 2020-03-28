//
//  NaviController.swift
//  LovePet
//
//  Created by Nu-Ri Lee on 2017. 5. 29..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit


class MyPageViewController : UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, URLSessionDelegate, URLSessionTaskDelegate , URLSessionDataDelegate, UISearchBarDelegate {
    
    var get_seq : String = "0";
    
    var myPage : Bool = true;
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var stackProfileView: UIStackView!
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileImge: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var nickNameLabelInfo: UILabel!
    @IBOutlet weak var ratingLabelInfo: UILabel!
    
    @IBOutlet weak var stackNickNameView: UIView!
    
    @IBOutlet weak var logoutView: UIView!
    
    @IBOutlet weak var btnLogout: RoundButton!
    
    @IBOutlet weak var blockSettingView: UIView!
    
    override var shouldAutorotate: Bool{
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            return true;
        }else{
            return true;
        }
    }
    
    //화면 회전 고정
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if UIDevice.current.userInterfaceIdiom == .phone{
            return [UIInterfaceOrientationMask.portrait]
        }else{
            return [UIInterfaceOrientationMask.all]
        }
    }
    
    
    @IBAction func btnLogoutPress(_ sender: Any) {
        
        if ( self.othersPage == true ){ //다른사람 페이지 (로그인상태)
            self.userBlock();
        }else{ //나의 페이지
            logOut();
        }
        
    }
    
    @IBAction func leftBarButtonPress(_ sender: Any) {
        self.dismissView()
    }
    
    func dismissView(){
        
        let noti2 = Notification.init(name : Notification.Name(rawValue: "loginInit"));
        NotificationCenter.default.post(noti2);
        
        let noti3 = Notification.init(name : Notification.Name(rawValue: "statusBarHide"));
        NotificationCenter.default.post(noti3);
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        //status bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            if ( statusBar.alpha != 1.0 )
            {
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                
                                
                                statusBar.alpha = 1.0;
                })
            }
        }//status
        
        
        
        
        loadProfile(user_seq: self.get_seq);
        
        
    }
    
    var othersPage : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        //gesture drag view dismiss
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        self.view.addGestureRecognizer(panGesture);
        
        
        
        //loginSesstion
        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;
        
        if ( String(loginSesseion) != self.get_seq ){ //내 페이지가 아닐때
            self.myPage = false;
            if ( loginSesseion != -1 ){//다른사람 페이지일때
                self.othersPage = true;
                
            }else{ //로그아웃상태
                self.othersPage = false;
            }
        }
        
        
        if ( self.myPage == true )//내 페이지
        {
            let profileViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.profileViewTap(recognizer:)))
            self.profileView.addGestureRecognizer(profileViewTap);
            
            let stackNickNameViewTap = MyTapGestureRecognizer(target: self, action:#selector(self.nickNameViewTap(recognizer:)))
            self.stackNickNameView.addGestureRecognizer(stackNickNameViewTap);
            
            self.blockSettingView.isHidden = false;
            
        }else if ( self.othersPage == true ){ //다른사람 페이지 (로그인상태)
            self.btnLogout.setTitle(NSLocalizedString("user block", comment: "user block"), for: .normal);
        }else{ //로그인상태 X
            self.logoutView.isHidden = true;
        }
        
        
    }
    
    @objc func draggedView(_ recognizer : UIPanGestureRecognizer){
        //let point = recognizer.location(in: view);
        let translation = recognizer.translation(in: view);
        
        //print(translation);
        
        if ( translation.y > 0 ){
            
            self.navigationController?.view.frame.origin.y = translation.y;
            
            //뒷배경 어둡게 하기
            if ( translation.y > 170 ){

                self.navigationController?.view.superview?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)

            }else{
                var percent : CGFloat = 1 - ( translation.y / 1.7 ) / 100;

                if ( percent >= 0.5 ){
                    //percent = 0.5;
                }

                if ( percent >= 0 ){
                    self.navigationController?.view.superview?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: percent)
                }


            }

            
        }
        
        
        
        if ( recognizer.state == .ended ){
            
            if translation.y >= 170{
                
                
                //dismiss view
                self.dismissView();
            }else{
                //return to the original position
                UIView.animate(withDuration: 0.3, animations: {
                    self.navigationController?.view.frame.origin = CGPoint(x: 0, y: 0);
                })
            }
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeNickName" {
            let vc = segue.destination as! ChangeNickNameViewController;
            vc.get_seq = self.get_seq;
            vc.get_nickName = self.nickNameLabel.text!;
        }
        
        if segue.identifier == "showMyPin" {
            let vc = segue.destination as! MyPinViewController;
            vc.user_seq = self.get_seq;
        }
        
        
        
    }
    
    
    
    
    @objc func nickNameViewTap(recognizer : UITapGestureRecognizer){
        
        let point = recognizer.location(in: view);
        
        
        let alertController = UIAlertController();
        
        let  changeNickNameButton = UIAlertAction(title: NSLocalizedString("change nickname", comment: "change nickname"), style: .default , handler: { (action) -> Void in
            //print("Delete button tapped")
            
            
            self.performSegue(withIdentifier: "changeNickName", sender: self);
            
        })
        
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        
        //alertController.title = "Open in another map";
        alertController.addAction(changeNickNameButton)
        alertController.addAction(cancelButton)
        
        //ipad 일때 위치 잡아주기
        if let popoverPresentationController = alertController.popoverPresentationController {
            
            //let globalPoint = self.mapView.superview?.convert(self.mapView.frame.origin, to: self.view)
            let globalPoint = point;
            let commentTextViewRect = CGRect(x: (globalPoint.x) , y: (globalPoint.y)  , width: 1, height: 1);
            
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = commentTextViewRect;
            //popoverPresentationController.permittedArrowDirections = .down
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func profileViewTap(recognizer : UITapGestureRecognizer){
        
        let point = recognizer.location(in: view);
        
        
        let alertController = UIAlertController();
        
        let  changeProfileButton = UIAlertAction(title: NSLocalizedString("change profile image", comment: "change profile image"), style: .default , handler: { (action) -> Void in
            //print("Delete button tapped")
            
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            myPickerController.allowsEditing = false;
            self.present(myPickerController, animated: true, completion: nil)
            
            
        })
        
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        
        //alertController.title = "Open in another map";
        alertController.addAction(changeProfileButton)
        alertController.addAction(cancelButton)
        
        //ipad 일때 위치 잡아주기
        if let popoverPresentationController = alertController.popoverPresentationController {
            
            //let globalPoint = self.mapView.superview?.convert(self.mapView.frame.origin, to: self.view)
            let globalPoint = point;
            let commentTextViewRect = CGRect(x: (globalPoint.x) , y: (globalPoint.y)  , width: 1, height: 1);
            
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = commentTextViewRect;
            //popoverPresentationController.permittedArrowDirections = .down
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    //이미지 피커
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        self.tempImageView.image = image
        self.myImageUploadRequest(image : self.tempImageView.image!)
        self.dismissView();
        
        
    }
    
    
    //이미지 업로드
    func myImageUploadRequest(image : UIImage)
    {
        
        
        let myUrl = NSURL(string: AppDelegate.serverUrl + "/chulsago/upload_img_profile.php");

        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginSesseion = UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1;

        let key : String = "nuri";
        let user_seq : String = String(loginSesseion);
        

        let param = [
            "key"   : key,
            "user_seq" : user_seq
        ]

        let boundary = generateBoundaryString()

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")


        let imageData = UIImageJPEGRepresentation(image, 1)

        if(imageData==nil)  { return; }

        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data

        //        myActivityIndicator.isHidden = false;
        //        myActivityIndicator.startAnimating();
        //        uploadPregressView.progress = 0;
        //        uploadLabel.text = "0 %";


        var session:URLSession?
        let configuration = URLSessionConfiguration.default
        let manqueue = OperationQueue.main
        session = URLSession(configuration: configuration, delegate:self, delegateQueue: manqueue)


        let task = session?.dataTask(with: request as URLRequest ){
            //let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in

            if error != nil {
                print("error=\(String(describing: error))")
                return
            }

            // You can print out response object
            //print("******* response = \(String(describing: response!))")



            let json : Any?

            do{
                json = try JSONSerialization.jsonObject(with: data!, options: [])

                //성공
                if let array = json as? [[String:Any]] {
                    for result in array{

                        print("****** response data = ");
                        print(result["seq"]!)
                        print(result["body"]!)
                        print(result["status"]!)
                    }


                    //성공시
                    
                    DispatchQueue.main.async() {
                        self.loadProfile(user_seq: self.get_seq);
                    }

                }


                // Print out reponse body
                //                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                //                print("****** response data = \(responseString!)")

            }catch{
                //print("Error: \(error)")
                //print(String(data: data!, encoding: .utf8)!);

                let array: [[String: Any]] = [
                    ["error": String(data: data!, encoding: .utf8)!]
                ]
                print(array[0]["error"]!)
                let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: array[0]["error"]!))", preferredStyle: .alert)

                let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                })

                alertController.addAction(okButton)


                self.present(alertController, animated: true, completion: nil)

            }





        }

        task?.resume()
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    
    
    
    
    func userBlock(){
        let alertController = UIAlertController();
        
        let  userBlockButton = UIAlertAction(title: NSLocalizedString("user block", comment: "user block"), style: .destructive, handler: { (action) -> Void in
            //print("Delete button tapped")
            print("사용자 차단");
            
            
            let key : String = "nuri";
            let user_seq : String = String(UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1);
            let block_user_seq : String = self.get_seq;
            
            
            
            let param : String = "key="+key+"&user_seq="+user_seq+"&block_user_seq="+block_user_seq;
            
            Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/user_block.php", withParam: param) { (results:[[String:Any]]) in
                
                for result in results{
                    if (result["error"] != nil){
                        //에러발생시
                        print(result["error"] ?? "error")
                        DispatchQueue.main.async() {
                            let alertController = UIAlertController(title: NSLocalizedString("waiting", comment: "waiting"), message: "\(String(describing: result["error"]!))", preferredStyle: .alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                            })
                            
                            alertController.addAction(okButton)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    }else{
                        DispatchQueue.main.async() {
                            let alertController = UIAlertController(title: NSLocalizedString("success", comment: "success"), message: NSLocalizedString("user block success", comment: "user block success"), preferredStyle: .alert)
                            
                            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
                                
                                let noti3 = Notification.init(name : Notification.Name(rawValue: "statusBarHide"));
                                NotificationCenter.default.post(noti3);
                                self.presentingViewController?.dismiss(animated: true);
                            })
                            
                            alertController.addAction(okButton)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    }
                }
            }//ajax
            
            
            
            //self.presentingViewController?.dismiss(animated: true);
            
            
            
        })
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        alertController.addAction(userBlockButton)
        alertController.addAction(cancelButton)
        
        //ipad 일때 위치 잡아주기
        if let popoverPresentationController = alertController.popoverPresentationController {
            
            let globalPoint = logoutView.superview?.convert(logoutView.frame.origin, to: self.view)
            let logoutViewRect = CGRect(x: (globalPoint?.x)! + (self.logoutView.frame.size.width/2) , y: (globalPoint?.y)! - 10 , width: 1, height: 1);
            
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = logoutViewRect;
            popoverPresentationController.permittedArrowDirections = .down
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //custom function
    func logOut(){
        
        
        
        
        let alertController = UIAlertController();
        
        let  logoutButton = UIAlertAction(title: "Logout", style: .destructive, handler: { (action) -> Void in
            //print("Delete button tapped")
            
            UserDefaults.standard.set(-1, forKey: "loginSesstion");
            //infoLikeReload
            let noti = Notification.init(name : Notification.Name(rawValue: "infoLikeReload"));
            NotificationCenter.default.post(noti);
            
            let noti2 = Notification.init(name : Notification.Name(rawValue: "loginInit"));
            NotificationCenter.default.post(noti2);
            
            let noti3 = Notification.init(name : Notification.Name(rawValue: "statusBarHide"));
            NotificationCenter.default.post(noti3);
            
            self.presentingViewController?.dismiss(animated: true);
            
            
            //네비게이션 뒤로가기
            //self.navigationController?.popViewController(animated: true)
            
            
            //ipad 일때
            if alertController.popoverPresentationController != nil {
                //print("RB");
            }
            
            
        })
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        alertController.addAction(logoutButton)
        alertController.addAction(cancelButton)
        
        //ipad 일때 위치 잡아주기
        if let popoverPresentationController = alertController.popoverPresentationController {
            
            let globalPoint = logoutView.superview?.convert(logoutView.frame.origin, to: self.view)
            let logoutViewRect = CGRect(x: (globalPoint?.x)! + (self.logoutView.frame.size.width/2) , y: (globalPoint?.y)! - 10 , width: 1, height: 1);
            
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = logoutViewRect;
            popoverPresentationController.permittedArrowDirections = .down
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    
    func loadProfile(user_seq : String){
        
        
        let param : String = "key=nuri&seq=" + user_seq;
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/user_select.php", withParam: param) { (results:[[String:Any]]) in
            
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
                    //let seq : String = (result["seq"] as? String)!;
                    let name : String = (result["name"] as? String)!;
                    let point : String = (result["point"] as? String)!;
                    let thumbnail_image : String = (result["thumbnail_image"] as? String)!;
                    
                    let point2 : Int = Int(point)!;
                    
                    //레이아웃 바꿀때 충돌 방지
                    DispatchQueue.main.async() {
                        
                        //프로필 사진 추가
                        if thumbnail_image != ""{
                            self.profileImge.contentMode = UIViewContentMode.scaleAspectFill
                            self.profileImge.downloadAndResizeImageFrom(thumbnail_image, contentMode: .scaleAspectFill, newWidth: 400)
                        }else{
                            self.profileImge.contentMode = UIViewContentMode.center
                            self.profileImge.image = UIImage(named: "nonProfile");
                        }
                        
                        //프로필 텍스트 추가
                        if name != ""{
                            let profileText = name;
                            self.nickNameLabel.text = profileText;
                            self.navigationItem.title = profileText;
                        }else{
                            let profileText = "NULL";
                            self.nickNameLabel.text = profileText;
                            self.navigationItem.title = profileText;
                        }
                        
                        
                        
                        //등급 가져오기
                        let rating: String = RatingClass.rating(point: point2) + " (P. " + String(point2) + ")";
                        self.ratingLabel.text = rating;
                        
                        
                    }
                    
                    
                }
            }
        }//ajax
        
        
    }
    
    
    
    
    
    // urlSesstion
    
    // urlSesstion Error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        let myAlert = UIAlertView(title: "Alert", message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "Ok")
        myAlert.show()
    }
    
    
    // urlSesstion Error
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    {
        
        //print("didSendBodyData")
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
       // uploadPregressView.progress = uploadProgress
        //let progressPercent = Int(uploadProgress*100)
        //uploadPregressLabel.text = String(progressPercent) + " %";
        //print(uploadProgress)
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceiveResponse")
        print(response);
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceiveData")
    }
    
    
    
    
    
}


