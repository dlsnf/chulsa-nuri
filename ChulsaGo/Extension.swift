


import UIKit



class Extenstion {
    
}


extension String {
    
    // 문자열 공백 삭제
    public func stringTrim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}



extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    public func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x : 0, y : childStartPoint.y, width : 1, height : self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    public func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    public func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
    // Bonus: Scroll to top
    public func scrollToTop_1(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: 1)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to top
    public func scrollToTop_custom(toppx : Int, animated: Bool) {
        let topOffset = CGPoint(x: 0, y: toppx)
        setContentOffset(topOffset, animated: animated)
    }
    
    
}


extension UIImageView {
    func downloadImageFrom(_ link:String, contentMode: UIViewContentMode) {
        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
    
    func downloadAndResizeImageFrom(_ link:String, contentMode: UIViewContentMode ,newWidth:CGFloat) {
        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
            (data, response, error) -> Void in            
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data {
                    if let tempImage = UIImage(data: data){
                        let scale = newWidth / tempImage.size.width
                        let newHeight = tempImage.size.height * scale
                        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
                        tempImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
                        let newImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        self.image = newImage
                    }
                }
            }
        }).resume()
    }
}




//이미지 업로드를 위한 것
extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

