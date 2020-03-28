//
//  EulaViewController.swift
//  ChulsaGo
//
//  Created by nuri Lee on 2017. 12. 18..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import SystemConfiguration

class EulaViewController : UIViewController{
    
    
    @IBAction func btnEulaPress(_ sender: UIBarButtonItem) {
        
        
        let session = KOSession.shared()
        
        //로그인 세션이 생성 되었으면
        if let s = session {
            // 이전 열린 세션은 닫고
            if s.isOpen() {
                s.close()
            }
            
            s.open(completionHandler: { (error) in
                
                // 에러가 없으면
                if error == nil {
                    //print("No error")
                    // 로그인 성공
                    if s.isOpen() {
                        //print("Success")
                        //print(s.accessToken);
                        self.getKaKaoValue()
                        
                        
                    }
                        // 로그인 실패
                    else{
                        print("Fail")
                    }
                }else{
                    // 로그인 에러
                    print("Error login: \(error!)")
                }
            })
            
        }else{
            print("Something wrong")
        }
        
        //self.navigationController?.popViewController(animated: true);
        
        
        
    }
    
    
    func getKaKaoValue(){
        KOSessionTask.meTask(completionHandler: { (profile, error) in
            if profile != nil{
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let kakao : KOUser = profile as! KOUser
                    
                    let email : String = kakao.email!;
                    let type : String = "kakao";
                    let id : String = String(describing: kakao.id!);
                    var name : String = String();
                    var profile_image : String = String();
                    var thumbnail_image : String = String();
                    
                    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        
    }
    
}
