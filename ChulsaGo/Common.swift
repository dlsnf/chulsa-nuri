
import Foundation
import UIKit


struct Common{
    
    
    static func pinCount( pin_type : String, completion: @escaping (String) -> () ){
        
        
        let key : String = "nuri";
        let pin_type : String = pin_type;
        
        
        
        let param : String = "key="+key+"&pin_type="+pin_type;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_count.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    //print(result["error"] ?? "error")
                    let error : String = String(describing: result["error"]!)
                    completion(error);
                    
                }else{
                    //print(result["seq"]!)
                    let count : String = String(describing: result["count"]!)
                    
                    completion(count);
                    
                }
            }
            
            
            
        }//ajax
        
    }
    
    
    
    
    static func pinCommmentDelete(pin_seq : String, pin_type : String, completion: @escaping (String) -> () ){
        
        
        let key : String = "nuri";
        let pin_seq : String = pin_seq;
        let pin_type : String = pin_type;
        
        
        
        let param : String = "key="+key+"&pin_seq="+pin_seq+"&pin_type="+pin_type;
        
        
        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/comment_pin_delete.php", withParam: param) { (results:[[String:Any]]) in
            
            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    //print(result["error"] ?? "error")
                    let error : String = String(describing: result["error"]!)
                    completion(error);
                    
                }else{
                    //print(result["seq"]!)
                    //let status : String = String(describing: result["status"]!)
                    
                    completion("ok");
                    
                }
            }
            
            
            
        }//ajax
        
    }
    
    
    
    
    //custom
    static func pinDelete(pin_seq : String, pin_type : String, completion: @escaping (String) -> () ){
        
        
        let key : String = "nuri";
        let pin_seq : String = pin_seq;
        let pin_type : String = pin_type;
                print(pin_seq);
                print(pin_type);
        
        

        let param : String = "key="+key+"&pin_seq="+pin_seq+"&pin_type="+pin_type;


        Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_delete.php", withParam: param) { (results:[[String:Any]]) in

            for result in results{
                if (result["error"] != nil){
                    //에러발생시
                    //print(result["error"] ?? "error")
                    let error : String = String(describing: result["error"]!)
                    completion(error);

                }else{
                    //print(result["seq"]!)
                    //let status : String = String(describing: result["status"]!)

                    completion("ok");

                }
            }



        }//ajax
        
    }
    
    
    
    
    
    //custom pin report
    static func pinReport(pin_seq : String, pin_type : String, pin_user_seq : String, reporter_seq : String, body : String, completion: @escaping (String) -> () ){
        
        
        let key : String = "nuri";
        let pin_seq : String = pin_seq;
        let pin_type : String = pin_type;
        let pin_user_seq : String = pin_user_seq;
        let reporter_seq : String = reporter_seq;
        let body : String = body;
//
//        print(pin_seq);
//        print(pin_type);
//        print(pin_user_seq);
//        print(reporter_seq);
//        print(body);
//
        
        
                let param : String = "key="+key+"&pin_seq="+pin_seq+"&pin_type="+pin_type+"&pin_user_seq="+pin_user_seq+"&reporter_seq="+reporter_seq+"&body="+body;
        
        
                Ajax.forecast(withUrl: AppDelegate.serverUrl + "/chulsago/pin_report.php", withParam: param) { (results:[[String:Any]]) in
        
                    for result in results{
                        if (result["error"] != nil){
                            //에러발생시
                            //print(result["error"] ?? "error")
                            let error : String = String(describing: result["error"]!)
                            completion(error);
                            
                        }else{
                            //print(result["seq"]!)
                            //let status : String = String(describing: result["status"]!)
        
                            completion("ok");
                            
                        }
                    }
        
        
        
                }//ajax
        
    }
}
