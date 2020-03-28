//
//  LikeViewController.swift
//  ChulsaGo
//
//  Created by nuri Lee on 2017. 12. 25..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class LikeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var pin_seq : String = String();
    var pin_type : String = String();
    
    
    
    @IBOutlet weak var likeTableView: UITableView!
    
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
    
    
    
    @IBAction func dismissView(_ sender: Any) {
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
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.likeTableView.delegate = self;
        self.likeTableView.dataSource = self;
        
        
        
        
        
        //빈셀 공백
        self.likeTableView.tableFooterView = UIView(frame: CGRect.zero);
        
        self.likeLoad();
    }
    
    
    @objc func draggedView(_ recognizer : UIPanGestureRecognizer){
        //let point = recognizer.location(in: view);
        let translation = recognizer.translation(in: view);
        
        //print(translation);
        
        if ( translation.y > 0 ){
            
            self.navigationController?.view.frame.origin.y = translation.y;
            
            //뒷배경 어둡게 하기
            //            if ( translation.y > 170 ){
            //
            //                self.navigationController?.view.superview?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            //
            //            }else{
            //                var percent : CGFloat = 1 - ( translation.y / 1.7 ) / 100;
            //
            //                if ( percent >= 0.5 ){
            //                    percent = 0.5;
            //                }
            //
            //                if ( percent >= 0 ){
            //                    self.navigationController?.view.superview?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: percent)
            //                }
            //
            //
            //            }
            
            
        }
        
        
        
        if ( recognizer.state == .ended ){
            
            if translation.y >= 170{
                
                
                //dismiss view
                
                
                let noti2 = Notification.init(name : Notification.Name(rawValue: "loginInit"));
                NotificationCenter.default.post(noti2);
                
                self.dismiss(animated: true, completion: nil)
            }else{
                //return to the original position
                UIView.animate(withDuration: 0.3, animations: {
                    self.navigationController?.view.frame.origin = CGPoint(x: 0, y: 0);
                })
            }
        }
    }//drag
    
    
    
    var tableJson : [[String:Any]] = [[String:Any]]();
    func likeLoad(){
        
        tableJson = [[String:Any]]();
        
        
        let key : String = "nuri";
        let pin_seq : String = self.pin_seq;
        let pin_type : String = self.pin_type;
        
        
        let param : String = "key="+key+"&pin_seq="+pin_seq+"&pin_type="+pin_type;
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_like_select.php", withParam: param) { (results:[[String:Any]]) in
            
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
                    
                    self.tableJson.append(result);
                    
                }
            }
            
            if (results.count != 0){ //값이 있을때
                //cell 재설정
                DispatchQueue.main.async() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        
                        self.likeTableView.reloadData();
                    }
                    
                }
            }else{ //아무런 값이 없을때
                
                //마지막 체크
                DispatchQueue.main.async() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.likeTableView.reloadData();
                    }
                    
                }
            }
            
            
        }//ajax
        
        
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMyPage" {
            let nav = segue.destination as! UINavigationController;
            let vc = nav.viewControllers[0] as! MyPageViewController;
            vc.get_seq = self.user_seq;
        }
        
    }
    
    
    
    
    
    
    
    //세션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    //셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //tableCount = self.tableJson.count;
        return self.tableJson.count;
        
    }
    
    
    //셀 연결
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "LikeTableCell", for: indexPath) as! LikeTableCell
        
        let index : Int = indexPath.row;
        
        
        
        DispatchQueue.main.async() {
            
            
            let result = self.tableJson[index];
            //let seq : String = String(describing: result["seq"]!)
            let user_seq : String = String(describing: result["user_seq"]!)
            //let block_user_seq : String = String(describing: result["block_user_seq"]!)
            
            let name : String = String(describing: result["name"]!)
            let thumbnail_image : String = String(describing: result["thumbnail_image"]!)
            
            
            //            let ip : String = String(describing: result["ip"]!)
            //            let date_ : String = String(describing: result["date_"]!)
            
            
            
            Cell.tag = Int(user_seq)!;
            
            DispatchQueue.main.async() {
                
                //프로필 사진 추가
                if thumbnail_image != ""{
                    Cell.profileImageView.contentMode = UIViewContentMode.scaleAspectFill
                    Cell.profileImageView.sd_setImage(with: URL(string: thumbnail_image), placeholderImage: nil,options: [.continueInBackground, .progressiveDownload], completed: { (image, error, cacheType, imageURL) in
                        //print("뿡");
                    })
                    
                    
                }else{
                    Cell.profileImageView.contentMode = UIViewContentMode.center
                    Cell.profileImageView.image = UIImage(named: "nonProfileSmall");
                }
                
                //프로필 텍스트 추가
                if name != ""{
                    let profileText = name;
                    Cell.labelNickName.text = profileText;
                }else{
                    let profileText = "NULL";
                    Cell.labelNickName.text = profileText;
                }
                
                
            }
            
            
        }
        
        
        return Cell
        
        
        
    }
    
    //셀 선택 취소
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    
    var user_seq : String = String();
    //셀 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print( indexPath.row);
        
        //선택셀 태그 가져오기
        let user_seq = tableView.cellForRow(at: indexPath)?.tag ?? 0
        
        
        self.user_seq = String(user_seq);
        
        self.performSegue(withIdentifier: "showMyPage", sender: self);
        
        
        
    }
    
    //셀 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70;
    }
    
    
    
    
    
    
    
    
}
