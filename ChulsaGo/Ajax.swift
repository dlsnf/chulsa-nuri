//
//  People.swift
//  ajax
//
//  Created by Nu-Ri Lee on 2017. 5. 26..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

struct Ajax{
    
    static func forecast(withUrl url : String, withParam param : String, completion: @escaping ([[String:Any]]) -> () ){
       
        
        let basePath = url;
        
        let url = basePath;
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST";
        
        let paramToSend = param;
        
        request.httpBody = paramToSend.data(using: String.Encoding.utf8)
        
        
        let tesk = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            //print(response);
            
            
            guard let _:Data = data else { return }
            
            
            let json : Any?
            
            do{
                json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                //print((json as AnyObject).count)
                
                if let array = json as? [[String:Any]] {
                    DispatchQueue.main.async() {
                        completion(array);
                    }
                    
                }

            }catch{
                
                //print("Error: \(error)")

                //print(String(data: data!, encoding: .utf8)!);
                
                let array: [[String: Any]] = [
                    ["error": String(data: data!, encoding: .utf8)!]
                ]

                DispatchQueue.main.async() {
                        completion(array);
                }
                
                return
            }
            
            
            
            
        }
        
        tesk.resume();
        
        
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




