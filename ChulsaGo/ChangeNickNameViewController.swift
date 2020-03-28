





import UIKit


class ChangeNickNameViewController : UIViewController {
    
    var get_seq : String = "0";
    var get_nickName : String = "";
    
    @IBOutlet weak var nickNameTextField: UITextField!
    
    func ltrim(_ str: String, _ chars: Set<Character>) -> String {
        if let index = str.characters.index(where: {!chars.contains($0)}) {
            return String(str[index..<str.endIndex])
        } else {
            return ""
        }
    }
    
    @IBAction func nickNameTextFeildChange(_ sender: Any) {
        
        let text = self.nickNameTextField.text?.stringTrim();
        
        
        let text_length = (self.nickNameTextField.text?.count)!;
        let text_max_length = 10;
        let text_min_length = 3;
        
        if(text == "")
        {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }else if ( text == self.get_nickName){
            
            self.navigationController?.navigationItem.rightBarButtonItem?.isEnabled = false;
        }else if ( text_length < text_min_length ){
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }
    
    
    
    
    
    @IBAction func btnChangePress(_ sender: UIBarButtonItem) {
        self.changeNickName();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    
        self.navigationItem.rightBarButtonItem?.isEnabled = false;
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        print(get_seq);
        
        self.nickNameTextField.text = self.get_nickName;
        self.nickNameTextField.becomeFirstResponder();
        
        
    }
    
    func changeNickName(){
        //특수문자 제거
        let text = self.nickNameTextField.text?.replacingOccurrences(of: "[^\\wㄱ-ㅎ가-힣ㅏ-ㅣ]|[_]", with: "", options: .regularExpression)
        
        
        let text_length : Int = (text?.count)!;
        
        
        
        if ( text != self.nickNameTextField.text )
        {
            //print("띄어쓰기 및 특수문자는 사용할 수 없습니다.");
            let alertController = UIAlertController(title: NSLocalizedString("error", comment: "error"), message: NSLocalizedString("not character", comment: "not character"), preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
            })
            
            alertController.addAction(okButton)
            
            self.present(alertController, animated: true, completion: nil)
            
        }else if ( text_length > 10 ){
            let alertController = UIAlertController(title: NSLocalizedString("error", comment: "error"), message: NSLocalizedString("nickname ten length", comment: "nickname ten length"), preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: NSLocalizedString("done", comment: "done"), style: .cancel , handler: { (action) -> Void in
            })
            
            alertController.addAction(okButton)
            
            self.present(alertController, animated: true, completion: nil)
        }else{
            
            print("실행");
            
            //닉네임 변경
            let key : String = "nuri";
            let user_seq : String = self.get_seq;
            print(user_seq);
            let nick_name : String = text!;
            print(nick_name);
            let param : String = "key="+key+"&user_seq="+user_seq+"&nick_name="+nick_name;
            
            Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/change_nick_name.php", withParam: param) { (results:[[String:Any]]) in
                
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
                        
                        print(status);
                        
                        DispatchQueue.main.async() {
                            self.nickNameTextField.resignFirstResponder();
                        }
                        
                        DispatchQueue.main.async() {
                            self.navigationController?.popViewController(animated: true);
                        }

                        
                        
                    }
                }
            }//ajax
            
            
        }
        
        
    }
    
    
    
    
    
}



