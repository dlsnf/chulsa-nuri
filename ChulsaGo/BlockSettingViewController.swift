//
//  BlockSettingViewController.swift
//  ChulsaGo
//
//  Created by nuri Lee on 2017. 12. 18..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import SDWebImage

class BlockSettingViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    
    @IBOutlet weak var blockTableView: UITableView!
    
    var loginSesseion = String();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blockTableView.delegate = self;
        self.blockTableView.dataSource = self;
        
        //빈셀 공백
        self.blockTableView.tableFooterView = UIView(frame: CGRect.zero);
        
        
        self.loginSesseion = String(UserDefaults.standard.object(forKey: "loginSesstion") as? Int ?? -1);
        
        
        self.blockLoad();
        
    }
    
    
    var tableJson : [[String:Any]] = [[String:Any]]();
    
    func blockLoad(){
        
        tableJson = [[String:Any]]();
        
        
        let key : String = "nuri";
        let user_seq : String = self.loginSesseion;
        
        
        let param : String = "key="+key+"&user_seq="+user_seq;
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/user_block_select.php", withParam: param) { (results:[[String:Any]]) in
            
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
                        
                        self.blockTableView.reloadData();
                    }
                    
                }
            }else{ //아무런 값이 없을때
                
                //마지막 체크
                DispatchQueue.main.async() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.blockTableView.reloadData();
                    }
                    
                }
            }
            
            
        }//ajax
        
        
    }
    
    
    @objc func btnBlockDeletePress(sender : RoundButton){
        
        let tag = sender.tag;
        
        
        
        let alertController = UIAlertController(title: NSLocalizedString("unblock", comment: "unblock"), message: NSLocalizedString("unblock?", comment: "unblock?"), preferredStyle: .alert)
        
        
        let  okButton = UIAlertAction(title: NSLocalizedString("unblock", comment: "unblock"), style: .destructive, handler: { (action) -> Void in
            
            
            let key : String = "nuri";
            let seq : String = String(tag);
            
            
            let param : String = "key="+key+"&seq="+seq;
            
            Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/user_block_delete.php", withParam: param) { (results:[[String:Any]]) in
                
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
                        let status : String = String(describing: result["status"]!)
                        
                        if status == "delete" { //삭제가 완료되었을때
                            DispatchQueue.main.async() {
                                self.blockLoad();
                            }
                        }
                        
                    }
                }
                
                
            }//ajax
            
            
            
        })
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
        
        
        
        
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
        
        
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "BlockSettingTableCell", for: indexPath) as! BlockSettingTableCell
        
        
        let index : Int = indexPath.row;
        
        //Cell.imageView.image = UIImage(named: "스크린샷 2017-07-14 오후 1.13.13.png");
        
        
        DispatchQueue.main.async() {
            
            
            let result = self.tableJson[index];
            let seq : String = String(describing: result["seq"]!)
            //let user_seq : String = String(describing: result["user_seq"]!)
            //let block_user_seq : String = String(describing: result["block_user_seq"]!)
            
            let name : String = String(describing: result["name"]!)
            let thumbnail_image : String = String(describing: result["thumbnail_image"]!)
            
            
//            let ip : String = String(describing: result["ip"]!)
//            let date_ : String = String(describing: result["date_"]!)
            
            
            
            Cell.tag = Int(seq)!;
            Cell.btnBlockDelete.tag = Int(seq)!;
            
            
            //버튼 펑션 추가
            Cell.btnBlockDelete.addTarget(self, action: #selector(self.btnBlockDeletePress(sender:)), for: .touchUpInside);
            
            DispatchQueue.main.async() {
                
                //프로필 사진 추가
                if thumbnail_image != ""{
                    Cell.profileImageView.contentMode = UIViewContentMode.scaleAspectFill
                    //Cell.profileImageView.downloadAndResizeImageFrom(thumbnail_image, contentMode: .scaleAspectFill, newWidth: 400)
                    
                    Cell.profileImageView.sd_setImage(with: URL(string: thumbnail_image), placeholderImage: nil,options: [.continueInBackground, .progressiveDownload], completed: { (image, error, cacheType, imageURL) in
                        //print("뿡");
                    })
                }else{
                    Cell.profileImageView.contentMode = UIViewContentMode.center;
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
    
    //셀 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print( indexPath.row);
        
        //선택셀 태그 가져오기
        //print(homeTableView.cellForRow(at: indexPath)?.tag ?? 0)
        
        
    }
    
    //셀 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70;
    }
    
    
}
