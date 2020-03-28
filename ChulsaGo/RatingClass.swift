//
//  RatingClass.swift
//  ChulsaGo
//
//  Created by Nu-Ri Lee on 2017. 7. 3..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class RatingClass{
    
    
    static func rating(point : Int) -> String{
        var rating : String = "계란";
        
        if point < 10 {
            rating = NSLocalizedString("egg", comment: "egg");
        }else if point < 20{
            rating = NSLocalizedString("chick", comment: "chick");
        }else if point < 50{
            rating = NSLocalizedString("big chick", comment: "big chick");
        }else if point < 100{
            rating = NSLocalizedString("chicken", comment: "chicken");
        }else if point < 200{
            rating = NSLocalizedString("chicken ribs", comment: "chicken ribs");
        }else if point < 300{
            rating = NSLocalizedString("samgyetang", comment: "samgyetang");
        }else if point < 400{
            rating = NSLocalizedString("fried chicken", comment: "fried chicken");
        }else if point < 500{
            rating = NSLocalizedString("seasoned chicken", comment: "seasoned chicken");
        }else{
            rating = NSLocalizedString("god of the chicken", comment: "god of the chicken");
        }
        
        return rating
        
    }

}
